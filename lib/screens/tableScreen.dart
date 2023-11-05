import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../componenets/datePick.dart';
import '../componenets/datePicker.dart';
import '../componenets/tableData.dart';

class DataTableExample extends StatefulWidget {
  const DataTableExample({Key? key}) : super(key: key);

  @override
  State<DataTableExample> createState() => _DataTableExampleState();
}

class _DataTableExampleState extends State<DataTableExample> {
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    dateController.text = ""; //set the initial value of text field
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> clientTotalPayments = {};
    List<DataRow> rows = [];
    DateTime selected = DateTime.now();
    DateTime initial = DateTime(1970);
    DateTime last = DateTime.now();
    final _dateC = TextEditingController();
    Future displayDatePicker(context) async {
      var date = await showDatePicker(
        context: context,
        initialDate: selected,
        firstDate: initial,
        lastDate: last,
      );
      if (date != null) {
        setState(() {
          _dateC.text = date.toLocal().toString().split(" ")[0];
        });
      }
      print(_dateC.text);
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
          future: processUserData(
              userDataSnapshot.data!.docs, clientTotalPayments, rows),
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
                    children: [
                      ElevatedButton(
                          onPressed: () => displayDatePicker(context),
                          child: const Text('date pick'))
                    ],
                  ),
                  Row(
                    children: [
                      DataTableWidget(clientTotalPayments: clientTotalPayments),
                    ],
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
    List<DataRow> rows,
  ) async {
    int startTimestamp = DateTime(2023, 10, 1).millisecondsSinceEpoch;
    int endTimestamp = DateTime(2023, 12, 1).millisecondsSinceEpoch;

    for (QueryDocumentSnapshot userDataDoc in userDataDocs) {
      String clientName =
          userDataDoc.get('name')?.toString() ?? 'Unknown Client';
      print("Client Name: $clientName");
      // Access the 'calls' collection for each client's document
      QuerySnapshot callsSnapshot =
          await userDataDoc.reference.collection('calls').get();

      double totalPayment = 0;

      for (QueryDocumentSnapshot callDoc in callsSnapshot.docs) {
        int documentTimestamp = callDoc['timestamp'] as int;
        if (documentTimestamp >= startTimestamp &&
            documentTimestamp < endTimestamp) {
          // Add the payment to totalPayment
          totalPayment += callDoc['payment'] as double;
        }
        // totalPayment += callDoc['payment'] as double;
      }
      // Store the total payment for the client
      clientTotalPayments[clientName] = totalPayment;

      // print(totalPayment);
      // print(clientTotalPayments);

      rows.add(DataRow(
        cells: <DataCell>[
          DataCell(Text(clientName)),
          DataCell(Text(totalPayment.toStringAsFixed(2))),
        ],
      ));
    }
  }
}
