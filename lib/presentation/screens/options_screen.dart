import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';


class OptionsScreen extends StatefulWidget {
  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool isNotificationsEnabled = false;
  bool value1 = false;
  bool value2 = false;

  int _distanceLevel = 1; // 0: Very Close, 1: Close, 2: Nearby

  String get distanceLabel {
    switch (_distanceLevel) {
      case 0:
        return "Minimum";
      case 1:
        return "Medium";
      case 2:
        return "Maximum";
      default:
        return "";
    }
  }
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Connection Distance",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _distanceLevel.toDouble(),
                      min: 0,
                      max: 2,
                      divisions: 2,
                      label: distanceLabel,
                      onChanged: (double newValue) {
                        setState(() {
                          _distanceLevel = newValue.round();
                        });
                      },
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Min", style: TextStyle(fontSize: 12)),
                        Text("-", style: TextStyle(fontSize: 12)),
                        Text("Max", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
          SwitchListTile(
            title: Text("Background Connection"),
            subtitle: Text("Enable or disable autoconnection"),
            value: value1,
            onChanged: (bool value) {setState(() {
              value1=value;
            });},
          ),
          SwitchListTile(
            title: Text("Background Connection"),
            subtitle: Text("Enable or disable autoconnection"),
            value: value2,
            onChanged: (bool value) {setState(() {
              value2=value;
            });},
          ),
        ],
      ),
    );
  }
}
