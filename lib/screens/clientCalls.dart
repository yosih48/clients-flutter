import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

import 'package:clientsf/objects/clients.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:external_path/external_path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:permission_handler/permission_handler.dart';
import '../componenets/addClientDialof.dart';
import '../componenets/alertDialog.dart';
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
Future<List<dynamic>> fetchCallsData() async {
  CollectionReference callsCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('user_data')
      .doc(widget.clientId.id)
      .collection('calls');
  
  QuerySnapshot querySnapshot = await callsCollection.get();
  List<dynamic> callsData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for (var row in callsData) {
   print(callsData);
  }
  return callsData;
}
// void exportToExcel(List<dynamic> data) async{
//   final Excel excel = Excel.createExcel();
//   final Sheet sheet = excel['Sheet1'];

//   // Add headers
//   sheet.appendRow(data[0].keys.toList());

//   // Add data rows
//   for (var row in data) {
//     sheet.appendRow(row.values.toList());
//   }
 

//   // Save the Excel file
//    List<int>? excelBytes = excel.encode();
    
//   String excelFilePath = await _getExcelFilePath();
//   final File excelFile = File(excelFilePath);
//   await excelFile.writeAsBytes(excelBytes!);
//     showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Export Complete'),
//         content: Text('Data has been exported to Excel file: $excelFilePath.'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text('OK'),
//           ),
//         ],
//       );
//     },
//   );
//     // Save the bytes to a file or send it to the user
//     // You can use the 'path_provider' package to access device storage
 
// }
  void _generateCsvFile(List<dynamic> data) async {
     print('csv data  ${data}');
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    // List<dynamic> associateList = [
    //   {"number": 1, "lat": "14.97534313396318", "lon": "101.22998536005622"},
    //   {"number": 2, "lat": "14.97534313396318", "lon": "101.22998536005622"},
    //   {"number": 3, "lat": "14.97534313396318", "lon": "101.22998536005622"},
    //   {"number": 4, "lat": "14.97534313396318", "lon": "101.22998536005622"}
    // ];

    List<List<dynamic>> rows = [];

    List<dynamic> row = [];
    row.add("number");
    row.add("latitude");
    row.add("longitude");
    rows.add(row);
    for (int i = 0; i < data.length; i++) {
      List<dynamic> row = [];
      row.add(data[i]["call"]);
      row.add(data[i]["type"]);
      row.add(data[i]["paid"]);
      rows.add(row);
    }

    // String csv = const ListToCsvConverter().convert(rows);

    // String dir = await ExtStorage.getExternalStoragePublicDirectory(
    //     ExtStorage.DIRECTORY_DOWNLOADS);
    // print("dir $dir");
    // String file = "$dir";

    // File f = File(file + "/filename.csv");

    // f.writeAsString(csv);
    String csv = const ListToCsvConverter().convert(rows);

String dir = await ExternalPath.getExternalStoragePublicDirectory(
    ExternalPath.DIRECTORY_DOWNLOADS);
    print("dir $dir");
    String file = "$dir";

    File f = File(file + "/filename.csv");

    f.writeAsString(csv);
                               showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Export Complete'),
          content: Text('Data has been exported to Excel.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );


  }
Future<String> _getExcelFilePath() async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  String excelFilePath = '${appDocumentsDirectory.path}/calls_data.xlsx';
  return excelFilePath;
}


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
          title: Text(AppLocalizations.of(context)!.filtering),
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
              child: Text(AppLocalizations.of(context)!.cancel),
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
              child: Text(AppLocalizations.of(context)!.add),
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
              PopupMenuItem<String>(
                value: 'filterPaid',
                child: Text(AppLocalizations.of(context)!.filtering),
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
              // .where('userRef', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              // .orderBy('timestamp', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(AppLocalizations.of(context)!.loading);
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
                      AppLocalizations.of(context)!.amount,
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
    //             Row(
    //               children: [
    //                                     IconButton(
    //                       // iconSize: 18,
    //                       padding: EdgeInsets.zero,
    //                       icon: Icon(Icons.delete),
    //                       onPressed: ()async {
    //                 List callsData = await fetchCallsData();
    //                 //    exportToExcel(callsData);
    //       _generateCsvFile(callsData);
    //                        showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text('Export Complete'),
    //       content: Text('Data has been exported to Excel.'),
    //       actions: <Widget>[
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //           child: Text('OK'),
    //         ),
    //       ],
    //     );
    //   },
    // );
    //                       },
    //                     ),
    //               ],
    //             ),
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
                            '${AppLocalizations.of(context)!.ramainingBalance}:'
                            ' ${totalPayment.toStringAsFixed(2)}',
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
                      print(call['id']);
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
                      // late String sum;
                      // if (paid == true) {
                      //   sum = "כן";
                      // } else {
                      //   sum = "לא";
                      // }

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
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Slidable(
                          key: const ValueKey(0),
                          endActionPane: ActionPane(
                            dismissible: DismissiblePane(onDismissed: () {
                              // we can able to perform to some action here
                            }),
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                autoClose: true,
                                flex: 1,
                                onPressed: (value) async {
                                  showDialogw(
                                    context,
                                    onConfirm: () async {
                                      // Remove the item from Firestore
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection('user_data')
                                          .doc(widget.clientId.id)
                                          .collection('calls')
                                          .doc(call[
                                              'id']) // Assuming 'id' is the document ID of each user data
                                          .delete();

                                      // Remove the item from the local list and update the UI
                                      setState(() {
                                        // users.removeAt(index);
                                        // print('deleted');
                                      });
                                    },
                                  );
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: AppLocalizations.of(context)!.delete,
                              ),
                              // SlidableAction(
                              //   autoClose: true,
                              //   flex: 1,
                              //   onPressed: (value) {
                              //         //  displayDialog(context, '${user.id}');

                              //         // showAlertDialog( context,'ASAS');
                              //           // showDialogw( context);

                              //   },
                              //   backgroundColor: Colors.blueAccent,
                              //   foregroundColor: Colors.white,
                              //   icon: Icons.edit,
                              //   label: 'Edit',
                              // ),
                            ],
                          ),
                          child: InkWell(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
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
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
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
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      height: 60,
                                      width: 0.5,
                                      color: Colors.grey[200]!.withOpacity(0.7),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (paid)
                                            Icon(Icons.done,
                                                color: Colors.green),
                                          // Text(' $sum'),
                                          if (!paid)
                                            Icon(Icons.cancel,
                                                color: Colors.red),
                                        ],
                                      ),
                                    ),
                                    
                                  ],
                                  
                                ),
                                
                              ),
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
           floatingActionButton: FloatingActionButton(
        onPressed: () async{
                         List callsData = await fetchCallsData();
                    //    exportToExcel(callsData);
          _generateCsvFile(callsData);
        },
     tooltip: 'Export to Excel', // Update tooltip to match the action
child: Row(
  
  children: [
    Icon(Icons.arrow_back),
    // SizedBox(width: 8), // Adjust the spacing between icon and text
    // Text('Export to Excel'), // Replace this text with your desired label
  ],
),

      )
    );
  }
}
