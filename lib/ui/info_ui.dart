import 'package:wateringsystem/cubit.dart';
import 'package:wateringsystem/getapi.dart';
import 'package:wateringsystem/mqtt_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:charcode/charcode.dart';

class InfoUI extends StatefulWidget {
  InfoUI({required this.title});
  final String title;

  @override
  InfoUIState createState() => InfoUIState();
}

class InfoUIState extends State<InfoUI> {
  MqttStream mqtt = new MqttStream();
  TextEditingController _c = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Column(children: <Widget>[
      _tempData(),
      _humidData(),
      _moistureData(),
      _lightControl(),
      _waterControl(),
      _roofControl()
    ]);
  }

  Widget _tempData() {
    return ListTile(
      leading: Icon(Icons.ac_unit, size: 56.0),
      title: Text('Temperature'),
      subtitle: BlocBuilder<TempCubit, String>(
          bloc: tempCubit,
          builder: (context, state) {
            return Text('$state' + String.fromCharCode($deg) + 'C');
          }),
    );
  }

  Widget _humidData() {
    return ListTile(
      leading: Icon(Icons.invert_colors, size: 56.0),
      title: Text('Humidity'),
      subtitle: BlocBuilder<HumidCubit, String>(
          bloc: humidCubit,
          builder: (context, state) {
            return Text('$state' + '%');
          }),
    );
  }

  Widget _moistureData() {
    return ListTile(
      leading: Icon(Icons.waves, size: 56.0),
      title: Text('Moisture'),
      subtitle: BlocBuilder<MoistureCubit, String>(
          bloc: moistureCubit,
          builder: (context, state) {
            return Text('$state' + '%');
          }),
    );
  }

  Widget _lightControl() {
    return ListTile(
      leading: Icon(Icons.lightbulb_outline),
      title: Text('Light control'),
      subtitle: BlocBuilder<LightCubit, String>(
          bloc: lightCubit,
          builder: (context, state) {
            return Text('$state');
          }),
      onTap: () {
        if (lightCubit.state == 'Off') {
          mqtt.publish('shipangei00@gmail.com/light', 'On', true);
        } else {
          mqtt.publish('shipangei00@gmail.com/light', 'Off', true);
        }
      },
    );
  }

  Widget _waterControl() {
    return ListTile(
      leading: const Icon(Icons.water_damage),
      title: Text('Water control'),
      subtitle: BlocBuilder<WaterCubit, String>(
          bloc: waterCubit,
          builder: (context, state) {
            return Text('$state');
          }),
      onTap: () async {
        if (waterCubit.state == 'Off') {
          var timeMillis = await getApi.predict();
          var timeSec = timeMillis / 1000;
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('The pump will run for $timeSec seconds'),
              content: TextField(
                controller: _c,
                keyboardType: TextInputType.number,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    mqtt.publish(
                        'shipangei00@gmail.com/pump', '$timeMillis', true);
                    Navigator.pop(context, 'OK');
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          mqtt.publish('shipangei00@gmail.com/pump', 'Off', true);
        }
      },
    );
  }

  Widget _roofControl() {
    return ListTile(
      leading: const Icon(Icons.roofing),
      title: Text('Roof control'),
      subtitle: BlocBuilder<RoofCubit, String>(
          bloc: roofCubit,
          builder: (context, state) {
            return Text('$state');
          }),
      onTap: () {
        if (roofCubit.state == 'Closed') {
          mqtt.publish('shipangei00@gmail.com/roof', 'Open', true);
        } else {
          mqtt.publish('shipangei00@gmail.com/roof', 'Close', true);
        }
      },
    );
  }
}
