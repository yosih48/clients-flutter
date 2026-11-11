import 'package:clientsf/l10n/app_localizations.dart';
import 'package:clientsf/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'alertDialog.dart';

final TextEditingController _textFieldController = TextEditingController();
final TextEditingController _mailFieldController = TextEditingController();
final TextEditingController _phoneFieldController = TextEditingController();
final TextEditingController _addressFieldController = TextEditingController();

Future<void> displayDialog(BuildContext context, String? id) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      final loc = AppLocalizations.of(context)!;
      final theme = Theme.of(context);
      final isEdit = id != null;

      return Dialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                          isEdit
                              ? Icons.edit_rounded
                              : Icons.person_add_alt_1_rounded,
                          color: theme.colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit ? loc.editClient : loc.clientInfo,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _textFieldController,
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.person_outline_rounded),
                            labelText: loc.clientName,
                          ),
                          autofocus: true,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _mailFieldController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.mail_outline_rounded),
                            labelText: loc.email,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneFieldController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_outlined),
                            labelText: loc.phoneLabel,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _addressFieldController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.place_outlined),
                            labelText: loc.addressLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(loc.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (id != null) {
                            updateUserb(
                                id,
                                _textFieldController.text,
                                _mailFieldController.text,
                                _addressFieldController.text,
                                _phoneFieldController.text);
                          } else {
                            addUser(
                                _textFieldController.text,
                                _mailFieldController.text,
                                _addressFieldController.text,
                                _phoneFieldController.text);
                          }
                        },
                        child: Text(isEdit ? loc.edit : loc.addUser),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

CollectionReference clients = FirebaseFirestore.instance.collection('users');

Future<void> addUser(name, email, address, phone) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userCollection =
        FirebaseFirestore.instance.collection('users');
    final userDoc =
        userCollection.doc(user.uid).collection('user_data').doc();

    try {
      await userDoc.set({
        'name': name,
        'email': email,
        'address': address,
        'phone': phone,
      });

      showToast('נשמר בהצלחה');
      _textFieldController.clear();
      _mailFieldController.clear();
      _phoneFieldController.clear();
      _addressFieldController.clear();
    } catch (error) {
      debugPrint("Failed to add user data to Firestore: $error");
    }
  }
}

Future<void> updateUserb(id, name, email, address, phone) {
  final user = FirebaseAuth.instance.currentUser;
  final Map<String, dynamic> updatedData = {};
  if (name != null && name.isNotEmpty) updatedData['name'] = name;
  if (email != null && email.isNotEmpty) updatedData['email'] = email;
  if (address != null && address.isNotEmpty) updatedData['address'] = address;
  if (phone != null && phone.isNotEmpty) updatedData['phone'] = phone;

  final clientRef = clients.doc(user!.uid).collection('user_data').doc(id);
  return clientRef
      .update(updatedData)
      .then((_) => _syncClientNameOnCalls(clientRef, updatedData['name']))
      .then((value) {
    showToast('עודכן בהצלחה');
    _textFieldController.clear();
    _mailFieldController.clear();
    _phoneFieldController.clear();
    _addressFieldController.clear();
  }).catchError((error) {
    debugPrint('Error updating user: $error');
  });
}

/// Calls keep a copy of the client's name (shown on the todo screen), so a
/// rename has to be copied onto every call of that client.
Future<void> _syncClientNameOnCalls(
    DocumentReference clientRef, String? name) async {
  if (name == null) return;
  final calls = await clientRef.collection('calls').get();
  const chunk = 450; // a batch holds at most 500 writes
  for (var i = 0; i < calls.docs.length; i += chunk) {
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in calls.docs.skip(i).take(chunk)) {
      if (doc.data()['clientName'] != name) {
        batch.update(doc.reference, {'clientName': name});
      }
    }
    await batch.commit();
  }
}

String generateClientId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}
