// import 'package:clientsf/datePick.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../Constants/AppString.dart';
import '../componenets/alertDialog.dart';
import '../componenets/parts.dart';
import '../objects/clients.dart';

// void createCall() {
//   Calls callNumberOne = Calls(call: 'call one', paid: true, type: 'big');
// // client.userList?.add(callNumberOne);
//   print(callNumberOne);
//   _callDetailsController.clear();
// }

final TextEditingController _textFieldController = TextEditingController();
final TextEditingController _mailFieldController = TextEditingController();
final TextEditingController _phoneFieldController = TextEditingController();
final TextEditingController _addressFieldController = TextEditingController();

const List<String> list = <String>[
  'סוג טיפול',
  'טיפול מרחוק',
  'מכירת ציוד',
  'בית הלקוח',
];

class actions extends StatefulWidget {
  final Todo user;
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
final TextEditingController paimentController = TextEditingController();
// old time method:
// final TextEditingController timeController = TextEditingController();
// final TextEditingController minuteController = TextEditingController();

int getSumHourValue() {
  int sumHourValue = 0;

  String sumHourString = paimentController.text;
  if (sumHourString != '') {
    sumHourValue = int.parse(sumHourString);
  }
  return sumHourValue;
}
// old time method:
// Duration getTimeFromController(
//     TextEditingController controller, TextEditingController minuteController) {
//   final hours = int.tryParse(controller.text) ?? 0;
//   final minutes = int.tryParse(minuteController.text) ?? 0;

//   return Duration(hours: hours, minutes: minutes);
// }

// String formatDuration(Duration duration) {
//   final hours = duration.inHours.remainder(24);
//   final minutes = duration.inMinutes.remainder(60);

//   final formatter = NumberFormat('00');

//   final formattedTime =
//       '${formatter.format(hours)}:${formatter.format(minutes)}}';

//   return formattedTime;
// }

class dropdown extends StatefulWidget {
  final Function(String) onDropdownChanged;

  const dropdown({Key? key, required this.onDropdownChanged}) : super(key: key);

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
          widget.onDropdownChanged(dropdownValue);
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
  final _timeC = TextEditingController();
  TimeOfDay timeOfDay = TimeOfDay.now();
  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      // T: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('הוספת חלקים'),
          // content: TextField(
          //   controller: _textFieldController,
          //   decoration: const InputDecoration(hintText: 'Type your todo'),
          //   autofocus: true,
          // ),
          content: Container(
            // height: 300.0,
            child: Column(
              children: [
                ProductForm(onProductListChanged: handleProductListChanged),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                handleProductListChanged(productList);
                setState(() {});
              },
              child: const Text('הוספה'),
            ),
          ],
        );
      },
    );
  }

  Future displayTimePicker(BuildContext context) async {
    var time = await showTimePicker(context: context, initialTime: timeOfDay);

    if (time != null) {
      setState(() {
        _timeC.text = "${time.hour}:${time.minute}";
      });
      print(_timeC.text);
    }
  }

  String dropdownValue = '';
  List<ProductData> productList = [];
  void handleProductListChanged(List<ProductData> updatedList) {
    setState(() {
      productList = updatedList;
    });
  }

  void handleDropdownValueChange(String value) {
    setState(() {
      dropdownValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  dropdown(onDropdownChanged: handleDropdownValueChange),
                  // ElevatedButton(
                  //   child: Text('תאריך קריאה'),
                  //   onPressed: () {
                  //     // Open the DatePicker in the current screen.
                  //     // showDatePicker(
                  //     //   context: arg,
                  //     //   initialDate: DateTime.now(),
                  //     //   firstDate: DateTime(2023, 1, 1),
                  //     //   lastDate: DateTime(2023, 12, 31),
                  //     // );
                  //     Navigator.pushNamed(context, '/date');
                  //   },
                  // ),
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
                          decoration: InputDecoration.collapsed(
                              hintText: "תיאור טיפול"),
                        ),
                      ))
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'זמן טיפול:',
                  ),
                  SizedBox(width: 8.0),
                  GestureDetector(
                    onTap: () => displayTimePicker(context),
                    child: Text(
                      _timeC.text.isNotEmpty ? _timeC.text : 'בחר זמן',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              // old time method
              // TimeTextField(
              //     controller: timeController,
              //     controllerMinute: minuteController),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: paimentController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: 'סהכ לתשלום'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    AppStrings.paid,
                    style: TextStyle(fontSize: 16),
                  ),
                  Checkbox(
                      value: _checkboxValue,
                      onChanged: (newValue) {
                        print(newValue);

                        setState(() {
                          _checkboxValue = newValue!;

                          print(_checkboxValue);
                        });
                      }),
                  // Expanded(
                  //   child: TextField(
                  //     controller: paimentController,
                  //     keyboardType: TextInputType.number,
                  //     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  //     decoration: InputDecoration(labelText: 'סהכ לתשלום'),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _displayDialog(),
                    child: Text(
                      'אספקת חלקים:',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
        ElevatedButton(
          child: Text('שמור'),
          onPressed: () {
            // someFunction();
            setState(() {
              // old time method
              // final time =
              //     getTimeFromController(timeController, minuteController);

              // final formattedTime = formatDuration(time);
              // Use the 'time' duration as needed
              int sumHourValue = getSumHourValue();

              for (var product in productList) {
                print('Product Name: ${product.name}');
                print('Price: ${product.price}');
                print('Discounted Price: ${product.discountedPrice}');
              }
              print(dropdownValue);
              if (_callDetailsController.text != '' &&
                  _timeC.text != '' &&
                  sumHourValue != '' &&
                  dropdownValue != '') {
                addCall(
                  widget.user,
                  _callDetailsController.text,
                  _checkboxValue,
                  dropdownValue,
                  // formattedTime,
                  _timeC.text,
                  sumHourValue,
                  productList,
                );
                void resetForm() {
                  // Clear text fields
                  _callDetailsController.text = '';
                  _timeC.text = '';

                  // Reset checkbox value
                  _checkboxValue = false;

                  // Reset dropdown value
                  dropdownValue = '';

                  // Reset other variables as needed
                  sumHourValue = 0;
                  productList.clear();
                }

                resetForm();

                Navigator.of(context).pop();
              } else {
                showToast('חסרים פרטים');
              }
            });
          },
        ),
      ],
    );
    ;
  }
}

// CollectionReference clients = FirebaseFirestore.instance.collection('users');

// Future<void> addCall( user, call, paid, type) {
//   print(user.id);
//   // Call the user's CollectionReference to add a new user
//   return clients
//       .doc(user.id)
//       .update({
//         'calls': {
//           'call': call,
//           'paid': paid,
//           'type': type,
//         },
//       })

//       .then((value) => print("call Added"))

//       .catchError((error) => print("Failed to add call: $error"));

// }
Future<void> addCall(user, call, paid, type, hour, payment,
    List<ProductData> productList) async {
  final clientRef = FirebaseFirestore.instance.collection('users').doc(user.id);
  final callsRef = clientRef.collection('calls');

  try {
    await callsRef.add({
      'call': call,
      'paid': paid,
      'type': type,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'hour': hour,
      'payment': payment,
      'products': productList
          .map((product) => {
                'name': product.name,
                'price': product.price,
                'discountedPrice': product.discountedPrice,
              })
          .toList(),
    });
    print("Call Added");

    showToast('נשמר בהצלחה');
  } catch (error) {
    print("Failed to add call: $error");
  }
}
