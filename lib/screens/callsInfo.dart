import 'package:clientsf/clientdCarsd.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clientsf/l10n/app_localizations.dart';

import '../componenets/alertDialog.dart';

/// Darker orange gradient so white text on the "unpaid" hero stays readable.
const List<Color> _unpaidGradient = [Color(0xFFD9822B), Color(0xFFB4651A)];
const List<Color> _paidGradient = [Color(0xFF22A06B), Color(0xFF1A7F55)];

class ClientServiceScreen extends StatefulWidget {
  /// The call as it was in the list; shown until the live document loads.
  final Map<String, dynamic> call;

  /// Id of the client the call belongs to.
  final String user;

  const ClientServiceScreen(
      {super.key, required this.call, required this.user});

  @override
  State<ClientServiceScreen> createState() => _ClientServiceScreenState();
}

class _ClientServiceScreenState extends State<ClientServiceScreen> {
  late final DocumentReference<Map<String, dynamic>> _callRef =
      clientsCollection()
          .doc(widget.user)
          .collection('calls')
          .doc(widget.call['id'] as String);
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _callStream =
      _callRef.snapshots();

  bool _updating = false;

  Future<void> _update(Map<String, dynamic> fields) async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _updating = true);
    try {
      await _callRef.update(fields);
      showToast(loc.updatedSuccess);
    } catch (e) {
      debugPrint('update call failed: $e');
      showToast(loc.updateFailed);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  void _openEdit(Map<String, dynamic> call) {
    // A regular push: after saving, the user lands back here and the live
    // document shows the edited values.
    Navigator.pushNamed(context, '/action', arguments: {
      'id': call['id'],
      'call': call['call'],
      'type': call['type'],
      'hour': call['hour'],
      'paid': call['paid'],
      'payment': call['payment'],
      'done': call['done'],
      'extraPayment': call['extraPayment'],
      'products': call['products'],
      'usera': widget.user,
      'partsPaid': call['partsPaid'],
      'computerProduct': call['computerProduct'],
      'quantity': call['quantity'],
      'officeVersion': call['officeVersion'],
      'windowsLicense': call['windowsLicense'],
      'officeLicense': call['officeLicense'],
      'inProgress': call['inProgress'],
      'fromScreen1': true,
    });
  }

  void _confirmDelete() {
    final loc = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialogw(
      context,
      onConfirm: () async {
        try {
          await _callRef.delete();
          if (mounted) navigator.pop();
          messenger.showSnackBar(SnackBar(content: Text(loc.callDeleted)));
        } catch (e) {
          debugPrint('delete call failed: $e');
          messenger.showSnackBar(SnackBar(content: Text(loc.deleteFailed)));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _callStream,
      builder: (context, snapshot) {
        final snap = snapshot.data;
        final Map<String, dynamic>? call = snap == null
            ? widget.call
            : (snap.exists ? {...snap.data()!, 'id': snap.id} : null);

        return Scaffold(
          appBar: AppBar(
            title: Text(loc.callDetails),
            actions: call == null
                ? null
                : [
                    IconButton(
                      tooltip: loc.edit,
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () => _openEdit(call),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'delete') _confirmDelete();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.danger),
                              const SizedBox(width: 12),
                              Text(loc.deleteCall,
                                  style:
                                      const TextStyle(color: AppColors.danger)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                  ],
          ),
          body: call == null
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  title: loc.callNotFound,
                  subtitle: '',
                )
              : _buildBody(context, call),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic> call) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final divider = Divider(color: theme.dividerColor, height: 1);

    final List<dynamic> products = call['products'] ?? [];
    final computerProduct = call['computerProduct'];
    final quantity = call['quantity'];
    final officeVersion = call['officeVersion'];
    final windowsLicense = call['windowsLicense'] == true;
    final officeLicense = call['officeLicense'] == true;
    final extraPayment = call['extraPayment'];
    final partsPaid = call['partsPaid'] == true;
    final done = call['done'] == true;
    final inProgress = call['inProgress'] == true;
    final paid = call['paid'] == true;
    final description = (call['call'] ?? '').toString().trim();
    final clientName = (call['clientName'] ?? '').toString();

    final hour = (call['hour'] ?? '').toString();
    final hasHours = hour.isNotEmpty && hour != '0:00' && hour != '0';

    final timestamp = call['timestamp'];
    final createdAt = timestamp is int
        ? DateFormat('d MMMM yyyy, HH:mm', locale)
            .format(DateTime.fromMillisecondsSinceEpoch(timestamp))
        : null;

    final partsTotal = products.fold<double>(0, (sum, p) {
      final v = p['discountedPrice'];
      return sum + (v is num ? v.toDouble() : 0);
    });

    final StatusPill statusPill = done
        ? StatusPill.success(loc.done, icon: Icons.task_alt_rounded)
        : inProgress
            ? StatusPill.info(loc.statusInProgress, icon: Icons.build_rounded)
            : StatusPill(
                label: loc.statusOpen,
                color: scheme.onSurfaceVariant,
                icon: Icons.radio_button_unchecked_rounded);

    final headerParts = [
      if (clientName.isNotEmpty) clientName,
      if (createdAt != null) createdAt,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (headerParts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
              child: Text(
                headerParts.join(' · '),
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500),
              ),
            ),

          // Hero payment summary
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: paid ? _paidGradient : _unpaidGradient,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: (paid ? _paidGradient : _unpaidGradient)
                      .first
                      .withOpacity(0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        paid ? loc.statusPaid : loc.statusPending,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      paid
                          ? Icons.check_circle_outline_rounded
                          : Icons.schedule_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  loc.paymentAmount,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${call['payment'] ?? 0} ₪',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _updating ? null : () => _update({'paid': !paid}),
                  icon: Icon(
                      paid ? Icons.undo_rounded : Icons.payments_outlined,
                      size: 18),
                  label: Text(paid ? loc.markUnpaid : loc.markPaid),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _updating
                      ? null
                      : () => _update(done
                          ? {'done': false}
                          : {'done': true, 'inProgress': false}),
                  icon: Icon(
                      done ? Icons.replay_rounded : Icons.task_alt_rounded,
                      size: 18),
                  label: Text(done ? loc.reopenCall : loc.markDone),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Status chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              statusPill,
              if (partsPaid)
                StatusPill.success(loc.partsPaidLabel,
                    icon: Icons.inventory_2_outlined),
            ],
          ),
          const SizedBox(height: 20),

          // Description, full width and selectable
          _Section(title: loc.description),
          SoftCard(
            padding: const EdgeInsets.all(18),
            child: SelectableText(
              description.isEmpty ? loc.noDescription : description,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: description.isEmpty ? scheme.onSurfaceVariant : null,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // General info
          _Section(title: loc.sectionGeneral),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              children: [
                InfoRow(
                    label: loc.typeofService,
                    value: '${call['type'] ?? '—'}'),
                divider,
                InfoRow(label: loc.sumHours, value: hasHours ? hour : '—'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _Section(title: loc.sectionPayment),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              children: [
                InfoRow(
                  label: loc.paymentStatus,
                  value: paid ? loc.statusPaid : loc.statusPending,
                  valueColor: paid ? AppColors.success : _unpaidGradient.first,
                ),
                if (extraPayment != null && extraPayment != 0) ...[
                  divider,
                  InfoRow(label: loc.extraPayment, value: '$extraPayment ₪'),
                ],
                divider,
                InfoRow(
                  label: loc.partsPaidLabel,
                  value: partsPaid ? loc.yes : loc.no,
                  valueColor:
                      partsPaid ? AppColors.success : scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),

          if (computerProduct != null ||
              officeVersion != null ||
              windowsLicense ||
              officeLicense) ...[
            const SizedBox(height: 20),
            _Section(title: loc.sectionAdditional),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Column(
                children: [
                  if (computerProduct != null) ...[
                    InfoRow(
                        label: loc.selectProduct, value: '$computerProduct'),
                    if (quantity != null)
                      InfoRow(label: loc.quantity, value: '$quantity'),
                  ],
                  if (officeVersion != null)
                    InfoRow(label: loc.officeVersion, value: '$officeVersion'),
                  if (windowsLicense)
                    InfoRow(
                        label: loc.windowsLicense,
                        value: loc.yes,
                        valueColor: AppColors.success),
                  if (officeLicense)
                    InfoRow(
                        label: loc.officeLicense,
                        value: loc.yes,
                        valueColor: AppColors.success),
                ],
              ),
            ),
          ],

          if (products.isNotEmpty) ...[
            const SizedBox(height: 20),
            _Section(title: loc.products),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                children: [
                  for (var i = 0; i < products.length; i++) ...[
                    if (i > 0) divider,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              products[i]['name'] ?? '',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${products[i]['discountedPrice'] ?? 0} ₪',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (products.length > 1) ...[
                    Divider(color: theme.dividerColor, height: 1, thickness: 1.5),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(loc.partsTotal,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurfaceVariant)),
                          ),
                          Text(
                            '${partsTotal.toStringAsFixed(partsTotal.truncateToDouble() == partsTotal ? 0 : 2)} ₪',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 6, end: 6, bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
