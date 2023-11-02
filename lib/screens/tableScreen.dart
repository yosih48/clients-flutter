import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataTableExample extends StatelessWidget {
  const DataTableExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          future: processUserData(userDataSnapshot.data!.docs),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // return _buildDataTable();
              return CircularProgressIndicator();
            } else {
              return CircularProgressIndicator();
            }
          },
        );
      },
    );
  }

  Future<void> processUserData(List<QueryDocumentSnapshot> userDataDocs) async {
    // Define a map to store total payments for each client
    Map<String, double> clientTotalPayments = {};

    for (QueryDocumentSnapshot userDataDoc in userDataDocs) {
      // Print the entire document
      print("userDataDoc: $userDataDoc");

      // Print the document data as a Map
      print("userDataDoc data: ${userDataDoc.data()}");
      String clientName =
          userDataDoc.get('name')?.toString() ?? 'Unknown Client';
      print("Client Name: $clientName");
      // Access the 'calls' collection for each client's document
      QuerySnapshot callsSnapshot =
          await userDataDoc.reference.collection('calls').get();

      double totalPayment = 0;

      for (QueryDocumentSnapshot callDoc in callsSnapshot.docs) {
        totalPayment += callDoc['payment'] as double;
      }
      print(totalPayment);
      // Store the total payment for the client
      clientTotalPayments[clientName] = totalPayment;
    }

    // You can use clientTotalPayments for further processing or display
  }

  // Widget _buildDataTable() {
  //   // Build and return the DataTable widget here
  //   // You can use the data from processUserData to populate the table
  // }
}
