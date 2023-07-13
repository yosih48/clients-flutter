import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'alertDialog.dart';

final TextEditingController _textFieldController = TextEditingController();
final TextEditingController _mailFieldController = TextEditingController();
final TextEditingController _phoneFieldController = TextEditingController();
final TextEditingController _addressFieldController = TextEditingController();

Future<void> editCallDialog(context) async {
  // print(context);
  return showDialog<void>(
    context: context,
    // T: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.clientInfo,
        ),
        // Text(AppLocalizations.of(context)!.helloWorld),
        // content: TextField(
        //   controller: _textFieldController,
        //   decoration: const InputDecoration(hintText: 'Type your todo'),
        //   autofocus: true,
        // ),
        content: Container(
          height: 300.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(AppLocalizations.of(context)!.helloWorld),

              TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  // Text(AppLocalizations.of(context)!.helloWorld),
                  labelText: 'Name',
                ),
                autofocus: true,
              ),
              TextField(
                controller: _mailFieldController,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.email),
                  hintText: 'Enter a phone email',
                  labelText: 'email',
                ),
                autofocus: true,
              ),
              TextField(
                controller: _phoneFieldController,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.phone),
                  hintText: 'Enter a phone number',
                  labelText: 'Phone',
                ),
                autofocus: true,
              ),
              TextField(
                controller: _addressFieldController,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.maps_home_work),
                  hintText: 'Enter address',
                  labelText: 'address',
                ),
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
            ),
          ),
          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //   ),
          //   onPressed: () {
          //     Navigator.of(context).pop();
          //     _addTodoItem(_textFieldController.text,
          //         _mailFieldController.text, _addressFieldController.text);
          //     print(_todos);
          //   },
          //   child: const Text('Add'),
          // ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
       
                updateUserb(
                    2,
                    _textFieldController.text,
                    _mailFieldController.text,
                    _addressFieldController.text,
                    _phoneFieldController.text);
         
            },
            child: Text(
              AppLocalizations.of(context)!.addUser,
            ),
          ),
        ],
      );
    },
  );
}

CollectionReference clients = FirebaseFirestore.instance.collection('users'); 
Future<void> updateUserb(id, name, email, address, phone) {
  print(phone);

  Map<String, dynamic> updatedData = {};

  // Update 'name' field if a new value is provided and not empty
  if (name != null && name.isNotEmpty) {
    updatedData['name'] = name;
  }

  // Update 'email' field if a new value is provided and not empty
  if (email != null && email.isNotEmpty) {
    updatedData['email'] = email;
  }

  // Update 'address' field if a new value is provided and not empty
  if (address != null && address.isNotEmpty) {
    updatedData['address'] = address;
  }

  // Update 'phone' field if a new value is provided and not empty
  if (phone != null && phone.isNotEmpty) {
    updatedData['phone'] = phone;
  }

  return clients.doc(id).update(updatedData).then((value) {
    print('User updated');
    showToast('עודכן בהצלחה');
    _textFieldController.clear();
    _mailFieldController.clear();
    _phoneFieldController.clear();
    _addressFieldController.clear();
  }).catchError((error) {
    print('Error updating user: $error');
  });
}

String generateClientId() {
  // Implement your logic to generate a unique client ID
  // This can be a randomly generated string, a combination of user input, or any other unique identifier generation method
  // For simplicity, we will use a timestamp-based ID in this example
  return DateTime.now().millisecondsSinceEpoch.toString();
}
