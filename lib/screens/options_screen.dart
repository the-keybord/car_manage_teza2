import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class OptionsScreen extends StatefulWidget {
  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool isNotificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotificationsEnabled = prefs.getBool('automatic_connection') ?? false;
    });
  }

  Future<void> _toggleAutoConnect(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('automatic_connection', value);

    setState(() {
      isNotificationsEnabled = value;
    });

    print(value ? "🔔 Autoconnect ENABLED!" : "🔕 Autoconnect DISABLED!");

    // ✅ Send updated settings to background service (REAL-TIME UPDATE)
    final service = FlutterBackgroundService();
    service.invoke('update_settings', {"notifications": value});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Options")),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Background Connection"),
            subtitle: Text("Enable or disable autoconnection"),
            value: isNotificationsEnabled,
            onChanged: _toggleAutoConnect,
          ),
        ],
      ),
    );
  }
}
