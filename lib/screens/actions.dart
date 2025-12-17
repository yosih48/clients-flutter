// import 'package:clientsf/datePick.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supercharged/supercharged.dart';
import '../Constants/AppString.dart';
import '../componenets/alertDialog.dart';
import '../componenets/parts.dart';
import '../objects/clients.dart';
import '../singelton/AppSingelton.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

final List<Map<String, dynamic>> computerModels = [
  {'key': 'מחשב מיני HP I5-13', 'price': 1300},
  {'key': 'נייד DELL i5', 'price': 1382},
  {'key': 'נייד HP U5', 'price': 1335},
  {'key': 'DELL I5 נייח', 'price': 0},
];

const List<String> officeVersions = [
  'Office 19',
  'Office 21',
  'Office 24',
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
    // print(dropdownValue);
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: TextStyle(color: Theme.of(context).primaryColor),
      underline: Container(
        height: 2,
        color: Theme.of(context).colorScheme.secondary,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          // print(' state ${dropdownValue}');
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
      // print(data['call']);
    }
    // print(data['id']);
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
bool _checkboxDone = false;
bool _checkboxParts = false;

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
  String sumPayment = '0';
  String extraPayment = '0';
  List<Object> products = [];
  List<ProductData> productList = [];
  double pay = 0;

  // New fields state
  String? _selectedComputerProduct;

  final TextEditingController _quantityController = TextEditingController();
  String? _selectedOfficeVersion;
  bool _windowsLicense = false;
  bool _officeLicense = false;

  void initState() {
    super.initState();

    print('extraPayment1: ${extraPayment}');
    if (widget.data.containsKey('products') &&
        widget.data['products'].isNotEmpty) {
      // if (widget.data.isNotEmpty) {
      // productList = widget.data['products'];
      productList = (widget.data['products'] as List<dynamic>)
          .map<ProductData>((product) {
        // Convert each dynamic product into a ProductData object
        return ProductData(
          name: product['name'],
          price: product['price'],
          discountedPrice: product['discountedPrice'],
        );
      }).toList();
    }
    for (var product in productList) {
      // print('Product Name: ${product.name}');
      // print('productList Price: ${product.discountedPrice}');
      // print('Discounted Price: ${product.discountedPrice}');
      pay += product.price!;
    }
    if (widget.data.containsKey('done') && widget.data['done'] == null) {
      // if (widget.data.isNotEmpty) {
      _checkboxDone = false;
    } else if (widget.data['done'] == true) {
      _checkboxDone = true;
    }

    // print(widget.data['done'].runtimeType);
    callDetails = widget.data.isNotEmpty ? widget.data['call'] : '';
    sumPayment =
        widget.data.isNotEmpty ? widget.data['payment'].toString() : '0';

    _checkboxValue = widget.data.isNotEmpty ? widget.data['paid'] : false;
    _checkboxParts =
        widget.data.containsKey('partsPaid') && widget.data['partsPaid'] == null
            ? false
            : (widget.data['partsPaid'] == true ? true : false);

    if (widget.data.containsKey('extraPayment')) {
      // if (widget.data.isNotEmpty) {
      extraPayment = widget.data['extraPayment'].toString();
      print('extraPayment: ${extraPayment}');
    }
    print(' partsPaid: ${widget.data['partsPaid']}');
    // _checkboxDone = widget.data.isNotEmpty && widget.data.containsKey('done')
    //     ? widget.data['done']
    //     : '';
    dropdownValue = widget.data.isNotEmpty ? widget.data['type'] : list.first;

    // Initialize new fields
    if (widget.data.isNotEmpty) {
      _selectedComputerProduct = widget.data['computerProduct'];
      _quantityController.text = widget.data['quantity']?.toString() ?? '';
      _selectedOfficeVersion = widget.data['officeVersion'];
      _windowsLicense = widget.data['windowsLicense'] ?? false;
      _officeLicense = widget.data['officeLicense'] ?? false;
    }

    getPrefs();
  }

  void handleProductListChanged(List<ProductData> updatedList) {
    setState(() {
      // products = updatedList;

      //  productList.add(updatedList as ProductData);
      // productList.addAll(List.from(updatedList));
      for (var product in updatedList) {
        if (!productList.contains(product)) {
          productList.add(
              product); // Add only if the product doesn't exist in productList
        }
      }
    });
  }

  getPrefs() async {
    // The async keyword is placed before the SharedPreferences class.
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      // hourlyRate = prefs.getInt('newValue') ?? 0;
      hourlyRate = prefs.getInt('${AppSingelton().userID}_newValue') ?? 0;
    });
    // print(' void share ${hourlyRate}');
    // print('widget.data   ${widget.data}');
  }

  final _timeC = TextEditingController(text: '0:00');
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
                  // Inherit from Theme
                  ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  // Inherit from Theme
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
    print('_timeC.text: ${_timeC.text}');
    _timeC.text = '';
    widget.data.remove('hour');
    var time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    setState(() {
      if (time != null) {
        // print('bot Empty  ${time}');
        _timeC.text = "${time.hour}:${time.minute}";
      } else {
        // print(' Empty  ${time}');
        _timeC.text = '0:00';
      }

      // }
    });
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

      // print(' drop ${drop}');
    });
    // print('handleDropdown ${value}');
  }

  // List<ProductData> productList = [];

  // void handleProductListChanged(List<ProductData> updatedList) {
  //   setState(() {
  //     productList = updatedList;

  //   });
  // }
  // final TextEditingController paimentController =
  // TextEditingController(text: sumPayment);
  // TextEditingController();
  final TextEditingController paimentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextEditingController _callDetailsController =
        TextEditingController(text: callDetails);

    double getSumHourValue() {
      double sumHourValue = 0.0;
      String sumHourString = paimentController.text;
      if (sumHourString != '0' && sumHourString.isNotEmpty) {
        sumHourValue = double.tryParse(sumHourString) ?? 0.0;
      }
      return sumHourValue;
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              // Dropdown for Call Type
              DropdownButtonFormField<String>(
                value: dropdownValue,
                decoration: InputDecoration(
                  labelText: 'סוג טיפול',
                  prefixIcon: Icon(Icons.category),
                ),
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  handleDropdownValueChange(value!);
                  setState(() {
                    dropdownValue = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Status Switches
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(AppStrings.paid),
                      value: _checkboxValue,
                      onChanged: (bool value) {
                        setState(() {
                          _checkboxValue = value;
                        });
                      },
                      secondary: Icon(Icons.attach_money,
                          color: _checkboxValue ? Colors.green : Colors.grey),
                    ),
                    Divider(height: 1),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.done),
                      value: _checkboxDone,
                      onChanged: (bool value) {
                        setState(() {
                          _checkboxDone = value;
                        });
                      },
                      secondary: Icon(Icons.check_circle,
                          color: _checkboxDone ? Colors.green : Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Call Details
              TextField(
                controller: _callDetailsController,
                maxLines: 5,
                onChanged: (value) {
                  callDetails = value;
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.calldescription,
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 80), // Align icon to top
                    child: Icon(Icons.description),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Time Picker
              if (drop == true)
                GestureDetector(
                  onTap: () => displayTimePicker(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _timeC,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.callTime,
                        prefixIcon: Icon(Icons.access_time),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                ),
              if (drop == true) SizedBox(height: 16),

              // Computer Product Selection
              DropdownButtonFormField<String>(
                value: _selectedComputerProduct,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.selectProduct,
                  prefixIcon: Icon(Icons.computer),
                ),
                items: computerModels.map((model) {
                  String label = '';
                  switch (model['key']) {
                    case 'miniDell':
                      label = AppLocalizations.of(context)!.miniDell;
                      break;
                    case 'hpI5':
                      label = AppLocalizations.of(context)!.hpI5;
                      break;
                    case 'lenovoI7':
                      label = AppLocalizations.of(context)!.lenovoI7;
                      break;
                    case 'macMini':
                      label = AppLocalizations.of(context)!.macMini;
                      break;
                    default:
                      label = model['key'];
                  }
                  return DropdownMenuItem<String>(
                    value: model['key'],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label),
                        Text('${model['price']} ₪'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedComputerProduct = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Quantity
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.quantity,
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
              ),
              SizedBox(height: 16),

              // Office Version
              DropdownButtonFormField<String>(
                value: _selectedOfficeVersion,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.officeVersion,
                  prefixIcon: Icon(Icons.work),
                ),
                items: officeVersions.map((String version) {
                  return DropdownMenuItem<String>(
                    value: version,
                    child: Text(version),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedOfficeVersion = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Licenses
              CheckboxListTile(
                title: Text(AppLocalizations.of(context)!.windowsLicense),
                value: _windowsLicense,
                onChanged: (value) {
                  setState(() {
                    _windowsLicense = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text(AppLocalizations.of(context)!.officeLicense),
                value: _officeLicense,
                onChanged: (value) {
                  setState(() {
                    _officeLicense = value ?? false;
                  });
                },
              ),
              SizedBox(height: 16),

              // Extra Payment
              TextField(
                controller: paimentController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.extraPayment,
                  prefixIcon: Icon(Icons.add_card),
                  suffixText: '₪',
                ),
              ),
              SizedBox(height: 16),

              // Total Payment Display
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.paymentAmount}:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      '${widget.data.isEmpty ? '0' : widget.data['payment']} ₪',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Products Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.product,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _displayDialog(),
                    icon: Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.addParts),
                  ),
                ],
              ),
              SizedBox(height: 8),

              if (productList.isNotEmpty)
                Card(
                  margin: EdgeInsets.zero,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: productList.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = productList[index];
                      return ListTile(
                        title: Text(product.name ?? ''),
                        subtitle: Text(
                            '${AppLocalizations.of(context)!.costPrice}: ${product.discountedPrice} ₪'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${product.price} ₪',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  productList.remove(product);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              if (productList.isNotEmpty) SizedBox(height: 16),

              // Total Costs and Parts Paid
              if (productList.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.totalCosts}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            Text(
                              '$pay ₪',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.paid),
                          Switch(
                            value: _checkboxParts,
                            onChanged: (value) {
                              setState(() {
                                _checkboxParts = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                AppLocalizations.of(context)!.save,
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                setState(() {
                  double sumHourValue = 0;
                  if (drop == false) {
                    _timeC.text = '0:00';
                  }

                  int? firstNumber = 0;
                  int? secondNumber = 0;
                  if (_timeC.text.isNotEmpty) {
                    firstNumber = int.tryParse(_timeC.text.substring(0, 1));
                    secondNumber =
                        int.tryParse(_timeC.text.split(":")[1].substring(0, 1));
                  }

                  double newProduct = 0;
                  for (var product in productList) {
                    newProduct += product.discountedPrice!;
                  }
                  double sumProduct = newProduct;

                  if (secondNumber! > 0) {
                    firstNumber = firstNumber! + 1;
                  }
                  int hourCharge = hourlyRate * (firstNumber!);

                  double? payment = paimentController.text.isEmpty
                      ? (widget.data['payment'] as num?)?.toDouble()
                      : double.tryParse(paimentController.text) ?? 0.0;

                  double sumPayment = sumProduct + hourCharge + payment!;

                  if (_callDetailsController.text != '' &&
                      dropdownValue != '') {
                    if (widget.data.isEmpty) {
                      addCall(
                        widget.user,
                        _callDetailsController.text,
                        _checkboxValue,
                        dropdownValue,
                        _timeC.text,
                        sumPayment,
                        _checkboxDone,
                        payment,
                        productList,
                        _checkboxParts,
                        computerProduct: _selectedComputerProduct,
                        quantity: int.tryParse(_quantityController.text),
                        officeVersion: _selectedOfficeVersion,
                        windowsLicense: _windowsLicense,
                        officeLicense: _officeLicense,
                      );
                    } else {
                      updateUser(
                        widget.data['usera'],
                        widget.data['id'],
                        _callDetailsController.text,
                        _checkboxValue,
                        dropdownValue,
                        _timeC.text,
                        sumPayment,
                        _checkboxDone,
                        payment,
                        productList,
                        _checkboxParts,
                        computerProduct: _selectedComputerProduct,
                        quantity: int.tryParse(_quantityController.text),
                        officeVersion: _selectedOfficeVersion,
                        windowsLicense: _windowsLicense,
                        officeLicense: _officeLicense,
                      );
                    }

                    void resetForm() {
                      _callDetailsController.text = '';
                      _timeC.text = '0:00';
                      _checkboxValue = false;
                      _checkboxDone = false;
                      _checkboxParts = false;
                      _dropdownValue = '';
                      sumHourValue = 0;
                      productList.clear();
                      _selectedComputerProduct = null;
                      _quantityController.clear();
                      _selectedOfficeVersion = null;
                      _windowsLicense = false;
                      _officeLicense = false;
                    }

                    resetForm();
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.missingDetails)),
                    );
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> addCall(
  client,
  call,
  paid,
  type,
  hour,
  payment,
  done,
  extraCharge,
  List<ProductData> productList,
  partsPaid, {
  String? computerProduct,
  int? quantity,
  String? officeVersion,
  bool? windowsLicense,
  bool? officeLicense,
}) async {
  User? user = FirebaseAuth.instance.currentUser;
  // print('userID  ${client.name}');
  // print('nainuserID  ${user}');
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
      'done': done,
      'userRef': user!.uid,
      'clientName': client.name,
      'clientRef': client.id,
      'extraPayment': extraCharge,
      'products': productList
          .map((product) => {
                'name': product.name,
                'price': product.price,
                'discountedPrice': product.discountedPrice,
              })
          .toList(),
      'partsPaid': partsPaid,
      'computerProduct': computerProduct,
      'quantity': quantity,
      'officeVersion': officeVersion,
      'windowsLicense': windowsLicense,
      'officeLicense': officeLicense,
    });
    print("Call Added");

    // showToast('נשמר בהצלחה');
  } catch (error) {
    print("Failed to add call: $error");
  }
}

Future<void> updateUser(
  clientID,
  callID,
  callDetails,
  paid,
  type,
  hour,
  payment,
  done,
  extraCharge,
  List<ProductData> productList,
  partsPaid, {
  String? computerProduct,
  int? quantity,
  String? officeVersion,
  bool? windowsLicense,
  bool? officeLicense,
}) async {
  print(clientID);
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final clientRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('user_data')
      .doc(clientID);
  final callsRef = clientRef.collection('calls');
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
      'done': done,
      'extraPayment': extraCharge,
      'products': productList
          .map((product) => {
                'name': product.name,
                'price': product.price,
                'discountedPrice': product.discountedPrice,
              })
          .toList(),
      'partsPaid': partsPaid,
      'computerProduct': computerProduct,
      'quantity': quantity,
      'officeVersion': officeVersion,
      'windowsLicense': windowsLicense,
      'officeLicense': officeLicense,
    });

    print("Call Updated");
    // showToast('עודכן בהצלחה');
  } catch (error) {
    print("Failed to update call: $error");
  }
}
