// import 'package:clientsf/datePick.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/AppString.dart';
import '../componenets/alertDialog.dart';
import '../componenets/parts.dart';
import '../objects/clients.dart';
import '../singelton/AppSingelton.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

class dropdown extends StatefulWidget {
  final Function(String) onDropdownChanged;
  final Map<dynamic, dynamic> data;
  const dropdown(
      {Key? key, required this.onDropdownChanged, required this.data})
      : super(key: key);

  @override
  State<dropdown> createState() => _dropdownState();
}

String dropdownValue = '';

class _dropdownState extends State<dropdown> {
  @override
  void initState() {
    super.initState();
    dropdownValue = widget.data.isNotEmpty ? widget.data['type'] : list.first;
  }

  @override
  Widget build(BuildContext context) {
    print(dropdownValue);
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
          print(' state ${dropdownValue}');
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

class actions extends StatefulWidget {
  final Todo? user;

  const actions({super.key, this.user});
  // const actions({Key? key, required this.userId}) : super(key: key);
  @override
  State<actions> createState() => _actionsState();
}

class _actionsState extends State<actions> {
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // usera = (arguments?['usera'] as String?)!;
    bool navigatedFromScreen1 = (arguments?['fromScreen1'] as bool? ?? false);

    // print(usera);
    // print('navigatedFromScreen1  ${navigatedFromScreen1}');
    Map data = {};
    if (navigatedFromScreen1) {
      data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      print(data['call']);
    }
    print(data['id']);
    // data = data.isNotEmpty
    //     ? data
    //     : ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text('חיובים'),
      ),

      // body: call(user: widget.user!),

      body: call(user: widget.user, data: data, dropdownValue: dropdownValue),
    );
  }
}

bool _checkboxValue = false;

class call extends StatefulWidget {
  final user;
  final data;
  final String dropdownValue;
  const call(
      {super.key, this.user, required this.data, required this.dropdownValue});

  @override
  State<call> createState() => _callState();
}

class _callState extends State<call> {
  // bool _checkboxValue = false;

  int hourlyRate = 0;
  String callDetails = '';
  List<dynamic> products = [];
  void initState() {
    super.initState();
    if (widget.data.containsKey('products') &&
        widget.data['products'].isNotEmpty) {
      // if (widget.data.isNotEmpty) {
      products = widget.data['products'];
    }

    callDetails = widget.data.isNotEmpty ? widget.data['call'] : '';
    _checkboxValue = widget.data.isNotEmpty ? widget.data['paid'] : false;
    dropdownValue = widget.data.isNotEmpty ? widget.data['type'] : list.first;
    getPrefs();
  }

  void handleProductListChanged(List<ProductData> updatedList) {
    setState(() {
      productList = updatedList;
     
      // products.add(updatedList);
    });
  }

  getPrefs() async {
    // The async keyword is placed before the SharedPreferences class.
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      // hourlyRate = prefs.getInt('newValue') ?? 0;
      hourlyRate = prefs.getInt('${AppSingelton().userID}_newValue') ?? 0;
    });
    print(' void share ${hourlyRate}');
    print('widget.data   ${widget.data}');
  }

  final _timeC = TextEditingController();
  TimeOfDay timeOfDay = TimeOfDay.now();

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      // T: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addParts),
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
              child: Text(AppLocalizations.of(context)!.cancel),
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
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );
  }

  Future displayTimePicker(BuildContext context) async {
    _timeC.text = '';
    widget.data.remove('hour');
    var time = await showTimePicker(context: context, initialTime: timeOfDay);
    // print(widget.data);
    // print('time  ${time}');
    setState(() {
      // if (widget.data.isNotEmpty) {
      //   _timeC.text = widget.data['hour'];
      //   print('NotEmpty  ${_timeC.text}');
      // } else {
      // print('Empty  ${_timeC.text}');

      if (time != null) {
        print('bot Empty  ${time}');
        _timeC.text = "${time.hour}:${time.minute}";
      } else {
        print(' Empty  ${time}');
        _timeC.text = '0.00';
      }

      // }
    });
    //     if (widget.data.isNotEmpty) {
    //   _timeC.text = widget.data['hour'];
    // } else if (time != null) {
    //   _timeC.text = "${time.hour}:${time.minute}";
    // } else {
    //   _timeC.text = 'בחר זמן';
    // }

    print(_timeC.text);
  }

  String _dropdownValue = '';
  bool drop = true;
  void handleDropdownValueChange(String value) {
    setState(() {
      _dropdownValue = value;
      if (dropdownValue == 'מכירת ציוד') {
        drop = false;
      } else {
        drop = true;
      }

      print(' drop ${drop}');
    });
    print('handleDropdown ${value}');
  }

  List<ProductData> productList = [];

  // void handleProductListChanged(List<ProductData> updatedList) {
  //   setState(() {
  //     productList = updatedList;

  //   });
  // }

  final TextEditingController paimentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // String callDetails = widget.data.isNotEmpty ? widget.data['call'] : '';
    final TextEditingController _callDetailsController =
        TextEditingController(text: callDetails);
    // final TextEditingController paimentController = TextEditingController();

    int getSumHourValue() {
      int sumHourValue = 0;

      String sumHourString = paimentController.text;
      if (sumHourString != '') {
        sumHourValue = int.parse(sumHourString);
      }
      return sumHourValue;
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  dropdown(
                    onDropdownChanged: handleDropdownValueChange,
                    data: widget.data,
                  ),

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
                          onChanged: (value) {
                            // Update the callDetails variable whenever the user changes the text
                            callDetails = value;
                          },
                          decoration: InputDecoration.collapsed(
                              hintText: AppLocalizations.of(context)!
                                  .calldescription),
                        ),
                      ))
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              if (drop == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.callTime,
                    ),
                    SizedBox(width: 8.0),
                    GestureDetector(
                      onTap: () => displayTimePicker(context),
                      child: Text(
                        // _timeC.text.isNotEmpty  ? _timeC.text : 'בחר זמן',
// _timeC.text.isEmpty? _timeC.text = widget.data['hour'] :  'בחר זמן',

                        widget.data.containsKey('hour')
                            ? (_timeC.text = widget.data['hour'])
                            : (_timeC.text.isNotEmpty
                                ? _timeC.text
                                : AppLocalizations.of(context)!.chooseTime),

                        //  _timeC.text.isNotEmpty && widget.data.isEmpty ? _timeC.text : (widget.data.isNotEmpty ? widget.data['hour'] : 'בחר זמן'),
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
                      decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.paymentAmount),
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
              if (products.isNotEmpty) SizedBox(height: 8),
              Column(
                children: products.map((product) {
                  final productName = product['name'];
                  final productPrice = product['price'];

                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          productName,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          '$productPrice ₪',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                }).toList(),
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
              int sumHourValue = getSumHourValue();
              int? firstNumber = 0;
              if (_timeC.text.isNotEmpty) {
                firstNumber = int.tryParse(_timeC.text.substring(0, 1));
              }

// sum poduct price
              double sumProduct = 0;
              for (var product in productList) {
                // print('Product Name: ${product.name}');
                // print('Price: ${product.price}');
                // print('Discounted Price: ${product.discountedPrice}');
                sumProduct += product.price!;
              }

              // print(sumHourValue.runtimeType);
              // print('userID  ${widget.user.id}');

              // price per hour
              int hourCharge = hourlyRate * (firstNumber! + 1);
              // calculate total price
              double sumPayment =
                  sumHourValue.toDouble() + sumProduct + hourCharge;

              print('dropdownValue ${dropdownValue}');
              print('charge per hour  ${hourCharge}');
              print('total payment  ${sumPayment}');
              print('hour first number  ${firstNumber}');
              print('call details  ${_callDetailsController.text}');
              // print('sigelton  ${AppSingelton().hourlyRate}');
              print('call time ${_timeC.text}');

              print('dataEmpty ${widget.data}');
              if (drop == false) {
                _timeC.text = '0';
              }
              if (_callDetailsController.text != '' &&
                  _timeC.text != '' &&
                  sumHourValue != '' &&
                  dropdownValue != '') {
                if (widget.data.isEmpty) {
                  print('empty');
                  addCall(
                      widget.user,
                      _callDetailsController.text,
                      _checkboxValue,
                      dropdownValue,
                      // formattedTime,
                      _timeC.text,
                      sumPayment,
                      productList);
                } else {
                  updateUser(
                      widget.data['usera'],
                      widget.data['id'],
                      _callDetailsController.text,
                      _checkboxValue,
                      dropdownValue,
                      _timeC.text,
                      sumPayment,
                      productList);
                }

                void resetForm() {
                  // Clear text fields
                  _callDetailsController.text = '';
                  _timeC.text = '';

                  // Reset checkbox value
                  _checkboxValue = false;

                  // Reset dropdown value
                  _dropdownValue = '';

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

Future<void> addCall(client, call, paid, type, hour, payment,
    List<ProductData> productList) async {
  User? user = FirebaseAuth.instance.currentUser;
  print('userID  ${client.id}');
  print('nainuserID  ${user}');
  final clientRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('user_data')
      .doc(client.id);
  final callsRef = clientRef.collection('calls');

  try {
    final callDoc =
        callsRef.doc(); // Create a new document with an auto-generated ID
    final callId = callDoc.id;

    await callDoc.set({
      'id': callId,
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

Future<void> updateUser(clientID, callID, callDetails, paid, type, hour,
    payment, List<ProductData> productList) async {
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final clientRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('user_data')
      .doc(clientID);
  final callsRef = clientRef.collection('calls');
  // print(phone);
  // print(user!.uid);
  // print(id);

  Map<String, dynamic> updatedData = {};

  // Update 'name' field if a new value is provided and not empty
  if (callDetails != null && callDetails.isNotEmpty) {
    updatedData['callDetails'] = callDetails;
  }

  // Update 'email' field if a new value is provided and not empty
  // if ( paid != null &&  paid.isNotEmpty) {
  //   updatedData[' paid'] =  paid;
  // }

  // Update 'address' field if a new value is provided and not empty
  if (type != null && type.isNotEmpty) {
    updatedData[' type'] = type;
  }

  // Update 'phone' field if a new value is provided and not empty
  // if (payment != null && payment.isNotEmpty) {
  //   updatedData['payment'] = payment;
  // }

  try {
    final callDoc = callsRef.doc(callID);
    await callDoc.update({
      'call': callDetails,
      'paid': paid,
      'type': type,
      'hour': hour,
      'payment': payment,
      'products': FieldValue.arrayUnion(productList
          .map((product) => {
                'name': product.name,
                'price': product.price,
                'discountedPrice': product.discountedPrice,
              })
          .toList()),
    });

    print("Call Updated");
    showToast('עודכן בהצלחה');
  } catch (error) {
    print("Failed to update call: $error");
  }
}
