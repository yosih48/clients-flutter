import 'dart:async';
import 'dart:convert';

import 'package:clientsf/objects/clients.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../componenets/dialogFilter.dart';
import 'callsInfo.dart';

class CallsScreen extends StatefulWidget {
  final Todo clientId;
  CallsScreen({required this.clientId});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  ValueNotifier<String?> _selectedCharacterNotifier =
      ValueNotifier<String?>('');

  Future<double> fetchDataFromFirestore() async {
    print('clientcalls clientid ${widget.clientId.id}');
    Map<String, dynamic> dataMap = {};

    // Reference to the collection in Firestore
    CollectionReference collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_data')
        .doc(widget.clientId.id)
        .collection('calls');

    // Get the documents from the collection
    QuerySnapshot querySnapshot = await collectionRef.get();
    double totalPayment = querySnapshot.docs.fold(0,
        (double previousValue, QueryDocumentSnapshot<Object?> element) {
      final payment = element['payment'];
      final paid = element['paid'];

      return previousValue +
          (paid == false && payment != null ? payment.toDouble() : 0);
    });
    print(totalPayment);

    return totalPayment;
  }

  bool? _getFilterValue() {
    if (_selectedCharacterNotifier.value == 'paid') {
      return true;
    } else if (_selectedCharacterNotifier.value == 'notpaid') {
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

  void onRadioButtonSelected(String? character) {}

  String? selectedCharacter;

  void _displayFilterDialog(BuildContext context) {
    fetchDataFromFirestore();
    showDialog(
      context: context,
      // T: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('filter'),
          // content: TextField(
          //   controller: _textFieldController,
          //   decoration: const InputDecoration(hintText: 'Type your todo'),
          //   autofocus: true,
          // ),
          content: Container(
            height: 200.0,
            child: Column(
              children: [
                RadioButtonExample(
                  onOptionSelected: (character) {
                    selectedCharacter = character;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // print(selectedCharacter);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // print(selectedCharacter);
                onRadioButtonSelected(selectedCharacter ?? 'ff');
                // handleProductListChanged(productList);
                setState(() {
                  _selectedCharacterNotifier.value =
                      //  selectedCharacter?? 'bush';
                      selectedCharacter;

                  print('setState ${selectedCharacter}');
                  print(_selectedCharacterNotifier.value);
                  // bool newBoolValue =
                  //     selectedCharacter?.toLowerCase() != "false";

                  // print(' newBoolValue ${newBoolValue}');
                  // _selectedCharacterNotifier.value = newBoolValue;
                  // // _selectedCharacterNotifier.value =
                  // // !_selectedCharacterNotifier.value;

                  // print('setState2 ${_selectedCharacterNotifier.value}');
                  // print(_selectedCharacterNotifier.value.runtimeType);
                });
              },
              child: const Text('הוספה'),
            ),
          ],
        );
      },
    );
  }

  String showUnpaidOnly = 'lafayette';
  // double totalPayment = 0;

  @override
  Widget build(BuildContext context) {
    print(widget.clientId.name);
    String? clientName = widget.clientId.name;

    // print(selectedOption);
    return Scaffold(
      appBar: AppBar(
        // title: Text(AppLocalizations.of(context)!.callsHistory),
        title: Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  AppLocalizations.of(context)!.callsHistory,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  clientName!,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),

        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'filterPaid',
                child: Text('סינון'),
              ),
              // const PopupMenuItem<String>(
              //   value: 'option2',
              //   child: Text('Option 2'),
              // ),
              // const PopupMenuItem<String>(
              //   value: 'option3',
              //   child: Text('Option 3'),
              // ),
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
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('user_data')
              .doc(widget.clientId.id)
              .collection('calls')
              // .where('paid', isEqualTo: _selectedCharacterNotifier.value)
              .where('paid', isEqualTo: _getFilterValue())
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
                      AppLocalizations.of(context)!.date,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(width: 32.0),
                    Text(
                      AppLocalizations.of(context)!.callDetails,
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
                      AppLocalizations.of(context)!.paid,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder<double>(
                        future: fetchDataFromFirestore(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Show a loading indicator while waiting for the data
                          }

                          if (snapshot.hasError) {
                            return Text(
                                'Error: ${snapshot.error}'); // Show an error message if there's an error
                          }

                          double totalPayment = snapshot.data ?? 0.0;

                          return Text(
                            'יתרה לחיוב: ${totalPayment.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.red),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: calls.length,
                    itemBuilder: (BuildContext context, int index) {
                      final call = calls[index].data() as Map<String, dynamic>;
                      // print(call['id']);
                      // print(call['timestamp']);
                      final callDetails = call['call'];
                      final type = call['type'];
                      final id = call['id'];
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

                      // totalPayment = calls.fold(0, (double previousValue,
                      //     QueryDocumentSnapshot<Object?> element) {
                      //   final payment = element['payment'];
                      //   final paid = element['paid'];
                      //   return previousValue +
                      //       (paid == false && payment != null
                      //           ? payment.toDouble()
                      //           : 0);
                      // });

                      // for (var call in calls) {
                      //   final payment = call['payment'];
                      //   final paid = call['paid'];

                      //   if (payment != null && paid == false) {
                      //     totalPayment += payment;
                      //   }
                      // }

                      // print('Total payment: $totalPayment');
                      // print(payment);

                      // );
                      return InkWell(
                        onTap: () {
                          // Handle the second option
                          // Navigator.of(context).pop();
                          // Navigator.pushNamed(context, '/actions');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClientServiceScreen(
                                  call: call, user: widget.clientId.id),
                            ),
                          );
                        },
                        child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(' $sum'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
