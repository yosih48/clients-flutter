import 'package:clientsf/screens/clientCalls.dart';
import 'package:clientsf/screens/clientInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import 'Constants/AppString.dart';
import 'componenets/addClientDialof.dart';
import 'componenets/alertDialog.dart';
import 'objects/clients.dart';
import 'screens/actions.dart';
import 'screens/callsinfo.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class UserListView extends StatefulWidget {


  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  String searchQuery = '';
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.searchcustomer,
                prefixIcon: Icon(Icons.search),
                // Border and styles are inherited from the global Theme
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('user_data')
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final List users = snapshot.data!.docs.map((QueryDocumentSnapshot doc) {
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

                final filteredUsers = users.where((user) {
                  return user.name.toLowerCase().contains(searchQuery) ||
                      user.email.toLowerCase().contains(searchQuery) ||
                      user.phone.toLowerCase().contains(searchQuery) ||
                      user.address.toLowerCase().contains(searchQuery);
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final user = filteredUsers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Slidable(
                        key: ValueKey(user.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                showDialogw(
                                  context,
                                  onConfirm: () async {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth.instance.currentUser!.uid)
                                        .collection('user_data')
                                        .doc(user.id)
                                        .delete();
                                    setState(() {
                                      // users.removeAt(index); // StreamBuilder handles updates
                                    });
                                  },
                                );
                              },
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: AppLocalizations.of(context)!.delete,
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                displayDialog(context, '${user.id}');
                              },
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: AppLocalizations.of(context)!.edit,
                              borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                            ),
                          ],
                        ),
                        child: Card(
                          margin: EdgeInsets.zero, // Managed by ListView padding
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  child: Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  user.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (user.phone != null && user.phone.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.phone, size: 14, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(user.phone, style: Theme.of(context).textTheme.bodyMedium),
                                          ],
                                        ),
                                      ),
                                    if (user.address != null && user.address.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on, size: 14, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                user.address,
                                                style: Theme.of(context).textTheme.bodyMedium,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: [
                                    TextButton.icon(
                                      icon: Icon(Icons.info_outline, size: 18),
                                      label: Text(AppLocalizations.of(context)!.clientInfo),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => clientInfo(user: user),
                                          ),
                                        );
                                      },
                                    ),
                                    TextButton.icon(
                                      icon: Icon(Icons.history, size: 18),
                                      label: Text("History"), // Localize if possible
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CallsScreen(clientId: user),
                                          ),
                                        );
                                      },
                                    ),
                                    FilledButton.icon( // Use FilledButton for primary action if available, or ElevatedButton
                                      icon: Icon(Icons.add, size: 18),
                                      label: Text(AppLocalizations.of(context)!.openTicket),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => actions(user: user),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
