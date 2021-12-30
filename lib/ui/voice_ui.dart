import 'dart:async';
import 'dart:math';
import 'package:wateringsystem/getapi.dart';
import 'package:wateringsystem/mqtt_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

final SpeechToText speech = SpeechToText();
bool hasSpeech = false;

class VoiceUI extends StatefulWidget {
  @override
  VoiceUIState createState() => VoiceUIState();
}

class VoiceUIState extends State<VoiceUI> with AutomaticKeepAliveClientMixin {
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = 'vi_VN';
  String response = '';
  int resultListened = 0;
  MqttStream mqtt = new MqttStream();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  VoiceUIState() {
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    if (!hasSpeech) {
      hasSpeech = await speech.initialize(
          onError: errorListener, onStatus: statusListener, debugLogging: true);
    }
    if (!mounted) return;

    setState(() {
      print(_hasSpeech);
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(children: [
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                Container(
                  child: Text(
                    'Recognized Words',
                    style: TextStyle(fontSize: 22.0),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Center(
                      child: Text(
                        lastWords,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextButton(
                      child: Text('Start'),
                      onPressed: !_hasSpeech || speech.isListening
                          ? null
                          : startListening,
                    ),
                    TextButton(
                      child: Text('Stop'),
                      onPressed: speech.isListening ? stopListening : null,
                    ),
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: speech.isListening ? cancelListening : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    'Response',
                    style: TextStyle(fontSize: 22.0),
                  ),
                ),
                Expanded(
                  //child: Text(lastError),
                  child: Container(
                    child: Center(
                      child: Text(
                        response,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: speech.isListening
                  ? Text(
                      "Listening...",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      'Not listening',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ]),
      ),
    );
  }

  void startListening() {
    lastWords = '';
    lastError = '';
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 20),
        pauseFor: Duration(seconds: 5),
        partialResults: false,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    ++resultListened;
    print('Result listener $resultListened');
    setState(() {
      lastWords = '${result.recognizedWords} - ${result.finalResult}';
      //print('lastword: $lastWords');
      processResponse(result.recognizedWords.toLowerCase());
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    // print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    // print(
    // 'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = '$status';
    });
  }

  /*void splitCommand(String result) {
    List results = result.split('và');
    results.forEach((element) => () {
          print(element);
          processResponse(element);
          Future.delayed(Duration(seconds: 1));
        });
  }*/

  void processResponse(String input) async {
    String result = '';
    if (input.contains('tưới')) {
      if (input.contains('ngừng')) {
        mqtt.publish('shipangei00@gmail.com/pump', 'Off', true);
        result = 'Đã ngừng tưới cây';
      } else {
        var timeMillis = await getApi.predict();
        var timeSec = timeMillis / 1000;
        mqtt.publish('shipangei00@gmail.com/pump', '$timeMillis', true);
        result = 'Đang tưới cây trong $timeSec giây';
      }
    } else if (input.contains('đèn')) {
      if (input.contains('bật')) {
        mqtt.publish('shipangei00@gmail.com/light', 'On', true);
        result = 'Đã bật đèn';
      } else if (input.contains('tắt')) {
        mqtt.publish('shipangei00@gmail.com/light', 'Off', true);
        result = 'Đã tắt đèn';
      } else {
        result = 'Yêu cầu không hợp lệ';
      }
    } else if (input.contains('mái')) {
      if (input.contains('mở')) {
        mqtt.publish('shipangei00@gmail.com/roof', 'Open', true);
        result = 'Đã mở mái che';
      } else if (input.contains('đóng')) {
        mqtt.publish('shipangei00@gmail.com/light', 'Close', true);
        result = 'Đã đóng mái che';
      } else {
        result = 'Yêu cầu không hợp lệ';
      }
    } else
      result = 'Yêu cầu không hợp lệ';
    textSpeech(result);
    setState(() {
      response = result;
    });
  }

  void textSpeech(String text) async {
    FlutterTts flutterTts = new FlutterTts();
    await flutterTts.setLanguage("vi-VN");
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(text);
  }
}
