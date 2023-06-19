import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallsScreen extends StatelessWidget {
  final String clientId;

  CallsScreen({required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Calls'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(clientId)
            .collection('calls')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          }

          final calls = snapshot.data!.docs;

          return ListView.builder(
            itemCount: calls.length,
            itemBuilder: (BuildContext context, int index) {
              final call = calls[index].data() as Map<String, dynamic>;
              final callDetails = call['callDetails'];
              // final timestamp = call['timestamp'] as Timestamp;
              // final dateTime = timestamp.toDate();

              return ListTile(
                title: Text(callDetails),
                // subtitle: Text('Timestamp: $dateTime'),
              );
            },
          );
        },
      ),
    );
  }
}
