import 'package:clientsf/objects/clients.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class CallsScreen extends StatelessWidget {
  final Todo clientId;
   
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
            .doc(clientId.id)
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

              // );
return Container(
  padding: EdgeInsets.symmetric(horizontal: 20),
  width: MediaQuery.of(context).size.width,
  margin: EdgeInsets.only(bottom: 12),
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      // borderRadius: BorderRadius.circular(8),
      color: Colors.blueAccent,
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('dssssssssssssssssssdsdsdssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Text('תאריך קריאה: $formattedDate '),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Text(' תשלום: $payment'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('שולם: $paid'),
            ],
          ),
        ),
      ],
    ),
  ),
);
            },
          );
        },
      ),
    );
  }
}
 