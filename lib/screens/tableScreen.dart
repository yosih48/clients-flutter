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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

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

  Map<String, double> clientTotalPayments = {};
  Map<String, double> clientNotPaidPayments = {};
  List<DataRow> rows = [];

  DateTime selected = DateTime.now();
  DateTime initial = DateTime(1970);
  DateTime last = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    int startTimestamp =
        DateTime(int.parse(_dateCyear.text), int.parse(_dateC.text), 1)
            .millisecondsSinceEpoch;
    int endTimestamp =
        DateTime(int.parse(_dateCEndYear.text), int.parse(_dateCEnd.text), 31)
            .millisecondsSinceEpoch;

    QuerySnapshot userDataSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_data')
        .get();

    await processUserData(userDataSnapshot.docs, startTimestamp, endTimestamp);
    setState(() {});
  }

  Future<void> processUserData(
    List<QueryDocumentSnapshot> userDataDocs,
    int startTimestamp,
    int endTimestamp,
  ) async {
    clientTotalPayments.clear();
    clientNotPaidPayments.clear();
    rows.clear();

    for (QueryDocumentSnapshot userDataDoc in userDataDocs) {
      String clientName =
          userDataDoc.get('name')?.toString() ?? 'Unknown Client';

      QuerySnapshot callsSnapshot = await userDataDoc.reference
          .collection('calls')
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThan: endTimestamp)
          .get();

      double totalPayment = 0;
      double totalNotPaidPayment = 0;
      double sumPrice = 0;

      for (QueryDocumentSnapshot callDoc in callsSnapshot.docs) {
        bool documentPaid = callDoc['paid'];
        List productList = callDoc['products'] as List<dynamic>;

        totalPayment += documentPaid ? callDoc['payment'] : 0.0;
        totalNotPaidPayment += !documentPaid ? callDoc['payment'] : 0.0;

        for (var product in productList) {
          sumPrice += product['price'].toDouble();
        }
      }

      clientTotalPayments[clientName] = totalPayment - sumPrice;
      clientNotPaidPayments[clientName] = totalNotPaidPayment;

      rows.add(DataRow(
        cells: <DataCell>[
          DataCell(Text(clientName)),
          DataCell(Text(totalPayment.toStringAsFixed(2))),
          DataCell(Text(totalNotPaidPayment.toStringAsFixed(2))),
        ],
      ));
    }
  }

  Future<void> displayDatePicker(BuildContext context, bool isEndDate) async {
    var date = await showMonthPicker(
      context: context,
      initialDate: selected,
      firstDate: initial,
      lastDate: last,
    );

    if (date != null) {
      setState(() {
        String selectedDate = date.toLocal().toString().split(" ")[0];
        List<String> dateParts = selectedDate.split("-");
        int month = int.parse(dateParts[1]);
        int year = int.parse(dateParts[0]);

        if (isEndDate) {
          _dateCEnd.text = month.toString();
          _dateCEndYear.text = year.toString();
        } else {
          _dateC.text = month.toString();
          _dateCyear.text = year.toString();
        }
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Table Example'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => displayDatePicker(context, false),
                child: const Text('מחודש:'),
              ),
              SizedBox(width: 8),
              Text('${_dateCyear.text}/ ${_dateC.text} '),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => displayDatePicker(context, true),
                child: const Text('עד חודש:'),
              ),
              SizedBox(width: 8),
              Text('${_dateCEndYear.text}/ ${_dateCEnd.text} '),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                DataTableWidget(
                  clientTotalPayments: clientTotalPayments,
                  clientNotPaidPayments: clientNotPaidPayments,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
