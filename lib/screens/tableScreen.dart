import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../componenets/datePick.dart';
import '../componenets/datePicker.dart';
import '../componenets/tableData.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class DataTableExample extends StatefulWidget {
  const DataTableExample({Key? key}) : super(key: key);

  @override
  State<DataTableExample> createState() => _DataTableExampleState();
}

class _DataTableExampleState extends State<DataTableExample> {

  final _dateC = TextEditingController(text:'1');

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> clientTotalPayments = {};
    List<DataRow> rows = [];
    DateTime selected = DateTime.now();
    DateTime initial = DateTime(1970);
    DateTime last = DateTime.now();

    Future displayDatePicker(context) async {
      var date = await showDatePicker(
        context: context,
        initialDate: selected,
        firstDate: initial,
        lastDate: last,
      );
      if (date != null) {
        setState(() {
          // _dateC.text = date.toLocal().toString().split(" ")[0];
          String selectedDate =
              date.toLocal().toString().split(" ")[0]; // Example: "2023-11-05"

          List<String> dateParts = selectedDate
              .split("-"); // Split by "-" to get parts ["2023", "11", "05"]

          // Extract the month part and convert it to an integer
          int month = int.parse(dateParts[1]);

          // Now 'month' contains the month as an integer (e.g., 11)

          _dateC.text =
              selectedDate; // If you want to keep the full date as a string

          // or

          _dateC.text =
              month.toString(); // If you only want the month as a string
        });
      }
      print(_dateC.text);
    }
//  Future<void> displayDatePicker(BuildContext context) async {
//       DateTime currentDate = DateTime.now();
//       DateTime? selectedDate = await showDatePicker(
//         context: context,
//         initialDate: currentDate,
//         firstDate: DateTime(currentDate.year - 1, 1),
//         lastDate: DateTime(currentDate.year + 1, 12),
//         builder: (BuildContext context, Widget? child) {
//           return Theme(
//             data: ThemeData.light().copyWith(
//               primaryColor:
//                   Colors.blue, // Change the primary color to your preference
//               accentColor:
//                   Colors.blue, // Change the accent color to your preference
//               colorScheme: ColorScheme.light(primary: Colors.blue),
//               buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
//             ),
//             child: child!,
//           );
//         },
//       );

//       if (selectedDate != null) {
//         setState(() {
//           // Format the selected date to display only the month and year
//           String formattedDate = DateFormat.yMMM().format(selectedDate);
//           _dateC.text = formattedDate;
//         });
//         print(_dateC.text);
//       }
//     }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('user_data')
          .snapshots(),
      builder: (context, userDataSnapshot) {
        if (!userDataSnapshot.hasData) {
          return CircularProgressIndicator();
        }

        return FutureBuilder<void>(
          future: processUserData(
              userDataSnapshot.data!.docs, clientTotalPayments, rows),
          builder: (context, snapshot) {
            print('ProcessUserData called'); // Verify if the function is called
            if (snapshot.connectionState == ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('Data Table Example'),
                ),
                //  body: DataTableWidget(rows: rows),
                body: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () => displayDatePicker(context),
                          child: const Text('date pick')),
                          SizedBox(width: 8),
                          
Text('חודש:'),
                      SizedBox(width: 5),
SizedBox(
  width: 80,
  height: 40,
  child: TextFormField(
  
    controller: _dateC,
  
    decoration: const InputDecoration(
  
      // labelText: 'date picker',
  
      border: OutlineInputBorder()
  
    ),
     enabled: false,
  
  ),
),

                    ],

                  ),
                  Row(
                    children: [
                      DataTableWidget(clientTotalPayments: clientTotalPayments),
                    ],
                  ),
                ]),
              );
            } else {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> processUserData(
    List<QueryDocumentSnapshot> userDataDocs,
    Map<String, double> clientTotalPayments,
    List<DataRow> rows,
  ) async {
    print(_dateC.text);
    int month = int.parse(_dateC.text);
    int startTimestamp = DateTime(2023, month  , 1).millisecondsSinceEpoch;
    int endTimestamp = DateTime(2023, 12, 1).millisecondsSinceEpoch;

    for (QueryDocumentSnapshot userDataDoc in userDataDocs) {
      String clientName =
          userDataDoc.get('name')?.toString() ?? 'Unknown Client';
      print("Client Name: $clientName");
      // Access the 'calls' collection for each client's document
      QuerySnapshot callsSnapshot =
          await userDataDoc.reference.collection('calls').get();

      double totalPayment = 0;

      for (QueryDocumentSnapshot callDoc in callsSnapshot.docs) {
        int documentTimestamp = callDoc['timestamp'] as int;
        if (documentTimestamp >= startTimestamp &&
            documentTimestamp < endTimestamp) {
          // Add the payment to totalPayment
          totalPayment += callDoc['payment'] as double;
        }
        // totalPayment += callDoc['payment'] as double;
      }
      // Store the total payment for the client
      clientTotalPayments[clientName] = totalPayment;

      // print(totalPayment);
      // print(clientTotalPayments);

      rows.add(DataRow(
        cells: <DataCell>[
          DataCell(Text(clientName)),
          DataCell(Text(totalPayment.toStringAsFixed(2))),
        ],
      ));
    }
  }
}
