import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';

// class RadioButtonExample extends StatefulWidget {
//   final Function(String) onOptionSelected;

//   RadioButtonExample({required this.onOptionSelected});
//   @override
//   _RadioButtonExampleState createState() => _RadioButtonExampleState();
// }

// class _RadioButtonExampleState extends State<RadioButtonExample> {
//   // Variable to hold the selected value
//   late String selectedOption;

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('Select an Option'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ListTile(
//                     title: Text('Option 1'),
//                     leading: Radio(
//                       value: 'Option 1',
//                       groupValue: selectedOption,
//                       onChanged: (value) {
//                         setState(() {
//                           selectedOption = value!;
//                         });
//                       },
//                     ),
//                   ),
//                   ListTile(
//                     title: Text('Option 2'),
//                     leading: Radio(
//                       value: 'Option 2',
//                       groupValue: selectedOption,
//                       onChanged: (value) {
//                         setState(() {
//                           selectedOption = value!;
//                         });
//                       },
//                     ),
//                   ),
//                   ListTile(
//                     title: Text('Option 3'),
//                     leading: Radio(
//                       value: 'Option 3',
//                       groupValue: selectedOption,
//                       onChanged: (value) {
//                         setState(() {
//                           selectedOption = value!;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 ElevatedButton(
//                   child: Text('OK'),
//                   onPressed: () {
//                     // Pass the selected option back to the main screen
//                     widget.onOptionSelected(selectedOption);
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//       child: Text('Show Dialog'),
//     );
//   }
// }



  late final Function(String) onOptionSelected;
  late String selectedOption;

Future<void> filterDialog(context) async {
  // print(context);
  return showDialog<void>(
    context: context,
    // T: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select an Option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('קריאות ששולמו'),
              leading: Radio(
                value: 'Option 1',
                groupValue: selectedOption,
                onChanged: (value) {
                  // setState(() {
                  // selectedOption = value!;
                  // });
                },
              ),
            ),
            ListTile(
              title: Text('Option 2'),
              leading: Radio(
                value: 'Option 2',
                groupValue: selectedOption,
                onChanged: (value) {
                  // setState(() {
                  // selectedOption = value!;
                  // });
                },
              ),
            ),
            ListTile(
              title: Text('Option 3'),
              leading: Radio(
                value: 'Option 3',
                groupValue: selectedOption,
                onChanged: (value) {
                  // setState(() {
                  // selectedOption = value!;
                  // });
                },
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              // Do something with the selected option
              print('Selected Option: $selectedOption');
              Navigator.of(context).pop(selectedOption);
            },
          ),
        ],
      );
    },
  );
}
