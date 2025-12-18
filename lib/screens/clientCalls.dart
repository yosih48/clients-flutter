import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';

import 'package:clientsf/objects/clients.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import '../componenets/alertDialog.dart';
import '../componenets/dialogFilter.dart';
import 'callsInfo.dart';

class CallsScreen extends StatefulWidget {
  final Todo clientId;
  CallsScreen({required this.clientId});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  ValueNotifier<String?> _selectedCharacterNotifier =
      ValueNotifier<String?>('both');
  bool _isDescending = true;

  Future<double> fetchDataFromFirestore() async {
    // Reference to the collection in Firestore
    CollectionReference collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_data')
        .doc(widget.clientId.id)
        .collection('calls');

    // Get the documents from the collection
    QuerySnapshot querySnapshot = await collectionRef.get();
    double totalPayment = querySnapshot.docs.fold(0,
        (double previousValue, QueryDocumentSnapshot<Object?> element) {
      final payment = element['payment'];
      final paid = element['paid'];

      return previousValue +
          (paid == false && payment != null ? payment.toDouble() : 0);
    });

    return totalPayment;
  }

  bool? _getFilterValue() {
    if (_selectedCharacterNotifier.value == 'paid') {
      return true;
    } else if (_selectedCharacterNotifier.value == 'notpaid') {
      return false;
    } else {
      return null;
    }
  }

  @override
  Future<List<dynamic>> fetchCallsData() async {
    CollectionReference callsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_data')
        .doc(widget.clientId.id)
        .collection('calls');

    QuerySnapshot querySnapshot = await callsCollection.get();
    List<dynamic> callsData =
        querySnapshot.docs.map((doc) => doc.data()).toList();
    return callsData;
  }

  void _generateCsvFile(List<dynamic> data) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    List<List<dynamic>> rows = [];

    List<dynamic> headerRow = [
      "מספר קריאה",
      "תיאור קריאה",
      "שעות עבודה",
      "לתשלום",
      "שולם",
    ];
    rows.add(headerRow);
    for (int i = 0; i < data.length; i++) {
      List<dynamic> row = [];
      row.add(i + 1);
      row.add(data[i]["call"]);
      row.add(data[i]["hour"]);
      row.add(data[i]["payment"]);
      row.add(data[i]["paid"]);
      rows.add(row);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Export Complete'),
          content: Text('Data has been exported to Excel.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    _selectedCharacterNotifier.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getCallsStream() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_data')
        .doc(widget.clientId.id)
        .collection('calls');

    if (_selectedCharacterNotifier.value != 'both') {
      query = query.where('paid', isEqualTo: _getFilterValue());
    }

    return query.orderBy('timestamp', descending: _isDescending).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    String? clientName = widget.clientId.name;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.callsHistory),
            Text(
              clientName!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.8),
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isDescending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: () {
              setState(() {
                _isDescending = !_isDescending;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCharacterNotifier.value,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.filtering,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: [
                DropdownMenuItem(
                  value: 'both',
                  child: Text('ללא סינון'),
                ),
                DropdownMenuItem(
                  value: 'paid',
                  child: Text('שולם'),
                ),
                DropdownMenuItem(
                  value: 'notpaid',
                  child: Text('לא שולם'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCharacterNotifier.value = value;
                });
              },
            ),
          ),
          // Total Balance Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.ramainingBalance,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SizedBox(height: 8),
                FutureBuilder<double>(
                  future: fetchDataFromFirestore(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text('Error');
                    }

                    double totalPayment = snapshot.data ?? 0.0;

                    return Text(
                      '${totalPayment.toStringAsFixed(2)} ₪',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Calls List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getCallsStream(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final calls = snapshot.data!.docs;

                if (calls.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No calls found',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: calls.length,
                  itemBuilder: (BuildContext context, int index) {
                    final call = calls[index].data() as Map<String, dynamic>;
                    final callDetails = call['call'] ?? '';
                    final paid = call['paid'] ?? false;
                    final timestamp = call['timestamp'];
                    final payment = call['payment'];
                    final formattedDate = timestamp != null
                        ? DateFormat('dd/MM/yy').format(
                            DateTime.fromMillisecondsSinceEpoch(timestamp))
                        : 'N/A';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Slidable(
                        key: ValueKey(call['id']),
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
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .collection('user_data')
                                        .doc(widget.clientId.id)
                                        .collection('calls')
                                        .doc(call['id'])
                                        .delete();
                                  },
                                );
                              },
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: AppLocalizations.of(context)!.delete,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClientServiceScreen(
                                    call: call, user: widget.clientId.id),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Date Column
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      SizedBox(height: 4),
                                      Icon(
                                        paid
                                            ? Icons.check_circle
                                            : Icons.pending,
                                        color:
                                            paid ? Colors.green : Colors.orange,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 16),
                                  // Details Column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          callDetails,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // Payment Column
                                  Text(
                                    '$payment ₪',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                ],
                              ),
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          List callsData = await fetchCallsData();
          _generateCsvFile(callsData);
        },
        icon: Icon(Icons.file_download),
        label: Text('Export'),
      ),
    );
  }
}
