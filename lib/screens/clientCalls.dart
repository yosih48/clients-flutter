import 'dart:async';

import 'package:clientsf/objects/clients.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../componenets/dialogFilter.dart';




class CallsScreen extends StatefulWidget {
  final Todo clientId;
  CallsScreen({required this.clientId});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}
enum SingingCharacter {  both, trueValue, falseValue }

class _CallsScreenState extends State<CallsScreen> {
  ValueNotifier<String> _selectedCharacterNotifier = ValueNotifier<String>('');

  String? selectedCharacter;

     SingingCharacter? selectedValue = SingingCharacter.both;
  bool? _getFilterValue() {
    // final String selectedValue = _selectedCharacterNotifier.value;
    // final String selectedValue = _selectedCharacterNotifier.value;

    if (selectedValue == SingingCharacter.trueValue) {
      return true;
    } else if (selectedValue == SingingCharacter.falseValue) {
      return false;
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    _selectedCharacterNotifier.dispose();
    super.dispose();
  }

  void onRadioButtonSelected(String character) {
    setState(() {
      selectedCharacter =
          character; // Set selectedCharacter value when a radio button is selected
    });
  }

  void _displayFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ListTile(
              //   title: const Text('True'),
              //   leading: Radio<String>(
              //     value: 'true',
              //     groupValue: _selectedCharacterNotifier.value,
              //     onChanged: (String? value) {
              //       setState(() {
              //         _selectedCharacterNotifier.value = value!;
              //         selectedCharacter = value;
              //       });
              //     },
              //   ),
              // ),
              //B
                         ListTile(
                    title: Text('true'),
                    leading: Radio<SingingCharacter>(
                      value: SingingCharacter.trueValue,
                      groupValue: selectedValue,
                      onChanged: (SingingCharacter? value) {
                        setState(() {
                            selectedValue = value;
                        print( selectedValue);
                        });
                      },
                    ),
                  ),
              // ListTile(
              //   title: const Text('False'),
              //   leading: Radio<String>(
              //     value: 'false',
              //     groupValue: _selectedCharacterNotifier.value,
              //     onChanged: (String? value) {
              //       setState(() {
              //         _selectedCharacterNotifier.value = value!;
              //         selectedCharacter = value;
              //       });
              //     },
              //   ),
              // ),
              //b
                             ListTile(
                    title: Text('False'),
                    leading: Radio<SingingCharacter>(
                      value: SingingCharacter.falseValue,
                      groupValue: selectedValue,
                      onChanged: (SingingCharacter? value) {
                        setState(() {
                            selectedValue = value;
                        
                        });
                      },
                    ),
                  ),
              // ListTile(
              //   title: const Text('Both'),
              //   leading: Radio<String>(
              //     value: 'both',
              //     groupValue: _selectedCharacterNotifier.value,
              //     onChanged: (String? value) {
              //       setState(() {
              //         _selectedCharacterNotifier.value = value!;
              //         selectedCharacter = value;
              //       });
              //     },
              //   ),
              // ),
              //b
                                 ListTile(
                    title: Text('both'),
                    leading: Radio<SingingCharacter>(
                      value: SingingCharacter.both,
                      groupValue: selectedValue,
                      onChanged: (SingingCharacter? value) {
                        setState(() {
                          print(value);
                            selectedValue = value;
                        
                        });
                      },
                    ),
                  ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  String showUnpaidOnly = 'lafayette';

  @override
  Widget build(BuildContext context) {
    // print(showUnpaidOnly);

    // print(selectedOption);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.callsHistory),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'filterPaid',
                child: Text('סינון'),
              ),
              const PopupMenuItem<String>(
                value: 'option2',
                child: Text('Option 2'),
              ),
              const PopupMenuItem<String>(
                value: 'option3',
                child: Text('Option 3'),
              ),
            ],
            icon: Icon(Icons.more_vert), // Three dots icon
            onSelected: (String value) {
              // Handle option selection here
              // if (value == 'option1') {
              _displayFilterDialog(context);
              // }
              // print('Selected option: $value');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.clientId.id)
              .collection('calls')
              // .where('paid', isEqualTo: _selectedCharacterNotifier.value)
              .where('paid',
                  // isEqualTo: _selectedCharacterNotifier.value ? true : null)
                  isEqualTo: _getFilterValue())
              // .orderBy('timestamp', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            }

            final calls = snapshot.data!.docs;

            return Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 12.0),
                    Text(
                      'תאריך',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(width: 32.0),
                    Text(
                      'תאור קריאה',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(width: 24.0),
                    Text(
                      'סכום',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(width: 48.0),
                    Text(
                      'שולם',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: calls.length,
                    itemBuilder: (BuildContext context, int index) {
                      final call = calls[index].data() as Map<String, dynamic>;
                      // print(call['call']);
                      // print(call['timestamp']);
                      final callDetails = call['call'];
                      final type = call['type'];
                      final paid = call['paid'];
                      final hour = call['hour'];
                      final timestamp = call['timestamp'];
                      final payment = call['payment'];
                      final formattedDate = DateFormat('dd/MM/yy').format(
                          DateTime.fromMillisecondsSinceEpoch(timestamp));
                      late String sum;
                      if (paid == true) {
                        sum = "כן";
                      } else {
                        sum = "לא";
                      }
                      // print(paid);

                      // );
                      return Container(
                        // padding: EdgeInsets.symmetric(horizontal: 20),
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                            // border: Border.bo(color: Colors.blueAccent)
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.blueAccent,
                                    width: 1.0,
                                    style: BorderStyle.solid))),

                        child: Container(
                          // padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              // borderRadius: BorderRadius.circular(8),
                              // color: Colors.blueAccent,
                              ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(' $formattedDate '),
                                    // Text(callDetails),
                                    SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 60,
                                width: 0.5,
                                color: Colors.grey[200]!.withOpacity(0.7),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(callDetails),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 60,
                                width: 0.5,
                                color: Colors.grey[200]!.withOpacity(0.7),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('  $payment'),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 60,
                                width: 0.5,
                                color: Colors.grey[200]!.withOpacity(0.7),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(' $sum'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
