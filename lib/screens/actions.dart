import 'package:clientsf/datePick.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  bool _checkboxValue = false;

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('חיובים'),
      ),
   
      body: call(context),

    );
  }
}

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

Widget call(arg) {
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
              Navigator.pushNamed(arg, '/date');
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
//           CheckboxExample(
//  value: _checkboxValue,
//          onChanged: (newValue) {
//  print(_checkboxValue);
//                 setState(() {
//                   _checkboxValue = newValue;
//                 });
//                  print(_checkboxValue);
//          }
//           ),
          SizedBox(width: 206),
          Expanded(
            child: Container(
              width: 100,
              child: TextField(
                decoration: const InputDecoration(hintText: AppStrings.sumHour),
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
                decoration: const InputDecoration(hintText: AppStrings.sumHour),
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
   
          addCall(_callDetailsController.text, true,dropdownValue );
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
}

void setState(Null Function() param0) {
}
  CollectionReference clients = FirebaseFirestore.instance.collection('users');
  Future<void> addCall( call,paid, type) {
    print(call);
    // Call the user's CollectionReference to add a new user
    return clients
    .doc('1')
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