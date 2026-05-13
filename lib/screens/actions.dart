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

const List<String> _serviceTypeKeys = [
  'טיפול מרחוק',
  'מכירת ציוד',
  'בית הלקוח',
];

const Map<String, IconData> _serviceTypeIcons = {
  'טיפול מרחוק': Icons.headset_mic_rounded,
  'מכירת ציוד': Icons.shopping_bag_rounded,
  'בית הלקוח': Icons.home_work_rounded,
  'סוג טיפול': Icons.handyman_outlined,
};

List<Map<String, dynamic>> computerModels = [];

const List<String> _officeVersions = ['Office 19', 'Office 21', 'Office 24'];

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
    final Map data = navigatedFromScreen1
        ? (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>)
        : {};
    final isEdit = data.isNotEmpty;

    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? loc.editTicket : loc.newTicket),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: _CallForm(user: widget.user, data: data, isEdit: isEdit),
    );
  }
}

class _CallForm extends StatefulWidget {
  final Todo? user;
  final Map data;
  final bool isEdit;
  const _CallForm(
      {required this.user, required this.data, required this.isEdit});

  @override
  State<_CallForm> createState() => _CallFormState();
}

class _CallFormState extends State<_CallForm> {
  int _hourlyRate = 0;

  // Form state
  String _serviceType = 'טיפול מרחוק';
  bool _paid = false;
  bool _done = false;
  bool _inProgress = false;
  bool _partsPaid = false;

  final TextEditingController _detailsCtrl = TextEditingController();
  final TextEditingController _extraPayCtrl = TextEditingController();
  final TextEditingController _quantityCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController(text: '0:00');

  String? _selectedComputerProduct;
  String? _selectedOfficeVersion;
  bool _windowsLicense = false;
  bool _officeLicense = false;
  bool _showAdvanced = false;

  List<ProductData> _productList = [];

  @override
  void initState() {
    super.initState();
    final data = widget.data;
    if (data.isNotEmpty) {
      _serviceType = data['type'] ?? _serviceTypeKeys.first;
      _detailsCtrl.text = data['call'] ?? '';
      _paid = data['paid'] ?? false;
      _done = data['done'] == true;
      _inProgress = data['inProgress'] ?? false;
      _partsPaid = data['partsPaid'] == true;
      _timeCtrl.text = (data['hour']?.toString().isNotEmpty == true)
          ? data['hour'].toString()
          : '0:00';
      _selectedComputerProduct = data['computerProduct'];
      _quantityCtrl.text = data['quantity']?.toString() ?? '';
      _selectedOfficeVersion = data['officeVersion'];
      _windowsLicense = data['windowsLicense'] ?? false;
      _officeLicense = data['officeLicense'] ?? false;

      if (data['extraPayment'] != null && data['extraPayment'] != 0) {
        _extraPayCtrl.text = data['extraPayment'].toString();
      }

      if (data.containsKey('products') &&
          (data['products'] as List).isNotEmpty) {
        _productList = (data['products'] as List<dynamic>)
            .map<ProductData>((p) => ProductData(
                  name: p['name'],
                  price: p['price'],
                  discountedPrice: p['discountedPrice'],
                ))
            .toList();
      }

      // Auto-expand advanced if any advanced field is set
      _showAdvanced = _selectedComputerProduct != null ||
          _selectedOfficeVersion != null ||
          _windowsLicense ||
          _officeLicense ||
          _quantityCtrl.text.isNotEmpty;
    } else if (!_serviceTypeKeys.contains(_serviceType)) {
      _serviceType = _serviceTypeKeys.first;
    }

    _loadHourlyRate();
    _fetchComputerModels();
  }

  @override
  void dispose() {
    _detailsCtrl.dispose();
    _extraPayCtrl.dispose();
    _quantityCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHourlyRate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hourlyRate = prefs.getInt('${AppSingelton().userID}_newValue') ?? 0;
    });
  }

  Future<void> _fetchComputerModels() async {
    final models = await AirtableService().fetchComputerModels();
    if (mounted) setState(() => computerModels = models);
  }

  bool get _showTime => _serviceType != 'מכירת ציוד';

  // Live computed total used for the hero card.
  double get _liveTotal {
    int hours = 0;
    int minutes = 0;
    if (_showTime && _timeCtrl.text.contains(':')) {
      final parts = _timeCtrl.text.split(':');
      hours = int.tryParse(parts[0]) ?? 0;
      minutes = int.tryParse(parts[1]) ?? 0;
    }
    if (minutes > 0) hours += 1;

    // Parts cost = "מחיר עלות" (the cost-to-me), stored on ProductData.price.
    final partsCost =
        _productList.fold<double>(0, (a, p) => a + (p.price ?? 0));
    final extra = double.tryParse(_extraPayCtrl.text) ?? 0;
    // Profit = what the client pays (extra) + hourly work − cost of parts.
    return extra + hours * _hourlyRate - partsCost;
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _timeCtrl.text =
          '${time.hour}:${time.minute.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _openProductDialog() async {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(loc.addParts),
          content: SizedBox(
            width: 360,
            child: ProductForm(onProductListChanged: (updated) {
              for (final p in updated) {
                if (!_productList.contains(p)) _productList.add(p);
              }
            }),
          ),
          actions: [
            OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(loc.cancel)),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() {});
                },
                child: Text(loc.add)),
          ],
        );
      },
    );
  }

  void _save(AppLocalizations loc) {
    if (_detailsCtrl.text.isEmpty || _serviceType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.missingDetails)),
      );
      return;
    }

    final timeText = _showTime ? _timeCtrl.text : '0:00';
    int hours = 0;
    int minutes = 0;
    if (timeText.contains(':')) {
      final parts = timeText.split(':');
      hours = int.tryParse(parts[0]) ?? 0;
      minutes = int.tryParse(parts[1]) ?? 0;
    }
    if (minutes > 0) hours += 1;

    // Parts cost = "מחיר עלות" (the cost-to-me), stored on ProductData.price.
    final partsCost =
        _productList.fold<double>(0, (a, p) => a + (p.price ?? 0));
    final extra = _extraPayCtrl.text.isEmpty
        ? (widget.data['payment'] as num?)?.toDouble() ?? 0.0
        : (double.tryParse(_extraPayCtrl.text) ?? 0.0);

    // Profit = what the client pays + hourly work − parts cost.
    final totalPayment = extra + hours * _hourlyRate - partsCost;

    if (widget.data.isEmpty) {
      addCall(
        widget.user,
        _detailsCtrl.text,
        _paid,
        _serviceType,
        timeText,
        totalPayment,
        _done,
        extra,
        _productList,
        _partsPaid,
        computerProduct: _selectedComputerProduct,
        quantity: int.tryParse(_quantityCtrl.text),
        officeVersion: _selectedOfficeVersion,
        windowsLicense: _windowsLicense,
        officeLicense: _officeLicense,
        inProgress: _inProgress,
      );
    } else {
      updateUser(
        widget.data['usera'],
        widget.data['id'],
        _detailsCtrl.text,
        _paid,
        _serviceType,
        timeText,
        totalPayment,
        _done,
        extra,
        _productList,
        _partsPaid,
        computerProduct: _selectedComputerProduct,
        quantity: int.tryParse(_quantityCtrl.text),
        officeVersion: _selectedOfficeVersion,
        windowsLicense: _windowsLicense,
        officeLicense: _officeLicense,
        inProgress: _inProgress,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              // 1. Live total hero
              _TotalHero(amount: _liveTotal, paid: _paid),
              const SizedBox(height: 20),

              // 2. Service type picker
              _SectionLabel(loc.serviceType),
              _ServiceTypePicker(
                selected: _serviceType,
                onChanged: (v) => setState(() => _serviceType = v),
              ),
              const SizedBox(height: 24),

              // 3. Status chips
              _SectionLabel(loc.status),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(
                    label: loc.statusPaid,
                    icon: Icons.payments_outlined,
                    selected: _paid,
                    color: AppColors.success,
                    onTap: () => setState(() => _paid = !_paid),
                  ),
                  _StatusChip(
                    label: loc.statusInProgress,
                    icon: Icons.work_history_rounded,
                    selected: _inProgress,
                    color: AppColors.primary,
                    onTap: () =>
                        setState(() => _inProgress = !_inProgress),
                  ),
                  _StatusChip(
                    label: loc.done,
                    icon: Icons.check_circle_outline_rounded,
                    selected: _done,
                    color: AppColors.warning,
                    onTap: () => setState(() => _done = !_done),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Description
              _SectionLabel(loc.calldescription),
              SoftCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 4),
                child: TextField(
                  controller: _detailsCtrl,
                  maxLines: 5,
                  minLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    hintText: loc.descriptionHint,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Time row (conditional) + Extra payment side-by-side
              Row(
                children: [
                  if (_showTime) ...[
                    Expanded(
                      child: _CompactField(
                        label: loc.callTime,
                        icon: Icons.access_time_rounded,
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _timeCtrl,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        rate: _hourlyRate > 0
                            ? '@ $_hourlyRate ₪/h'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: _CompactField(
                      label: loc.extraPayment,
                      icon: Icons.add_card_rounded,
                      child: TextField(
                        controller: _extraPayCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          hintText: '0',
                          suffixText: '₪',
                        ),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 6. Parts list with inline add
              _PartsSection(
                items: _productList,
                onAdd: _openProductDialog,
                onRemove: (p) =>
                    setState(() => _productList.remove(p)),
                partsPaid: _partsPaid,
                onPartsPaidChanged: (v) => setState(() => _partsPaid = v),
                loc: loc,
              ),

              const SizedBox(height: 20),

              // 7. Advanced (hardware / licenses) – collapsible
              _ExpandableSection(
                title: loc.hardwareAndLicenses,
                subtitle: _advancedSummary(loc),
                expanded: _showAdvanced,
                onToggle: () =>
                    setState(() => _showAdvanced = !_showAdvanced),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedComputerProduct,
                      decoration: InputDecoration(
                        labelText: loc.selectProduct,
                        prefixIcon: const Icon(Icons.computer_outlined),
                      ),
                      items: computerModels.map((model) {
                        String label;
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
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Text(label,
                                      overflow: TextOverflow.ellipsis)),
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        labelText: loc.quantity,
                        prefixIcon:
                            const Icon(Icons.format_list_numbered_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedOfficeVersion,
                      decoration: InputDecoration(
                        labelText: loc.officeVersion,
                        prefixIcon: const Icon(Icons.apps_rounded),
                      ),
                      items: _officeVersions
                          .map((v) => DropdownMenuItem<String>(
                              value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedOfficeVersion = v),
                    ),
                    const SizedBox(height: 12),
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
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18),
                            child: Divider(
                                height: 1,
                                color:
                                    Theme.of(context).dividerColor),
                          ),
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
                  ],
                ),
              ),
            ],
          ),
        ),

        // Sticky save bar with live total summary
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(loc.total,
                        style: TextStyle(
                            color: AppColors.inkMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8)),
                    Text(
                      '${_liveTotal.toStringAsFixed(0)} ₪',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text(widget.isEdit ? loc.saveChanges : loc.save),
                    onPressed: () => _save(loc),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _advancedSummary(AppLocalizations loc) {
    final bits = <String>[];
    if (_selectedComputerProduct != null) bits.add(loc.summaryHardware);
    if (_selectedOfficeVersion != null) bits.add(loc.summaryOffice);
    if (_windowsLicense) bits.add(loc.summaryWinLicense);
    if (_officeLicense) bits.add(loc.summaryOfficeLicense);
    return bits.isEmpty ? loc.optionalDetails : bits.join(' · ');
  }
}

// ─── building blocks ──────────────────────────────────────────────────────

class _TotalHero extends StatelessWidget {
  final double amount;
  final bool paid;
  const _TotalHero({required this.amount, required this.paid});

  @override
  Widget build(BuildContext context) {
    final gradient = paid
        ? const [AppColors.success, Color(0xFF1F9569)]
        : const [AppColors.primary, AppColors.primaryDark];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
                paid
                    ? Icons.verified_rounded
                    : Icons.receipt_long_rounded,
                color: Colors.white,
                size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paid
                      ? AppLocalizations.of(context)!.totalPaidLabel
                      : AppLocalizations.of(context)!.totalToCharge,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.4),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  transitionBuilder: (c, a) =>
                      FadeTransition(opacity: a, child: c),
                  child: Text(
                    '${amount.toStringAsFixed(0)} ₪',
                    key: ValueKey(amount.toStringAsFixed(0)),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTypePicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _ServiceTypePicker(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _serviceTypeKeys.map((type) {
        final isSelected = type == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: type == _serviceTypeKeys.last ? 0 : 10),
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).dividerColor,
                    width: 1.2,
                  ),
                  boxShadow: isSelected ? AppShadows.lifted : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _serviceTypeIcons[type] ?? Icons.handyman_outlined,
                      color: isSelected ? Colors.white : AppColors.ink,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: selected ? color : Theme.of(context).dividerColor,
              width: 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 6)),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color:
                    selected ? Colors.white : AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;
  final String? rate;

  const _CompactField({
    required this.label,
    required this.icon,
    required this.child,
    this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.inkMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.inkMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (rate != null)
                Text(
                  rate!,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _PartsSection extends StatelessWidget {
  final List<ProductData> items;
  final VoidCallback onAdd;
  final ValueChanged<ProductData> onRemove;
  final bool partsPaid;
  final ValueChanged<bool> onPartsPaidChanged;
  final AppLocalizations loc;

  const _PartsSection({
    required this.items,
    required this.onAdd,
    required this.onRemove,
    required this.partsPaid,
    required this.onPartsPaidChanged,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    // Cost-to-me total (what these parts cost YOU, not the client).
    final total =
        items.fold<double>(0, (a, p) => a + (p.price ?? 0));
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Text(loc.product,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(loc.addParts),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6)),
              ),
            ],
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8, left: 26),
              child: Text(
                loc.noPartsAdded,
                style: TextStyle(
                    color: AppColors.inkMuted, fontSize: 12),
              ),
            )
          else ...[
            const SizedBox(height: 6),
            ...items.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(p.name ?? '—',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600))),
                      Text(
                        '${p.price ?? 0} ₪',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 16, color: AppColors.danger),
                        onPressed: () => onRemove(p),
                        constraints: const BoxConstraints(
                            minWidth: 28, minHeight: 28),
                        padding: EdgeInsets.zero,
                        splashRadius: 16,
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('${loc.totalCosts}: ',
                    style: TextStyle(
                        color: AppColors.inkMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text('${total.toStringAsFixed(0)} ₪',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text(loc.paid,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                      value: partsPaid,
                      onChanged: onPartsPaidChanged),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _ExpandableSection({
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.tune_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        Text(subtitle,
                            style: TextStyle(
                                color: AppColors.inkMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded,
                        color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
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
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    value ? accent.withOpacity(0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon,
                  size: 16,
                  color: value ? accent : AppColors.inkMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: AppColors.inkMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── persistence ─────────────────────────────────────────────────────────

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
