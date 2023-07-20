// import 'dart:html';

import 'package:clientsf/singelton/AppSingelton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int hourlyRate = 0;

  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red);

  bool lockAppSwitchVal = true;
  bool fingerprintSwitchVal = false;
  bool changePassSwitchVal = true;

  TextStyle headingStyleIOS = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: CupertinoColors.inactiveGray,
  );
  TextStyle descStyleIOS = const TextStyle(color: CupertinoColors.inactiveGray);
  Future<void> getStoredHourlyRate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // int storedValue = prefs.getInt('newValue') ?? 0;
    int storedValue = prefs.getInt('${AppSingelton().userID}_newValue') ?? 0;
    //  print(storedValue);
    //  print(AppSingelton().userID);
    setState(() {
      hourlyRate = storedValue;
    });
  }

  @override
  void initState() {
    super.initState();

    getStoredHourlyRate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings UI"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Common",
                    style: headingStyle,
                  ),
                ],
              ),
              // const ListTile(
              //   leading: Icon(Icons.language),
              //   title: Text("Language"),
              //   subtitle: Text("English"),
              // ),
              // const Divider(),
              // const ListTile(
              //   leading: Icon(Icons.cloud),
              //   title: Text("Environment"),
              //   subtitle: Text("Production"),
              // ),
              SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("שווי שעת עבודה", style: headingStyle),
                  SizedBox(height: 6.0),
                  Row(
                    children: [
                      Text(
                        hourlyRate.toStringAsFixed(
                            2), // Display the current value of hourlyRate
                        style: TextStyle(fontSize: 16),
                      ),
                      Slider(
                        value: hourlyRate.toDouble(),
                        min: 0,
                        max: 400,
                        divisions: 100,
                        onChanged: (newValue) async {
                          double newHourlyRate = newValue;
                          setState(() {
                            hourlyRate = newHourlyRate.toInt();
                            // print(hourlyRate);
                            // print(AppSingelton().hourlyRate);
                          });
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          // prefs.setInt('newValue', newValue.toInt());
                          prefs.setInt('${AppSingelton().userID}_newValue',
                              newValue.toInt());
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const ListTile(
                leading: Icon(Icons.phone),
                title: Text("Phone Number"),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.mail),
                title: Text("Email"),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text("Sign Out"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Security", style: headingStyle),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.phonelink_lock_outlined),
                title: const Text("Lock app in background"),
                trailing: Switch(
                    value: lockAppSwitchVal,
                    activeColor: Colors.redAccent,
                    onChanged: (val) {
                      setState(() {
                        lockAppSwitchVal = val;
                      });
                    }),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text("Use fingerprint"),
                trailing: Switch(
                    value: fingerprintSwitchVal,
                    activeColor: Colors.redAccent,
                    onChanged: (val) {
                      setState(() {
                        fingerprintSwitchVal = val;
                      });
                    }),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Change Password"),
                trailing: Switch(
                    value: changePassSwitchVal,
                    activeColor: Colors.redAccent,
                    onChanged: (val) {
                      setState(() {
                        changePassSwitchVal = val;
                      });
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Misc", style: headingStyle),
                ],
              ),
              const ListTile(
                leading: Icon(Icons.file_open_outlined),
                title: Text("Terms of Service"),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.file_copy_outlined),
                title: Text("Open Source and Licences"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
