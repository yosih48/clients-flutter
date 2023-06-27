import 'package:clientsf/objects/clients.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CallsScreen extends StatelessWidget {
  final Todo clientId;

  CallsScreen({required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.callsHistory),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(clientId.id)
              .collection('calls')
              .orderBy('timestamp', descending: true)
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
