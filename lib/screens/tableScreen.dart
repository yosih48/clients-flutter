import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../componenets/tableData.dart';

class DataTableExample extends StatelessWidget {
  const DataTableExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double> clientTotalPayments = {};
     List<DataRow> rows = [];
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
          
            future: processUserData(userDataSnapshot.data!.docs, clientTotalPayments, rows),
          builder: (context, snapshot) {
             print('ProcessUserData called'); // Verify if the function is called
            if (snapshot.connectionState == ConnectionState.done) {
               return Scaffold(
                appBar: AppBar(
                  title: Text('Data Table Example'),
                ),
                //  body: DataTableWidget(rows: rows),
                   body: DataTableWidget(clientTotalPayments: clientTotalPayments),
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
    for (QueryDocumentSnapshot userDataDoc in userDataDocs) {
      String clientName = userDataDoc.get('name')?.toString() ?? 'Unknown Client';
      print("Client Name: $clientName");
      // Access the 'calls' collection for each client's document
      QuerySnapshot callsSnapshot = await userDataDoc.reference.collection('calls').get();

      double totalPayment = 0;

      for (QueryDocumentSnapshot callDoc in callsSnapshot.docs) {
        totalPayment += callDoc['payment'] as double;
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
