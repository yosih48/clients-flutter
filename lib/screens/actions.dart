import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../componenets/alertDialog.dart';
import '../componenets/hourly_rate.dart';
import '../componenets/parts.dart';
import '../componenets/service_types.dart';
import '../objects/clients.dart';
import 'package:clientsf/l10n/app_localizations.dart';

import '../services/airtable_service.dart';

const List<String> _serviceTypeKeys = [
  serviceRemote,
  serviceEquipmentSale,
  serviceAtClient,
];

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
  String _serviceType = serviceRemote;
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

  bool _saving = false;
  bool _descriptionError = false;

  /// Set once the form was saved, so the unsaved-changes guard lets it close.
  bool _allowPop = false;

  /// Snapshot of the form when it opened, to detect unsaved changes.
  late String _initialSnapshot;

  @override
  void initState() {
    super.initState();
    final data = widget.data;
    if (data.isNotEmpty) {
      _serviceType = data['type'] ?? _serviceTypeKeys.first;
      _detailsCtrl.text = data['call'] ?? '';
      _paid = data['paid'] ?? false;
      _done = data['done'] == true;
      // A call is either in progress or done, never both.
      _inProgress = !_done && data['inProgress'] == true;
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
        _extraPayCtrl.text = _formatAmount(data['extraPayment']);
      }

      if (data.containsKey('products') &&
          (data['products'] as List).isNotEmpty) {
        _productList = (data['products'] as List<dynamic>)
            .map<ProductData>(ProductData.fromDynamic)
            .toList();
      }

      // Auto-expand advanced if any advanced field is set
      _showAdvanced = _selectedComputerProduct != null ||
          _selectedOfficeVersion != null ||
          _windowsLicense ||
          _officeLicense ||
          _quantityCtrl.text.isNotEmpty;
    }
    if (!_serviceTypeKeys.contains(_serviceType)) {
      _serviceType = _serviceTypeKeys.first;
    }

    _initialSnapshot = _snapshot();
    _loadHourlyRate();
    _fetchComputerModels();
  }

  static String _formatAmount(dynamic v) {
    if (v is num) {
      return v == v.truncate() ? v.toInt().toString() : v.toString();
    }
    return v.toString();
  }

  String _snapshot() => [
        _serviceType,
        _paid,
        _done,
        _inProgress,
        _partsPaid,
        _detailsCtrl.text,
        _extraPayCtrl.text,
        _quantityCtrl.text,
        _timeCtrl.text,
        _selectedComputerProduct,
        _selectedOfficeVersion,
        _windowsLicense,
        _officeLicense,
        for (final p in _productList)
          '${p.name}|${p.price}|${p.discountedPrice}',
      ].join('§');

  bool get _isDirty => _snapshot() != _initialSnapshot;

  @override
  void dispose() {
    _detailsCtrl.dispose();
    _extraPayCtrl.dispose();
    _quantityCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHourlyRate() async {
    final rate = await loadHourlyRate();
    if (mounted) setState(() => _hourlyRate = rate);
  }

  Future<void> _fetchComputerModels() async {
    final models = await AirtableService().fetchComputerModels();
    if (mounted) setState(() => computerModels = models);
  }

  bool get _showTime => _serviceType != serviceEquipmentSale;

  /// Billable hours: any started hour counts as a full hour.
  int get _billableHours {
    if (!_showTime) return 0;
    final d = _parseDuration(_timeCtrl.text);
    return d.inHours + (d.inMinutes % 60 > 0 ? 1 : 0);
  }

  double get _extra => double.tryParse(_extraPayCtrl.text) ?? 0;

  // Parts cost = "מחיר עלות" (the cost-to-me), stored on ProductData.price.
  double get _partsCost =>
      _productList.fold<double>(0, (a, p) => a + (p.price ?? 0));

  // Profit = what the client pays (extra) + hourly work − cost of parts.
  double get _liveTotal => _extra + _billableHours * _hourlyRate - _partsCost;

  static Duration _parseDuration(String text) {
    final parts = text.split(':');
    final h = int.tryParse(parts.first) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return Duration(hours: h, minutes: m);
  }

  /// Picks how long the work took (a duration, not a time of day).
  Future<void> _pickDuration() async {
    final loc = AppLocalizations.of(context)!;
    var picked = _parseDuration(_timeCtrl.text);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.workDuration, style: Theme.of(ctx).textTheme.titleMedium),
            SizedBox(
              height: 200,
              child: CupertinoTheme(
                data: CupertinoThemeData(brightness: Theme.of(ctx).brightness),
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  minuteInterval: 5,
                  initialTimerDuration:
                      Duration(minutes: (picked.inMinutes ~/ 5) * 5),
                  onTimerDurationChanged: (d) => picked = d,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(loc.ok),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      setState(() => _timeCtrl.text =
          '${picked.inHours}:${(picked.inMinutes % 60).toString().padLeft(2, '0')}');
    }
  }

  Future<void> _openProductDialog() async {
    // Parts typed in the dialog are only added when the user taps "Add".
    List<ProductData> pending = [];
    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(loc.addParts),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: ProductForm(
                  onProductListChanged: (updated) => pending = updated),
            ),
          ),
          actions: [
            OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(loc.cancel)),
            ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(loc.add)),
          ],
        );
      },
    );
    if (added != true) return;
    final valid = pending.where((p) =>
        (p.name ?? '').trim().isNotEmpty ||
        (p.price ?? 0) != 0 ||
        (p.discountedPrice ?? 0) != 0);
    setState(() => _productList.addAll(valid));
  }

  Future<void> _save(AppLocalizations loc) async {
    if (_detailsCtrl.text.trim().isEmpty) {
      setState(() => _descriptionError = true);
      return;
    }

    final timeText = _showTime ? _timeCtrl.text : '0:00';
    // An empty field means no extra charge. (It used to fall back to the old
    // 'payment', which re-added hours and re-subtracted parts on every save.)
    final extra = _extra;
    final totalPayment = _liveTotal;

    setState(() => _saving = true);
    final Future<void> write;
    if (widget.data.isEmpty) {
      write = addCall(
        widget.user,
        _detailsCtrl.text.trim(),
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
      write = updateUser(
        widget.data['usera'],
        widget.data['id'],
        _detailsCtrl.text.trim(),
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

    try {
      // Offline, Firestore only completes the write once it reaches the
      // server; it is already queued locally, so don't block on it forever.
      await write.timeout(const Duration(seconds: 8));
      showToast(loc.updatedSuccess);
    } on TimeoutException {
      showToast(loc.savedWillSync);
    } catch (e) {
      debugPrint('save call failed: $e');
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.saveFailed)));
      }
      return;
    }

    if (!mounted) return;
    _closeForm();
  }

  /// Lets the unsaved-changes guard rebuild as "can pop" before popping.
  void _closeForm() {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _onPopBlocked() async {
    final loc = AppLocalizations.of(context)!;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.discardChangesTitle),
        content: Text(loc.discardChangesBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.keepEditing)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(loc.discard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) _closeForm();
  }

  /// "Extra 200 + 2h × 150 − Parts 80", shown under the hero total.
  String _breakdown(AppLocalizations loc) {
    final parts = <String>[];
    if (_extra != 0) parts.add('${loc.extraPayment} ${_formatAmount(_extra)}');
    if (_billableHours > 0 && _hourlyRate > 0) {
      parts.add('+ ${loc.hoursShort(_billableHours)} × $_hourlyRate');
    }
    if (_partsCost != 0) {
      parts.add('− ${loc.totalCosts} ${_formatAmount(_partsCost)}');
    }
    return parts.join('  ');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final _CallStatus status = _done
        ? _CallStatus.done
        : (_inProgress ? _CallStatus.inProgress : _CallStatus.open);

    // Computer models come from Airtable; keep the saved choice selectable
    // even before they load or if it was removed there.
    final modelKeys = computerModels.map((m) => m['key']).toSet();
    final missingSelected = _selectedComputerProduct != null &&
        !modelKeys.contains(_selectedComputerProduct);

    return PopScope(
      canPop: _allowPop || !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onPopBlocked();
      },
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                // 1. Live total hero
                _TotalHero(
                  amount: _liveTotal,
                  paid: _paid,
                  breakdown: _breakdown(loc),
                ),
                const SizedBox(height: 20),

                // 2. Service type picker
                _SectionLabel(loc.serviceType),
                _ServiceTypePicker(
                  selected: _serviceType,
                  onChanged: (v) => setState(() => _serviceType = v),
                ),
                const SizedBox(height: 24),

                // 3. Status: one of open / in progress / done, plus paid
                _SectionLabel(loc.status),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<_CallStatus>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: _CallStatus.open,
                        label: Text(loc.statusOpen),
                        icon: const Icon(Icons.radio_button_unchecked_rounded,
                            size: 16),
                      ),
                      ButtonSegment(
                        value: _CallStatus.inProgress,
                        label: Text(loc.statusInProgress),
                        icon: const Icon(Icons.build_rounded, size: 16),
                      ),
                      ButtonSegment(
                        value: _CallStatus.done,
                        label: Text(loc.done),
                        icon: const Icon(Icons.task_alt_rounded, size: 16),
                      ),
                    ],
                    selected: {status},
                    onSelectionChanged: (s) => setState(() {
                      _done = s.first == _CallStatus.done;
                      _inProgress = s.first == _CallStatus.inProgress;
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                SoftCard(
                  padding: EdgeInsets.zero,
                  child: _ToggleRow(
                    icon: Icons.payments_outlined,
                    label: loc.statusPaid,
                    value: _paid,
                    accent: AppColors.success,
                    onChanged: (v) => setState(() => _paid = v),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Description
                _SectionLabel(loc.calldescription),
                SoftCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: TextField(
                    controller: _detailsCtrl,
                    maxLines: 5,
                    minLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {
                      if (_descriptionError) _descriptionError = false;
                    }),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      hintText: loc.descriptionHint,
                      errorText:
                          _descriptionError ? loc.descriptionRequired : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Work duration (conditional) + extra payment side-by-side
                Row(
                  children: [
                    if (_showTime) ...[
                      Expanded(
                        child: _CompactField(
                          label: loc.workDuration,
                          icon: Icons.timer_outlined,
                          onTap: _pickDuration,
                          rate: _hourlyRate > 0
                              ? loc.perHourRate(_hourlyRate)
                              : null,
                          child: Text(
                            _timeCtrl.text,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
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
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
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
                  onRemove: (p) => setState(() => _productList.remove(p)),
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
                        items: [
                          if (missingSelected)
                            DropdownMenuItem<String>(
                              value: _selectedComputerProduct,
                              child: Text(
                                  _computerLabel(loc, _selectedComputerProduct!),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ...computerModels.map((model) {
                            return DropdownMenuItem<String>(
                              value: model['key'],
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      child: Text(
                                          _computerLabel(loc, model['key']),
                                          overflow: TextOverflow.ellipsis)),
                                  Text('${model['price']} ₪',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: scheme.primary)),
                                ],
                              ),
                            );
                          }),
                        ],
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
                        onChanged: (_) => setState(() {}),
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
                        items: {
                          ..._officeVersions,
                          if (_selectedOfficeVersion != null)
                            _selectedOfficeVersion!,
                        }
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
                              accent: scheme.primary,
                              onChanged: (v) =>
                                  setState(() => _windowsLicense = v),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: Divider(
                                  height: 1,
                                  color: Theme.of(context).dividerColor),
                            ),
                            _ToggleRow(
                              icon: Icons.workspaces_outline,
                              label: loc.officeLicense,
                              value: _officeLicense,
                              accent: scheme.primary,
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
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
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
                      icon: _saving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: scheme.onPrimary),
                            )
                          : const Icon(Icons.check_rounded, size: 20),
                      label:
                          Text(widget.isEdit ? loc.saveChanges : loc.save),
                      onPressed: _saving ? null : () => _save(loc),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _computerLabel(AppLocalizations loc, String key) {
    switch (key) {
      case 'miniDell':
        return loc.miniDell;
      case 'hpI5':
        return loc.hpI5;
      case 'lenovoI7':
        return loc.lenovoI7;
      case 'macMini':
        return loc.macMini;
      default:
        return key;
    }
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

enum _CallStatus { open, inProgress, done }

class _TotalHero extends StatelessWidget {
  final double amount;
  final bool paid;
  final String breakdown;
  const _TotalHero(
      {required this.amount, required this.paid, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final gradient = paid
        ? const [Color(0xFF22A06B), Color(0xFF1A7F55)]
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
                paid ? Icons.verified_rounded : Icons.receipt_long_rounded,
                color: Colors.white,
                size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paid ? loc.totalPaidLabel : loc.totalToCharge,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5),
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
                if (breakdown.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    breakdown,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
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
  const _ServiceTypePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: _serviceTypeKeys.map((type) {
        final isSelected = type == selected;
        final fg = isSelected ? Colors.white : scheme.onSurface;
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
                end: type == _serviceTypeKeys.last ? 0 : 10),
            child: Material(
              color: isSelected ? scheme.primary : scheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(
                  color: isSelected ? scheme.primary : Theme.of(context).dividerColor,
                  width: 1.2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(type),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(serviceTypeIcon(type), color: fg, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        serviceTypeLabel(loc, type),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CompactField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;
  final String? rate;
  final VoidCallback? onTap;

  const _CompactField({
    required this.label,
    required this.icon,
    required this.child,
    this.rate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (rate != null)
                Text(
                  rate!,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 11.5,
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
    final scheme = Theme.of(context).colorScheme;
    // Cost-to-me total (what these parts cost YOU, not the client).
    final total = items.fold<double>(0, (a, p) => a + (p.price ?? 0));
    return SoftCard(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  color: Color(0xFFD9822B), size: 18),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
              ),
            ],
          ),
          if (items.isEmpty)
            Padding(
              padding:
                  const EdgeInsetsDirectional.only(top: 4, bottom: 8, start: 26),
              child: Text(
                loc.noPartsAdded,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
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
                            color: AppColors.accent, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(
                              (p.name ?? '').isEmpty ? '—' : p.name!,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600))),
                      Text(
                        '${p.price ?? 0} ₪',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      IconButton(
                        tooltip: loc.delete,
                        icon: const Icon(Icons.close_rounded,
                            size: 16, color: AppColors.danger),
                        onPressed: () => onRemove(p),
                        constraints:
                            const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: EdgeInsets.zero,
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
                        color: scheme.onSurfaceVariant,
                        fontSize: 12.5,
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
                  child:
                      Switch(value: partsPaid, onChanged: onPartsPaidChanged),
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
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 14, 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child:
                        Icon(Icons.tune_rounded, color: scheme.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        Text(subtitle,
                            style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more_rounded,
                        color: scheme.onSurfaceVariant),
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
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: value ? accent.withOpacity(0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon,
                  size: 16, color: value ? accent : scheme.onSurfaceVariant),
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
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
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
    rethrow;
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
    rethrow;
  }
}
