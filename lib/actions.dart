import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

const List<String> list = <String>[
  'טיפול מרחוק',
  'מכירת ציוד',
  'בית הלקוח',
  'Four'
];
final TextEditingController _textFieldController = TextEditingController();
final TextEditingController _mailFieldController = TextEditingController();
final TextEditingController _phoneFieldController = TextEditingController();
final TextEditingController _addressFieldController = TextEditingController();

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('חיובים'),
      ),
      // body: const Center(child: dropdown()),
      body: call(),
    );
  }
}

class dropdown extends StatefulWidget {
  const dropdown({super.key});

  @override
  State<dropdown> createState() => _dropdownState();
}

class _dropdownState extends State<dropdown> {
  String dropdownValue = list.first;

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

Widget call() {
  return Column(children: [
    Column(
      children: [
        TextField(
          controller: _textFieldController,
          decoration: const InputDecoration(hintText: 'תאריך'),
          autofocus: true,
        ),
        SizedBox(height: 8),
        TextField(
          controller: _mailFieldController,
          decoration: const InputDecoration(hintText: 'Type your email'),
          autofocus: true,
        ),
        TextField(
          controller: _phoneFieldController,
          decoration: const InputDecoration(hintText: 'Type your phone number'),
          autofocus: true,
        ),
        TextField(
          controller: _addressFieldController,
          decoration:
              const InputDecoration(hintText: 'Type your phone address'),
          autofocus: true,
        ),
      ],
    )
  ]);
}
