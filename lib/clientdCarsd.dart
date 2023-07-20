import 'package:clientsf/screens/clientCalls.dart';
import 'package:clientsf/screens/clientInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Constants/AppString.dart';
import 'objects/clients.dart';
import 'screens/actions.dart';
import 'screens/callsinfo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class UserListView extends StatefulWidget {
  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!
                .uid) // Fetch the authenticated user's document
            .collection('user_data') // Fetch the user-specific collection
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text(AppLocalizations.of(context)!.loading);
          }
          //     final Map<String, dynamic> userData = snapshot.data!.data()!;
          // final List<Todo> todos = userData.entries.map((entry) {
          //   final Map<String, dynamic> data =
          //       entry.value as Map<String, dynamic>;
          //   return Todo(
          //     id: entry.key,
          //     name: data['name'],
          //     email: data['email'],
          //     address: data['address'],
          //     phone: data['phone'],
          //     completed: false,
          //   );
          // }).toList();

          final List users =
              snapshot.data!.docs.map((QueryDocumentSnapshot doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Todo(
              id: doc.id,
              name: data['name'],
              email: data['email'],
              address: data['address'],
              phone: data['phone'],
              completed: false,
            );
          }).toList();

          return ListTileTheme(
            contentPadding: const EdgeInsets.all(15),
            iconColor: Colors.blue[500],
            textColor: Colors.black,
            tileColor: Colors.cyan[100],
            style: ListTileStyle.list,
            dense: true,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                final user = users[index];
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
                                             onPressed: (value)async {
                        // Remove the item from Firestore
  await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('user_data')
      .doc(user.id) // Assuming 'id' is the document ID of each user data
      .delete();

  // Remove the item from the local list and update the UI
  setState(() {
    users.removeAt(index);
    print('deleted');
  });
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          autoClose: true,
                          flex: 1,
                          onPressed: (value) {
                        // Remove the item from Firestore
  // await FirebaseFirestore.instance
  //     .collection('users')
  //     .doc(FirebaseAuth.instance.currentUser!.uid)
  //     .collection('user_data')
  //     .doc(user.id) // Assuming 'id' is the document ID of each user data
  //     .delete();

  // // Remove the item from the local list and update the UI
  // setState(() {
  //   users.removeAt(index);
  //   print('deleted');
  // });
                          },
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    child: Center(
                            child: Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title:
                          Text(user.name, style: TextStyle(fontSize: 15.0)),
                      subtitle: Text('${user.phone}',
                          style: TextStyle(fontSize: 15.0)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => clientInfo(
                                      user: user,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.info)),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => actions(
                                      user: user,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_box)),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CallsScreen(clientId: user),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.history)),
                          // icon: const Icon(Icons.history)),
                          // ElevatedButton(
                          //   child: Text(AppLocalizations.of(context)!.clientInfo),
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => clientInfo(
                          //           user: user,
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                          SizedBox(width: 8),
                          // ElevatedButton(
                          //   child: Text(AppLocalizations.of(context)!.openTicket),
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => actions(
                          //           user: user,
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                        ],
                      ),
                    )),
                    ),
                  ),
                );



                // return GestureDetector(
                //   // onLongPress: () {
                //   //   showDialog(
                //   //     context: context,
                //   //     builder: (BuildContext context) {
                //   //       return AlertDialog(
                //   //         title: Text(
                //   //           AppLocalizations.of(context)!.options,
                //   //         ),
                //   //         content: Column(
                //   //           mainAxisSize: MainAxisSize.min,
                //   //           crossAxisAlignment: CrossAxisAlignment.start,
                //   //           children: [
                //   //             InkWell(
                //   //               onTap: () {
                //   //                 // Handle the first option
                //   //                 Navigator.of(context).pop();
                //   //                 Navigator.push(
                //   //                   context,
                //   //                   MaterialPageRoute(
                //   //                     builder: (context) =>
                //   //                         CallsScreen(clientId: user),
                //   //                   ),
                //   //                 );
                //   //               },
                //   //               child: Padding(
                //   //                 padding: EdgeInsets.symmetric(vertical: 8.0),
                //   //                 child: Text(AppLocalizations.of(context)!
                //   //                     .clientHistory),
                //   //               ),
                //   //             ),
                //   //             // InkWell(
                //   //             //   onTap: () {
                //   //             //     // Handle the second option
                //   //             //     // Navigator.of(context).pop();
                //   //             //     // Navigator.pushNamed(context, '/actions');
                //   //             //            Navigator.push(
                //   //             //       context,
                //   //             //       MaterialPageRoute(
                //   //             //         builder: (context) =>  ClientServiceScreen(

                //   //             //         ),
                //   //             //       ),
                //   //             //     );
                //   //             //   },
                //   //             //   child: Padding(
                //   //             //     padding: EdgeInsets.symmetric(vertical: 8.0),
                //   //             //     child: Text('יתרת חובה'),
                //   //             //   ),
                //   //             // ),
                //   //           ],
                //   //         ),
                //   //       );
                //   //     },
                //   //   );
                //   // },
                //   // style 1
                //   child: Card(
                //       margin: const EdgeInsets.all(10),
                //       child: ListTile(
                //         title:
                //             Text(user.name, style: TextStyle(fontSize: 15.0)),
                //         subtitle: Text('${user.phone}',
                //             style: TextStyle(fontSize: 15.0)),
                //         trailing: Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             IconButton(
                //                 onPressed: () {
                //                   Navigator.push(
                //                     context,
                //                     MaterialPageRoute(
                //                       builder: (context) => clientInfo(
                //                         user: user,
                //                       ),
                //                     ),
                //                   );
                //                 },
                //                 icon: const Icon(Icons.info)),
                //             IconButton(
                //                 onPressed: () {
                //                   Navigator.push(
                //                     context,
                //                     MaterialPageRoute(
                //                       builder: (context) => actions(
                //                         user: user,
                //                       ),
                //                     ),
                //                   );
                //                 },
                //                 icon: const Icon(Icons.add_box)),
                //             IconButton(
                //                 onPressed: () {
                //                   Navigator.push(
                //                     context,
                //                     MaterialPageRoute(
                //                       builder: (context) =>
                //                           CallsScreen(clientId: user),
                //                     ),
                //                   );
                //                 },
                //                 icon: const Icon(Icons.history)),
                //             // icon: const Icon(Icons.history)),
                //             // ElevatedButton(
                //             //   child: Text(AppLocalizations.of(context)!.clientInfo),
                //             //   onPressed: () {
                //             //     Navigator.push(
                //             //       context,
                //             //       MaterialPageRoute(
                //             //         builder: (context) => clientInfo(
                //             //           user: user,
                //             //         ),
                //             //       ),
                //             //     );
                //             //   },
                //             // ),
                //             SizedBox(width: 8),
                //             // ElevatedButton(
                //             //   child: Text(AppLocalizations.of(context)!.openTicket),
                //             //   onPressed: () {
                //             //     Navigator.push(
                //             //       context,
                //             //       MaterialPageRoute(
                //             //         builder: (context) => actions(
                //             //           user: user,
                //             //         ),
                //             //       ),
                //             //     );
                //             //   },
                //             // ),
                //           ],
                //         ),
                //       )),
                //   //             // style 2
                //   //             child: Card(
                //   //   child: Padding(
                //   //     padding: const EdgeInsets.all(16.0),
                //   //     child: Column(
                //   //       crossAxisAlignment: CrossAxisAlignment.start,
                //   //       children: [
                //   //         Text(
                //   //           user.name,
                //   //           style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                //   //         ),
                //   //         Text(
                //   //           '${user.phone}',
                //   //           style: TextStyle(fontSize: 16.0),
                //   //         ),
                //   //         Row(
                //   //           mainAxisSize: MainAxisSize.min,
                //   //           children: [
                //   //             ElevatedButton(
                //   //               child: Text(AppLocalizations.of(context)!.clientInfo),
                //   //               onPressed: () {
                //   //                 Navigator.push(
                //   //                   context,
                //   //                   MaterialPageRoute(
                //   //                     builder: (context) => clientInfo(
                //   //                       user: user,
                //   //                     ),
                //   //                   ),
                //   //                 );
                //   //               },
                //   //             ),
                //   //             SizedBox(width: 8),
                //   //             ElevatedButton(
                //   //               child: Text(AppLocalizations.of(context)!.openTicket),
                //   //               onPressed: () {
                //   //                 Navigator.push(
                //   //                   context,
                //   //                   MaterialPageRoute(
                //   //                     builder: (context) => actions(
                //   //                       user: user,
                //   //                     ),
                //   //                   ),
                //   //                 );
                //   //               },
                //   //             ),
                //   //           ],
                //   //         ),
                //   //       ],
                //   //     ),
                //   //   ),
                //   // ),
                // );
              },
            ),
          );
        },
      ),
    );
  }
}
