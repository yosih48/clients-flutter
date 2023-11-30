import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../componenets/tableData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_month_picker/flutter_month_picker.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../singelton/AppSingelton.dart';

class DataTableExample extends StatefulWidget {
  const DataTableExample({Key? key}) : super(key: key);

  @override
  State<DataTableExample> createState() => _DataTableExampleState();
}

class _DataTableExampleState extends State<DataTableExample> {
  final _dateC = TextEditingController(text: '1');
  final _dateCEnd = TextEditingController(text: '12');
  final _dateCyear = TextEditingController(text: '2023');
  final _dateCEndYear = TextEditingController(text: '2023');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> clientTotalPayments = {};
    Map<String, double> clientNotPaidPayments = {};
    List<DataRow> rows = [];
    DateTime selected = DateTime.now();
    DateTime initial = DateTime(1970);
    DateTime last = DateTime.now();
    Future displayDatePicker(context) async {
      var date = await showMonthPicker(
        context: context,
        initialDate: selected,
        firstDate: initial,
        lastDate: last,
      );
      if (date != null) {
        setState(() {
          // _dateC.text = date.toLocal().toString().split(" ")[0];
          String selectedDate =
              date.toLocal().toString().split(" ")[0]; // Example: "2023-11-05"

          List<String> dateParts = selectedDate
              .split("-"); // Split by "-" to get parts ["2023", "11", "05"]

          // Extract the month part and convert it to an integer
          int month = int.parse(dateParts[1]);
          int year = int.parse(dateParts[0]);
          print(year);
          // Now 'month' contains the month as an integer (e.g., 11)

          _dateC.text =
              selectedDate; // If you want to keep the full date as a string

          // or
          _dateC.text =
              month.toString(); // If you only want the month as a string
          _dateCyear.text = year.toString();
        });
      }
      print(_dateC.text);
    }

    Future displayDatePickerEnd(context) async {
      var date = await showMonthPicker(
        context: context,
        initialDate: selected,
        firstDate: initial,
        lastDate: last,
      );
      if (date != null) {
        setState(() {
          // _dateC.text = date.toLocal().toString().split(" ")[0];
          String selectedDate =
              date.toLocal().toString().split(" ")[0]; // Example: "2023-11-05"

          List<String> dateParts = selectedDate
              .split("-"); // Split by "-" to get parts ["2023", "11", "05"]

          // Extract the month part and convert it to an integer
          int month = int.parse(dateParts[1]);
          int year = int.parse(dateParts[0]);

          // Now 'month' contains the month as an integer (e.g., 11)

          _dateCEnd.text =
              selectedDate; // If you want to keep the full date as a string

          // or

          _dateCEnd.text =
              month.toString(); // If you only want the month as a string
          _dateCEndYear.text =
              year.toString(); // If you only want the year as a string
        });
      }
      print(_dateCEnd.text);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('user_data')
          .snapshots(),
      builder: (context, userDataSnapshot) {
        if (!userDataSnapshot.hasData) {
          return CircularProgressIndicator();
        }

        return FutureBuilder<void>(
          future: processUserData(userDataSnapshot.data!.docs,
              clientTotalPayments, clientNotPaidPayments, rows),
          builder: (context, snapshot) {
            print('ProcessUserData called'); // Verify if the function is called
            if (snapshot.connectionState == ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('Data Table Example'),
                ),
                //  body: DataTableWidget(rows: rows),
                body: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () => displayDatePicker(context),
                          child: const Text('מחודש:')),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_dateCyear.text}/ ${_dateC.text} '),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                          onPressed: () => displayDatePickerEnd(context),
                          child: const Text('עד חודש:')),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_dateCEndYear.text}/ ${_dateCEnd.text} '),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(children: [
                      Row(
                        children: [
                          DataTableWidget(
                              clientTotalPayments: clientTotalPayments,
                              clientNotPaidPayments: clientNotPaidPayments),
                        ],
                      ),
                    ]),
                  ),
                ]),
              );
            } else {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> processUserData(
    List<QueryDocumentSnapshot> userDataDocs,
    Map<String, double> clientTotalPayments,
    Map<String, double> clientNotPaidPayments,
    List<DataRow> rows,
  ) async {
    print(_dateC.text);
    int month = int.parse(_dateC.text);
    int monthEnd = int.parse(_dateCEnd.text);
    int year = int.parse(_dateCyear.text);
    int yearEnd = int.parse(_dateCEndYear.text);
    int startTimestamp = DateTime(year, month, 1).millisecondsSinceEpoch;
    int endTimestamp = DateTime(yearEnd, monthEnd, 31).millisecondsSinceEpoch;
    for (QueryDocumentSnapshot userDataDoc in userDataDocs) {
      String clientName =
          userDataDoc.get('name')?.toString() ?? 'Unknown Client';
      // print("Client Name: $clientName");
      // Access the 'calls' collection for each client's document
      QuerySnapshot callsSnapshot =
          await userDataDoc.reference.collection('calls').get();

      double totalPayment = 0;
      double totalNotPaidPayment = 0;
    double sumPrice = 0;

      for (QueryDocumentSnapshot callDoc in callsSnapshot.docs) {
        int documentTimestamp = callDoc['timestamp'] as int;
        bool documentPaid = callDoc['paid'];
        List productList = [];
      
        productList = callDoc['products'] as List<dynamic>;
        // print(productList);

        // print('products  ${callDoc['products']['price'].toDouble()}');
        //  double price = callDoc['products']['price'].toDouble();
        // print('Product price: $price');
        if (documentTimestamp >= startTimestamp &&
            documentTimestamp < endTimestamp) {
          totalPayment += documentPaid ? callDoc['payment'] : 0.0;
          totalNotPaidPayment += !documentPaid ? callDoc['payment'] : 0.0;
        for (var product in productList) {
          // Assuming each product is a map and has a "price" field
          double price = product['price'].toDouble();
          sumPrice += price;
          print('Product price: $price');
          print('sumPrice: $sumPrice');
        }

        }

        // totalPayment += callDoc['payment'] as double;
      }
      // Store the total payment for the client
      clientTotalPayments[clientName] = totalPayment  -sumPrice;
      clientNotPaidPayments[clientName] = totalNotPaidPayment  ;

      rows.add(DataRow(
        cells: <DataCell>[
          DataCell(Text(clientName)),
          DataCell(Text(totalPayment.toStringAsFixed(2))),
          DataCell(Text(totalNotPaidPayment.toStringAsFixed(2))),
        ],
      ));
    }
  }
}
