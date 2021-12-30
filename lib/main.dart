import 'package:wateringsystem/ui/info_ui.dart';
import 'package:wateringsystem/ui/settings_ui.dart';
import 'package:wateringsystem/ui/voice_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.info),
                  text: 'Data',
                ),
                Tab(
                  icon: Icon(Icons.mic),
                  text: 'Assistant',
                ),
                Tab(
                  icon: Icon(Icons.settings),
                  text: 'Settings',
                )
              ],
            ),
            title: Text('Greenhouse'),
          ),
          body: TabBarView(
            children: [
              InfoUI(title: ''),
              VoiceUI(),
              SettingsUI(title: ''),
            ],
          ),
        ),
      ),
    );
  }
}
