import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../componenets/alertDialog.dart';
import 'callsInfo.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../componenets/alertDialog.dart';
import 'callsInfo.dart';

class callsTodo extends StatefulWidget {
  const callsTodo({super.key});

  @override
  State<callsTodo> createState() => _callsTodoState();
}

class _callsTodoState extends State<callsTodo> {
  bool _showInProgress = false;

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.todo),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                    value: false,
                    label: Text('To Do'),
                    icon: Icon(Icons.list)),
                ButtonSegment<bool>(
                    value: true,
                    label: Text('In Progress'),
                    icon: Icon(Icons.work_history)),
              ],
              selected: <bool>{_showInProgress},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _showInProgress = newSelection.first;
                });
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
            stream: _showInProgress
                ? FirebaseFirestore.instance
                    .collectionGroup('calls')
                    .where('inProgress', isEqualTo: true)
                    .where('userRef',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collectionGroup('calls')
                    .where('done', isEqualTo: false)
                    .where('userRef',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                List callDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: callDocs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> callData =
                        callDocs[index].data() as Map<String, dynamic>;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientServiceScreen(
                                call: callData, user: callData['clientRef']),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                            child: Text(
                              callData['clientName'].isNotEmpty
                                  ? callData['clientName'][0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            callData['clientName'],
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                callData['type'],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                callData['call'],
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        _showInProgress
                            ? 'No calls in progress'
                            : 'No pending calls',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }
}
