import 'dart:convert';
import 'dart:io';

import 'package:clientsf/objects/clients.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../clientdCarsd.dart';
import '../componenets/alertDialog.dart';
import 'actions.dart';
import 'callsInfo.dart';

enum _PaidFilter { all, paid, unpaid }

/// Profit shown per call: what the client paid (extraPayment) minus the cost
/// of parts. Computed on display so old records with the legacy formula are
/// corrected too.
double _callProfit(Map<String, dynamic> call) {
  final extraNum = call['extraPayment'];
  final extra = extraNum is num
      ? extraNum.toDouble()
      : double.tryParse(extraNum?.toString() ?? '') ?? 0;
  // Parts cost = "מחיר עלות" (cost-to-me) stored as 'price', not 'discountedPrice'.
  final partsCost = (call['products'] as List?)?.fold<double>(0, (a, p) {
        final d = p['price'];
        return a + (d is num ? d.toDouble() : 0);
      }) ??
      0;
  return extra - partsCost;
}

String _money(double v) =>
    '${v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1)} ₪';

class CallsScreen extends StatefulWidget {
  final Todo clientId;
  const CallsScreen({super.key, required this.clientId});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  _PaidFilter _filter = _PaidFilter.all;
  bool _isDescending = true;
  bool _exporting = false;

  late final CollectionReference<Map<String, dynamic>> _callsRef =
      clientsCollection().doc(widget.clientId.id).collection('calls');

  /// One live subscription for the whole screen. Filtering and sorting are
  /// done in memory: a client has few calls, and a where+orderBy query would
  /// need a composite Firestore index (and would skip calls with paid == null).
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _callsStream =
      _callsRef.snapshots();

  bool _isPaid(Map<String, dynamic> c) => c['paid'] == true;

  int _timestamp(Map<String, dynamic> c) {
    final t = c['timestamp'];
    return t is int ? t : 0;
  }

  Future<void> _export(List<Map<String, dynamic>> calls) async {
    final loc = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final box = context.findRenderObject() as RenderBox?;
    setState(() => _exporting = true);
    try {
      final dateFmt = DateFormat('dd/MM/yyyy HH:mm', locale);
      final rows = <List<dynamic>>[
        [
          loc.csvDate,
          loc.csvDescription,
          loc.csvType,
          loc.status,
          loc.csvPaid,
          loc.csvProfit,
          loc.extraPayment,
          loc.csvHours,
        ],
        for (final c in calls)
          [
            _timestamp(c) == 0
                ? ''
                : dateFmt.format(
                    DateTime.fromMillisecondsSinceEpoch(_timestamp(c))),
            c['call'] ?? '',
            c['type'] ?? '',
            _statusLabel(loc, c),
            _isPaid(c) ? loc.statusPaid : loc.statusPending,
            _callProfit(c),
            c['extraPayment'] ?? '',
            c['hour'] ?? '',
          ],
      ];
      // BOM so Excel opens the Hebrew text as UTF-8.
      final csv = '﻿${const ListToCsvConverter().convert(rows)}';

      final dir = await getTemporaryDirectory();
      final safeName = (widget.clientId.name ?? 'client')
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final file = File('${dir.path}/$safeName-calls.csv');
      await file.writeAsString(csv, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: '${loc.callsHistory} - ${widget.clientId.name ?? ''}',
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      debugPrint('export failed: $e');
      showToast(loc.exportFailed);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final clientName = widget.clientId.name ?? '';
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _callsStream,
      builder: (context, snapshot) {
        final all = snapshot.data?.docs
                .map((d) => {...d.data(), 'id': d.data()['id'] ?? d.id})
                .toList() ??
            <Map<String, dynamic>>[];

        final paidCount = all.where(_isPaid).length;
        final unpaid = all.where((c) => !_isPaid(c)).toList();
        final outstanding = unpaid.fold<double>(0, (sum, c) {
          final p = c['payment'];
          return sum + (p is num ? p.toDouble() : 0);
        });

        final visible = all.where((c) {
          switch (_filter) {
            case _PaidFilter.all:
              return true;
            case _PaidFilter.paid:
              return _isPaid(c);
            case _PaidFilter.unpaid:
              return !_isPaid(c);
          }
        }).toList()
          ..sort((a, b) => _isDescending
              ? _timestamp(b).compareTo(_timestamp(a))
              : _timestamp(a).compareTo(_timestamp(b)));

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.callsHistory,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                Text(
                  clientName,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: muted),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: loc.export,
                onPressed: (_exporting || all.isEmpty)
                    ? null
                    : () => _export(visible),
                icon: _exporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.ios_share_rounded),
              ),
              const SizedBox(width: 4),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => actions(user: widget.clientId)),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(loc.openTicket),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: _BalanceCard(
                  label: loc.ramainingBalance,
                  amount: snapshot.hasData ? outstanding : null,
                  caption: snapshot.hasData && unpaid.isNotEmpty
                      ? loc.unpaidCallsCount(unpaid.length)
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: '${loc.all} (${all.length})',
                              selected: _filter == _PaidFilter.all,
                              onTap: () =>
                                  setState(() => _filter = _PaidFilter.all),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: '${loc.statusPaid} ($paidCount)',
                              selected: _filter == _PaidFilter.paid,
                              onTap: () =>
                                  setState(() => _filter = _PaidFilter.paid),
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: '${loc.statusPending} (${unpaid.length})',
                              selected: _filter == _PaidFilter.unpaid,
                              onTap: () =>
                                  setState(() => _filter = _PaidFilter.unpaid),
                              color: AppColors.warning,
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _isDescending = !_isDescending),
                      icon: Icon(
                        _isDescending
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        size: 16,
                      ),
                      label: Text(
                        _isDescending ? loc.sortNewest : loc.sortOldest,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildList(context, snapshot, visible)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    List<Map<String, dynamic>> visible,
  ) {
    final loc = AppLocalizations.of(context)!;
    if (snapshot.hasError) {
      debugPrint('calls query error: ${snapshot.error}');
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: loc.loadCallsError,
        subtitle: loc.authNetworkError,
      );
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.history_rounded,
        title: loc.noCallsYet,
        subtitle: loc.noCallsHint,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: visible.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _CallTile(
        call: visible[index],
        callsRef: _callsRef,
        clientId: widget.clientId.id,
      ),
    );
  }
}

String _statusLabel(AppLocalizations loc, Map<String, dynamic> c) {
  if (c['done'] == true) return loc.done;
  if (c['inProgress'] == true) return loc.statusInProgress;
  return loc.statusOpen;
}

class _BalanceCard extends StatelessWidget {
  final String label;
  final double? amount;
  final String? caption;
  const _BalanceCard({required this.label, required this.amount, this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                if (amount == null)
                  const SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                else
                  Text(
                    '${amount!.toStringAsFixed(2)} ₪',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6),
                  ),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(caption!,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.primary;
    return Material(
      color: selected ? c : scheme.surface,
      shape: StadiumBorder(
          side: BorderSide(
              color: selected ? c : Theme.of(context).dividerColor)),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : scheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _CallTile extends StatelessWidget {
  final Map<String, dynamic> call;
  final CollectionReference<Map<String, dynamic>> callsRef;
  final String clientId;
  const _CallTile({
    required this.call,
    required this.callsRef,
    required this.clientId,
  });

  void _confirmDelete(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    showDialogw(
      context,
      onConfirm: () async {
        try {
          await callsRef.doc(call['id'] as String).delete();
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).toString();

    final callDetails = (call['call'] ?? '').toString();
    final paid = call['paid'] == true;
    final timestamp = call['timestamp'];
    final profit = _callProfit(call);

    final date =
        timestamp is int ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    final formattedDate =
        date != null ? DateFormat('d MMM', locale).format(date) : '—';
    final formattedYear =
        date != null ? DateFormat('yyyy', locale).format(date) : '';

    final StatusPill statusPill;
    if (call['done'] == true) {
      statusPill = StatusPill.info(loc.done, icon: Icons.task_alt_rounded);
    } else if (call['inProgress'] == true) {
      statusPill = StatusPill(
          label: loc.statusInProgress,
          color: scheme.primary,
          icon: Icons.build_rounded);
    } else {
      statusPill = StatusPill(
          label: loc.statusOpen,
          color: scheme.onSurfaceVariant,
          icon: Icons.radio_button_unchecked_rounded);
    }

    return Slidable(
      key: ValueKey(call['id']),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.24,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Builder(
              builder: (slidableContext) => Material(
                color: AppColors.danger.withOpacity(isDark ? 0.18 : 0.10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  side: BorderSide(color: AppColors.danger.withOpacity(0.2)),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Slidable.of(slidableContext)?.close();
                    _confirmDelete(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline_rounded,
                          color: AppColors.danger),
                      const SizedBox(height: 4),
                      Text(loc.delete,
                          style: const TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClientServiceScreen(call: call, user: clientId),
          ),
        ),
        child: Row(
          children: [
            // Date column
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary),
                  ),
                  if (formattedYear.isNotEmpty)
                    Text(formattedYear,
                        style: TextStyle(
                            fontSize: 10,
                            color: scheme.primary.withOpacity(0.75))),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    callDetails.isEmpty ? loc.noDescription : callDetails,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      statusPill,
                      if (paid)
                        StatusPill.success(loc.statusPaid,
                            icon: Icons.check_rounded)
                      else
                        StatusPill.warning(loc.statusPending,
                            icon: Icons.schedule_rounded),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _money(profit),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: paid ? scheme.onSurface : AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
