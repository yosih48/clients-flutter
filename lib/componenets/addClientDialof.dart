import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'alertDialog.dart';



final TextEditingController _textFieldController = TextEditingController();
final TextEditingController _mailFieldController = TextEditingController();
final TextEditingController _phoneFieldController = TextEditingController();
final TextEditingController _addressFieldController = TextEditingController();

Future<void> _displayDialog(context) async {
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
            child: const Text('Cancel'),
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
              addUser(_textFieldController.text, _mailFieldController.text,
                  _addressFieldController.text, _phoneFieldController.text);
              // _addTodoItem(_textFieldController.text,
              //     _mailFieldController.text, _addressFieldController.text);

          
            },
            child: const Text('Add user'),
          ),
        ],
      );
    },
  );
}
CollectionReference clients = FirebaseFirestore.instance.collection('users');
Future<void> addUser(name, email, address, phone) {
  String clientId = generateClientId();
  // Call the user's CollectionReference to add a new user
  print(name);
  return clients.doc(clientId).set({
    'id': clientId,
    'name': name,
    'email': email,
    'address': address,
    'phone': phone,
  })
      // .then((value) => print("User Added") )
      .then((value) {
    print("User Added");
    showToast('נשמר בהצלחה');
    _textFieldController.clear();
    _mailFieldController.clear();
    _phoneFieldController.clear();
    _addressFieldController.clear();
  }).catchError((error) => print("Failed to add user: $error"));
}
String generateClientId() {
  // Implement your logic to generate a unique client ID
  // This can be a randomly generated string, a combination of user input, or any other unique identifier generation method
  // For simplicity, we will use a timestamp-based ID in this example
  return DateTime.now().millisecondsSinceEpoch.toString();
}
