import 'package:clientsf/datePick.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:widget_bindings/widget_bindings.dart';
import '../Constants/AppString.dart';
import '../checkbox.dart';
import '../datePick.dart';
import '../objects/clients.dart';
import '../objects/clientsCalls.dart';

const List<String> list = <String>[
  'סוג טיפול',
  'טיפול מרחוק',
  'מכירת ציוד',
  'בית הלקוח',
];

void createCall() {
  Calls callNumberOne = Calls(call: 'call one', paid: true, type: 'big');
// client.userList?.add(callNumberOne);
  print(callNumberOne);
  _callDetailsController.clear();
}

final String dropdownValue = 'gg';
final TextEditingController _textFieldController = TextEditingController();
final TextEditingController _mailFieldController = TextEditingController();
final TextEditingController _phoneFieldController = TextEditingController();
final TextEditingController _addressFieldController = TextEditingController();

class actions extends StatefulWidget {

final Todo user ;
  const actions({super.key, required this.user});
    // const actions({Key? key, required this.userId}) : super(key: key);


  @override
  State<actions> createState() => _actionsState();
}

class _actionsState extends State<actions> {


  void initState() {
    
    print(widget.user.id);
    
  }
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('חיובים'),
        ),
        // body: call(context),
        body: call(user: widget.user),
        );
  }
}

bool _checkboxValue = false;

final TextEditingController _callDetailsController = TextEditingController();

class dropdown extends StatefulWidget {
  const dropdown({super.key});

  @override
  State<dropdown> createState() => _dropdownState();
}

class _dropdownState extends State<dropdown> {
  String dropdownValue = list.first;
  // String defalutValue = 'dsds';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class call extends StatefulWidget {
final Todo user;

  const call({super.key, required this.user});
  
  @override
  State<call> createState() => _callState();
}

class _callState extends State<call> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            dropdown(),
            ElevatedButton(
              child: Text('תאריך קריאה'),
              onPressed: () {
                // Open the DatePicker in the current screen.
                // showDatePicker(
                //   context: arg,
                //   initialDate: DateTime.now(),
                //   firstDate: DateTime(2023, 1, 1),
                //   lastDate: DateTime(2023, 12, 31),
                // );
                Navigator.pushNamed(context, '/date');
              },
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Card(
                color: Colors.grey,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _callDetailsController,
                    maxLines: 8, //or null
                    decoration:
                        InputDecoration.collapsed(hintText: "תיאור טיפול"),
                  ),
                ))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Checkbox(
                    value: _checkboxValue,
                    onChanged: (newValue) {
                      print(newValue);

                      setState(() {
                        _checkboxValue = newValue!;

                        print(_checkboxValue);
                      });
                    }),
                Text(
                  AppStrings.paid,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(width: 206),
            Expanded(
              child: Container(
                width: 100,
                child: TextField(
                  decoration:
                      const InputDecoration(hintText: AppStrings.sumHour),
                  autofocus: true,
                ),
              ),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              child: Container(
                width: 20,
                child: TextField(
                  decoration:
                      const InputDecoration(hintText: AppStrings.sumHour),
                  autofocus: true,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8),
        ElevatedButton(
          child: Text('שמור'),
          onPressed: () {
            setState(() {
              print(_checkboxValue);
              addCall(widget.user, _callDetailsController.text, _checkboxValue, dropdownValue);
            });
          },
        ),
        // TextField(
        //   controller: _mailFieldController,
        //   decoration: const InputDecoration(hintText: 'Type your email'),
        //   autofocus: true,
        // ),
        // TextField(
        //   controller: _phoneFieldController,
        //   decoration: const InputDecoration(hintText: 'Type your phone number'),
        //   autofocus: true,
        // ),
        // TextField(
        //   controller: _addressFieldController,
        //   decoration: const InputDecoration(hintText: 'Type your phone address'),
        //   autofocus: true,
        // ),
      ],
    ));
    ;
  }
}

CollectionReference clients = FirebaseFirestore.instance.collection('users');
Future<void> addCall( user, call, paid, type) {
  print(user.id);
  // Call the user's CollectionReference to add a new user
  return clients
      .doc(user.id)
      .update({
        'calls': {
          'call': call,
          'paid': paid,
          'type': type,
        },
      })
      .then((value) => print("call Added"))
      .catchError((error) => print("Failed to add call: $error"));
}
