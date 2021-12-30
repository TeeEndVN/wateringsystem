import 'package:wateringsystem/cubit.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';
import 'package:random_string/random_string.dart';
import 'dart:math' show Random;

class MqttStream {
  MqttServerClient? client;

  MqttStream() {
    subscribe();
  }

  Future<MqttServerClient?> _login() async {
    client = new MqttServerClient.withPort(
        'maqiatto.com', randomAlphaNumeric(10), 1883);
    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs('email here', 'password here');
    client!.connectionMessage = connMess;

    try {
      await client!.connect();
    } on Exception catch (e) {
      client!.disconnect();
      client = null;
      return client;
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
    } else {
      client!.disconnect();
      client = null;
    }
    return client;
  }

  Future<bool> subscribe() async {
    if (await _connectToClient() == true) {
      client!.onDisconnected = _onDisconnected;
      client!.onConnected = _onConnected;
      client!.onSubscribed = _onSubscribed;
      topic();
    }
    return true;
  }

  Future<bool> _connectToClient() async {
    if (client != null &&
        client!.connectionStatus!.state == MqttConnectionState.connected) {
    } else {
      client = await _login();
      if (client == null) {
        return false;
      }
    }
    return true;
  }

  void _onSubscribed(String topic) {
    print('subscribe: $topic');
  }

  void _onDisconnected() {
    client!.disconnect();
    print('disconnected');
  }

  void _onConnected() {
    print('connected');
  }

  Future _subscribe(String topic) async {
    client!.subscribe(topic, MqttQos.atLeastOnce);
    MqttClientTopicFilter topicFilter =
        MqttClientTopicFilter(topic, client!.updates);
    topicFilter.updates.listen((List<MqttReceivedMessage<MqttMessage?>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      this.add(pt, topic);
      print(topic + ': ' + pt);
    });
  }

  Future<void> publish(String topic, String value, bool retain) async {
    if (await _connectToClient() == true) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(value);
      client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!,
          retain: retain);
    }
  }

  Future<void> topic() async {
    _subscribe("shipangei00@gmail.com/humid");
    _subscribe("shipangei00@gmail.com/temp");
    _subscribe("shipangei00@gmail.com/moisture");
    _subscribe("shipangei00@gmail.com/pumpstat");
    _subscribe("shipangei00@gmail.com/roofstat");
    _subscribe("shipangei00@gmail.com/lightstat");
  }

  Future<void> add(String pt, String topic) async {
    switch (topic) {
      case 'shipangei00@gmail.com/humid':
        {
          humidCubit.receive(pt);
          break;
        }
      case 'shipangei00@gmail.com/temp':
        {
          tempCubit.receive(pt);
          break;
        }
      case 'shipangei00@gmail.com/moisture':
        {
          moistureCubit.receive(pt);
          break;
        }
      case 'shipangei00@gmail.com/pumpstat':
        {
          waterCubit.receive(pt);
          break;
        }
      case 'shipangei00@gmail.com/roofstat':
        {
          roofCubit.receive(pt);
          break;
        }
      case 'shipangei00@gmail.com/lightstat':
        {
          lightCubit.receive(pt);
          break;
        }
    }
  }
}
