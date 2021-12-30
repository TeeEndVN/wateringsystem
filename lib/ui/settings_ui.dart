import 'package:wateringsystem/getapi.dart';
import 'package:flutter/material.dart';

class SettingsUI extends StatefulWidget {
  SettingsUI({required this.title});
  final String title;

  @override
  SettingsUIState createState() => SettingsUIState();
}

class SettingsUIState extends State<SettingsUI> {
  TextEditingController _c = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Column(children: <Widget>[
      Text('IP Address: '),
      TextField(
        controller: _c,
      ),
      ElevatedButton(
        child: Text('Save'),
        onPressed: () => getApi.setIp = _c.text,
      )
    ]);
  }
}
