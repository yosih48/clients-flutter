import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../componenets/parts.dart';
import '../objects/clients.dart';
import '../singelton/AppSingelton.dart';
import 'package:clientsf/l10n/app_localizations.dart';

import '../services/airtable_service.dart';

const List<String> _serviceTypes = [
  'סוג טיפול',
  'טיפול מרחוק',
  'מכירת ציוד',
  'בית הלקוח',
];

List<Map<String, dynamic>> computerModels = [];

const List<String> _officeVersions = [
  'Office 19',
  'Office 21',
  'Office 24',
];

String dropdownValue = '';

class actions extends StatefulWidget {
  final Todo? user;

  const actions({super.key, this.user});
  @override
  State<actions> createState() => _actionsState();
}

class _actionsState extends State<actions> {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool navigatedFromScreen1 =
        (arguments?['fromScreen1'] as bool? ?? false);
    Map data = {};
    if (navigatedFromScreen1) {
      data = ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>;
    }
    final isEdit = data.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? 'Edit ticket' : 'New ticket')),
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
      {super.key,
      this.user,
      required this.data,
      required this.dropdownValue});

  @override
  State<call> createState() => _callState();
}

class _callState extends State<call> {
  int hourlyRate = 0;
  String callDetails = '';
  String sumPayment = '0';
  String extraPayment = '0';
  List<ProductData> productList = [];
  double pay = 0;

  String? _selectedComputerProduct;
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedOfficeVersion;
  bool _windowsLicense = false;
  bool _officeLicense = false;
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();

    if (widget.data.containsKey('products') &&
        widget.data['products'].isNotEmpty) {
      productList = (widget.data['products'] as List<dynamic>)
          .map<ProductData>((product) => ProductData(
                name: product['name'],
                price: product['price'],
                discountedPrice: product['discountedPrice'],
              ))
          .toList();
    }
    for (final product in productList) {
      pay += (product.price ?? 0);
    }
    if (widget.data.containsKey('done') && widget.data['done'] == null) {
      _checkboxDone = false;
    } else if (widget.data['done'] == true) {
      _checkboxDone = true;
    }

    callDetails = widget.data.isNotEmpty ? widget.data['call'] : '';
    sumPayment =
        widget.data.isNotEmpty ? widget.data['payment'].toString() : '0';

    _checkboxValue = widget.data.isNotEmpty ? widget.data['paid'] : false;
    _checkboxParts =
        widget.data.containsKey('partsPaid') && widget.data['partsPaid'] == null
            ? false
            : (widget.data['partsPaid'] == true ? true : false);

    if (widget.data.containsKey('extraPayment')) {
      extraPayment = widget.data['extraPayment'].toString();
    }
    dropdownValue =
        widget.data.isNotEmpty ? widget.data['type'] : _serviceTypes.first;

    if (widget.data.isNotEmpty) {
      _selectedComputerProduct = widget.data['computerProduct'];
      _quantityController.text = widget.data['quantity']?.toString() ?? '';
      _selectedOfficeVersion = widget.data['officeVersion'];
      _windowsLicense = widget.data['windowsLicense'] ?? false;
      _officeLicense = widget.data['officeLicense'] ?? false;
      _inProgress = widget.data['inProgress'] ?? false;
    }

    getPrefs();
    _fetchComputerModels();
  }

  Future<void> _fetchComputerModels() async {
    final models = await AirtableService().fetchComputerModels();
    setState(() => computerModels = models);
  }

  void handleProductListChanged(List<ProductData> updatedList) {
    setState(() {
      for (final product in updatedList) {
        if (!productList.contains(product)) {
          productList.add(product);
        }
      }
    });
  }

  Future<void> getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hourlyRate = prefs.getInt('${AppSingelton().userID}_newValue') ?? 0;
    });
  }

  final _timeC = TextEditingController(text: '0:00');
  TimeOfDay timeOfDay = TimeOfDay.now();

  Future<void> _displayProductDialog() async {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(loc.addParts),
          content: SizedBox(
            width: 360,
            child: ProductForm(onProductListChanged: handleProductListChanged),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                handleProductListChanged(productList);
                setState(() {});
              },
              child: Text(loc.add),
            ),
          ],
        );
      },
    );
  }

  Future displayTimePicker(BuildContext context) async {
    _timeC.text = '';
    widget.data.remove('hour');
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
      _timeC.text =
          time != null ? "${time.hour}:${time.minute}" : '0:00';
    });
  }

  bool _showHourField = true;
  void _handleDropdownValueChange(String value) {
    setState(() {
      if (value == 'מכירת ציוד') {
        _showHourField = false;
      } else {
        _showHourField = true;
      }
    });
  }

  final TextEditingController paimentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final TextEditingController _callDetailsController =
        TextEditingController(text: callDetails);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              // Service type
              _FieldLabel('Service type'),
              DropdownButtonFormField<String>(
                value: dropdownValue,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.handyman_outlined),
                ),
                items: _serviceTypes
                    .map((v) =>
                        DropdownMenuItem<String>(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) {
                  _handleDropdownValueChange(v!);
                  setState(() => dropdownValue = v);
                },
              ),
              const SizedBox(height: 20),

              // Status switches
              _FieldLabel('Status'),
              SoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ToggleRow(
                      icon: Icons.payments_outlined,
                      label: 'שולם',
                      value: _checkboxValue,
                      accent: AppColors.success,
                      onChanged: (v) => setState(() => _checkboxValue = v),
                    ),
                    _DividerInline(),
                    _ToggleRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: loc.done,
                      value: _checkboxDone,
                      accent: AppColors.success,
                      onChanged: (v) => setState(() => _checkboxDone = v),
                    ),
                    _DividerInline(),
                    _ToggleRow(
                      icon: Icons.work_history_rounded,
                      label: 'In progress',
                      value: _inProgress,
                      accent: AppColors.primary,
                      onChanged: (v) => setState(() => _inProgress = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Call details
              _FieldLabel(loc.calldescription),
              TextField(
                controller: _callDetailsController,
                maxLines: 4,
                onChanged: (v) => callDetails = v,
                decoration: const InputDecoration(
                  hintText: '…',
                ),
              ),
              const SizedBox(height: 20),

              if (_showHourField) ...[
                _FieldLabel(loc.callTime),
                GestureDetector(
                  onTap: () => displayTimePicker(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _timeC,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.access_time_rounded),
                        suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              _FieldLabel(loc.selectProduct),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedComputerProduct,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.computer_outlined),
                ),
                items: computerModels.map((model) {
                  String label = '';
                  switch (model['key']) {
                    case 'miniDell':
                      label = loc.miniDell;
                      break;
                    case 'hpI5':
                      label = loc.hpI5;
                      break;
                    case 'lenovoI7':
                      label = loc.lenovoI7;
                      break;
                    case 'macMini':
                      label = loc.macMini;
                      break;
                    default:
                      label = model['key'];
                  }
                  return DropdownMenuItem<String>(
                    value: model['key'],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text(label, overflow: TextOverflow.ellipsis)),
                        Text('${model['price']} ₪',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) =>
                    setState(() => _selectedComputerProduct = v),
              ),
              const SizedBox(height: 20),

              _FieldLabel(loc.quantity),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.format_list_numbered_rounded),
                ),
              ),
              const SizedBox(height: 20),

              _FieldLabel(loc.officeVersion),
              DropdownButtonFormField<String>(
                value: _selectedOfficeVersion,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.apps_rounded),
                ),
                items: _officeVersions
                    .map((v) =>
                        DropdownMenuItem<String>(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedOfficeVersion = v),
              ),
              const SizedBox(height: 20),

              SoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ToggleRow(
                      icon: Icons.window_rounded,
                      label: loc.windowsLicense,
                      value: _windowsLicense,
                      accent: AppColors.primary,
                      onChanged: (v) =>
                          setState(() => _windowsLicense = v),
                    ),
                    _DividerInline(),
                    _ToggleRow(
                      icon: Icons.workspaces_outline,
                      label: loc.officeLicense,
                      value: _officeLicense,
                      accent: AppColors.primary,
                      onChanged: (v) =>
                          setState(() => _officeLicense = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _FieldLabel(loc.extraPayment),
              TextField(
                controller: paimentController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.add_card_rounded),
                  suffixText: '₪',
                ),
              ),
              const SizedBox(height: 20),

              // Total payment
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accentSoft, Color(0xFFFFF1E6)],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                      color: AppColors.accent.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.receipt_long_rounded,
                          color: AppColors.ink, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(loc.paymentAmount,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ),
                    Text(
                      '${widget.data.isEmpty ? '0' : widget.data['payment']} ₪',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Products section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.product,
                      style: Theme.of(context).textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: _displayProductDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(loc.addParts),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (productList.isNotEmpty)
                SoftCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productList.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Theme.of(context).dividerColor,
                        indent: 18,
                        endIndent: 18),
                    itemBuilder: (context, index) {
                      final product = productList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.accentSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 18,
                                  color: AppColors.warning),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(product.name ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  Text(
                                    '${loc.costPrice}: ${product.discountedPrice} ₪',
                                    style: TextStyle(
                                        color: AppColors.inkMuted,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${product.price} ₪',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15),
                            ),
                            IconButton(
                              icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.danger,
                                  size: 20),
                              onPressed: () => setState(
                                  () => productList.remove(product)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              if (productList.isNotEmpty) const SizedBox(height: 16),

              if (productList.isNotEmpty)
                SoftCard(
                  padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  bordered: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.totalCosts,
                                style: TextStyle(
                                    color: AppColors.inkMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('$pay ₪',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(loc.paid,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Switch(
                            value: _checkboxParts,
                            onChanged: (v) =>
                                setState(() => _checkboxParts = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Sticky save bar
        Container(
          padding:
              const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded, size: 20),
                label: Text(loc.save),
                onPressed: () {
                  setState(() {
                    if (!_showHourField) _timeC.text = '0:00';

                    int? firstNumber = 0;
                    int? secondNumber = 0;
                    if (_timeC.text.isNotEmpty) {
                      firstNumber =
                          int.tryParse(_timeC.text.substring(0, 1));
                      secondNumber = int.tryParse(
                          _timeC.text.split(":")[1].substring(0, 1));
                    }

                    double newProduct = 0;
                    for (final product in productList) {
                      newProduct += (product.discountedPrice ?? 0);
                    }
                    final double sumProduct = newProduct;

                    if (secondNumber! > 0) firstNumber = firstNumber! + 1;
                    final int hourCharge = hourlyRate * (firstNumber!);

                    final double? payment = paimentController.text.isEmpty
                        ? (widget.data['payment'] as num?)?.toDouble()
                        : double.tryParse(paimentController.text) ?? 0.0;

                    final double finalPayment =
                        sumProduct + hourCharge + (payment ?? 0);

                    if (_callDetailsController.text != '' &&
                        dropdownValue != '') {
                      if (widget.data.isEmpty) {
                        addCall(
                          widget.user,
                          _callDetailsController.text,
                          _checkboxValue,
                          dropdownValue,
                          _timeC.text,
                          finalPayment,
                          _checkboxDone,
                          payment,
                          productList,
                          _checkboxParts,
                          computerProduct: _selectedComputerProduct,
                          quantity:
                              int.tryParse(_quantityController.text),
                          officeVersion: _selectedOfficeVersion,
                          windowsLicense: _windowsLicense,
                          officeLicense: _officeLicense,
                          inProgress: _inProgress,
                        );
                      } else {
                        updateUser(
                          widget.data['usera'],
                          widget.data['id'],
                          _callDetailsController.text,
                          _checkboxValue,
                          dropdownValue,
                          _timeC.text,
                          finalPayment,
                          _checkboxDone,
                          payment,
                          productList,
                          _checkboxParts,
                          computerProduct: _selectedComputerProduct,
                          quantity:
                              int.tryParse(_quantityController.text),
                          officeVersion: _selectedOfficeVersion,
                          windowsLicense: _windowsLicense,
                          officeLicense: _officeLicense,
                          inProgress: _inProgress,
                        );
                      }

                      _callDetailsController.text = '';
                      _timeC.text = '0:00';
                      _checkboxValue = false;
                      _checkboxDone = false;
                      _checkboxParts = false;
                      productList.clear();
                      _selectedComputerProduct = null;
                      _quantityController.clear();
                      _selectedOfficeVersion = null;
                      _windowsLicense = false;
                      _officeLicense = false;
                      _inProgress = false;

                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.missingDetails)),
                      );
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.inkMuted,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: value ? accent.withOpacity(0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon,
                  size: 18,
                  color: value ? accent : AppColors.inkMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _DividerInline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Divider(height: 1, color: Theme.of(context).dividerColor),
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
  bool? inProgress,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  final clientRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('user_data')
      .doc(client.id);
  final callsRef = clientRef.collection('calls');

  try {
    final callDoc = callsRef.doc();
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
      'userRef': user.uid,
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
      'inProgress': inProgress,
    });
  } catch (error) {
    debugPrint("Failed to add call: $error");
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
  bool? inProgress,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  final clientRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('user_data')
      .doc(clientID);
  final callsRef = clientRef.collection('calls');

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
      'inProgress': inProgress,
    });
  } catch (error) {
    debugPrint("Failed to update call: $error");
  }
}
