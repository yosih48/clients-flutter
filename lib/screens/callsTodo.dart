import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../componenets/alertDialog.dart';
import 'callsInfo.dart';

class callsTodo extends StatelessWidget {
  const callsTodo({super.key});

  @override
  Widget build(BuildContext context) {
   
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.todo),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('calls')
                .where('done', isEqualTo: false)
                    .where('userRef', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(AppLocalizations.of(context)!.loading);
              }

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                // Access the list of documents returned by the query
                List callDocs = snapshot.data!.docs;

                // You can now iterate through the call documents and extract the data
                return ListView.builder(
                  itemCount: callDocs.length,
                  itemBuilder: (context, index) {
                    // Get the data for each call
                    Map<String, dynamic> callData = callDocs[index].data();
                    print(callData);
                    // Now, you can use `callData` to display the relevant information on the screen
                    // For example, if you want to display the call's ID and title:
                    return InkWell(
       onTap: () {
                              // Handle the second option
                              // Navigator.of(context).pop();
                              // Navigator.pushNamed(context, '/actions');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClientServiceScreen(
                                      call: callData, user:callData['id']),
                                ),
                              );
                            },

                      child: Card(
                        child: ListTile(
                          leading: Text(callData['clientName']),
                          title: Text(callData['type']),
                          subtitle: Text(callData['call']),
                        ),
                      ),
                    );
                  },
                );
              } else {
                // Handle the case where there are no calls with 'done' set to false
                return Text('No calls with "done" set to false found.');
              }

              //       return Column(
              //         children: [
              //           Row(
              //             children: [
              //               SizedBox(width: 12.0),
              //               Text(
              //                 AppLocalizations.of(context)!.date,
              //                 style:
              //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              //               ),
              //               SizedBox(width: 32.0),
              //               Text(
              //                 AppLocalizations.of(context)!.callDetails,
              //                 style:
              //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              //               ),
              //               SizedBox(width: 24.0),
              //               Text(
              //                  AppLocalizations.of(context)!.amount,
              //                 style:
              //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              //               ),
              //               SizedBox(width: 48.0),
              //               Text(
              //                 AppLocalizations.of(context)!.paid,
              //                 style:
              //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              //               ),
              //             ],
              //           ),
              //           Container(
              //             margin: EdgeInsets.only(top: 16.0),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 FutureBuilder<double>(
              //                   future: fetchDataFromFirestore(),
              //                   builder: (context, snapshot) {
              //                     if (snapshot.connectionState ==
              //                         ConnectionState.waiting) {
              //                       return CircularProgressIndicator(); // Show a loading indicator while waiting for the data
              //                     }

              //                     if (snapshot.hasError) {
              //                       return Text(
              //                           'Error: ${snapshot.error}'); // Show an error message if there's an error
              //                     }

              //                     double totalPayment = snapshot.data ?? 0.0;

              //                     return Text(
              //                       '${AppLocalizations.of(context)!.ramainingBalance}:'
              //                       ' ${totalPayment.toStringAsFixed(2)}',
              //                       style: TextStyle(
              //                           fontWeight: FontWeight.bold,
              //                           fontSize: 20,
              //                           color: Colors.red),
              //                     );
              //                   },
              //                 ),
              //               ],
              //             ),
              //           ),
              //           Expanded(
              //             child: ListView.builder(
              //               itemCount: calls.length,
              //               itemBuilder: (BuildContext context, int index) {
              //                 final call = calls[index].data() as Map<String, dynamic>;
              //                 print(call['id']);
              //                 // print(call['timestamp']);
              //                 final callDetails = call['call'];
              //                 final type = call['type'];
              //                 final id = call['id'];
              //                 final paid = call['paid'];
              //                 final hour = call['hour'];
              //                 final timestamp = call['timestamp'];
              //                 final payment = call['payment'];
              //                 final formattedDate = DateFormat('dd/MM/yy').format(
              //                     DateTime.fromMillisecondsSinceEpoch(timestamp));

              //                 return Padding(
              //                   padding: const EdgeInsets.all(8.0),
              //                   child:Slidable(
              //          key: const ValueKey(0),
              //               endActionPane: ActionPane(
              //                 dismissible: DismissiblePane(onDismissed: () {
              //                   // we can able to perform to some action here
              //                 }),
              //                 motion: const DrawerMotion(),
              //                 children: [
              //                   SlidableAction(
              //                     autoClose: true,
              //                     flex: 1,
              //                                        onPressed: (value)async {

              // showDialogw(
              //     context,
              //     onConfirm: () async {
              //       // Remove the item from Firestore
              //       await FirebaseFirestore.instance
              //           .collection('users')
              //           .doc(FirebaseAuth.instance.currentUser!.uid)
              //           .collection('user_data')
              //           .doc(widget.clientId.id)
              //           .collection('calls')
              //           .doc(call['id']) // Assuming 'id' is the document ID of each user data
              //           .delete();

              //       // Remove the item from the local list and update the UI
              //       setState(() {
              //         // users.removeAt(index);
              //         // print('deleted');
              //       });
              //     },
              //   );

              //                     },
              //                     backgroundColor: Colors.red,
              //                     foregroundColor: Colors.white,
              //                     icon: Icons.delete,
              //                    label:  AppLocalizations.of(context)!.delete,
              //                   ),

              //                 ],
              //               ),

              //                     child: InkWell(
              //                       onTap: () {
              //                         // Handle the second option
              //                         // Navigator.of(context).pop();
              //                         // Navigator.pushNamed(context, '/actions');
              //                         Navigator.push(
              //                           context,
              //                           MaterialPageRoute(
              //                             builder: (context) => ClientServiceScreen(
              //                                 call: call, user: widget.clientId.id),
              //                           ),
              //                         );
              //                       },
              //                       child: Container(
              //                         // padding: EdgeInsets.symmetric(horizontal: 20),
              //                         width: MediaQuery.of(context).size.width,
              //                         margin: EdgeInsets.only(top: 12),
              //                         decoration: BoxDecoration(
              //                             // border: Border.bo(color: Colors.blueAccent)
              //                             border: Border(
              //                                 bottom: BorderSide(
              //                                     color: Colors.blueAccent,
              //                                     width: 1.0,
              //                                     style: BorderStyle.solid))),

              //                         child: Container(
              //                           // padding: EdgeInsets.all(16),
              //                           decoration: BoxDecoration(
              //                               // borderRadius: BorderRadius.circular(8),
              //                               // color: Colors.blueAccent,
              //                               ),
              //                           child: Row(
              //                             children: [
              //                               Expanded(
              //                                 child: Column(
              //                                   crossAxisAlignment:
              //                                       CrossAxisAlignment.center,
              //                                   mainAxisAlignment: MainAxisAlignment.center,
              //                                   children: [
              //                                     Text(' $formattedDate '),
              //                                     // Text(callDetails),
              //                                     SizedBox(
              //                                       height: 12,
              //                                     ),
              //                                   ],
              //                                 ),
              //                               ),
              //                               Container(
              //                                 margin: EdgeInsets.symmetric(horizontal: 10),
              //                                 height: 60,
              //                                 width: 0.5,
              //                                 color: Colors.grey[200]!.withOpacity(0.7),
              //                               ),
              //                               Expanded(
              //                                 child: Column(
              //                                   crossAxisAlignment:
              //                                       CrossAxisAlignment.center,
              //                                   children: [
              //                                     Text(callDetails),
              //                                   ],
              //                                 ),
              //                               ),
              //                               Container(
              //                                 margin: EdgeInsets.symmetric(horizontal: 10),
              //                                 height: 60,
              //                                 width: 0.5,
              //                                 color: Colors.grey[200]!.withOpacity(0.7),
              //                               ),
              //                               Expanded(
              //                                 child: Column(
              //                                   crossAxisAlignment:
              //                                       CrossAxisAlignment.center,
              //                                   children: [
              //                                     Text('  $payment'),
              //                                   ],
              //                                 ),
              //                               ),
              //                               Container(
              //                                 margin: EdgeInsets.symmetric(horizontal: 10),
              //                                 height: 60,
              //                                 width: 0.5,
              //                                 color: Colors.grey[200]!.withOpacity(0.7),
              //                               ),
              //                               Expanded(
              //                                 child: Column(
              //                                   crossAxisAlignment:
              //                                       CrossAxisAlignment.center,
              //                                   children: [
              //                                     if (paid)
              //                                       Icon(Icons.done, color: Colors.green),
              //                                     // Text(' $sum'),
              //                                     if (!paid)
              //                                       Icon(Icons.cancel, color: Colors.red),
              //                                   ],
              //                                 ),
              //                               ),
              //                             ],
              //                           ),
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                 );
              //               },
              //             ),
              //           ),
              //         ],
              // );
            }),
      ),
    );
  }
}
