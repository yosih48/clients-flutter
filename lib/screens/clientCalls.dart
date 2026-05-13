import 'package:clientsf/objects/clients.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import '../componenets/alertDialog.dart';
import 'callsInfo.dart';

class CallsScreen extends StatefulWidget {
  final Todo clientId;
  const CallsScreen({super.key, required this.clientId});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  String _filter = 'both'; // both | paid | notpaid
  bool _isDescending = true;

  Future<double> fetchOutstandingTotal() async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_data')
        .doc(widget.clientId.id)
        .collection('calls');
    final qs = await ref.get();
    return qs.docs.fold<double>(0, (prev, d) {
      final payment = d['payment'];
      final paid = d['paid'];
      return prev +
          ((paid == false && payment != null)
              ? (payment as num).toDouble()
              : 0);
    });
  }

  bool? _getFilterValue() {
    if (_filter == 'paid') return true;
    if (_filter == 'notpaid') return false;
    return null;
  }

  Future<List<dynamic>> fetchCallsData() async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_data')
        .doc(widget.clientId.id)
        .collection('calls');
    final qs = await ref.get();
    return qs.docs.map((doc) => doc.data()).toList();
  }

  void _generateCsvFile(List<dynamic> data) async {
    await [Permission.storage].request();
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.exportComplete),
        content: Text(loc.exportSuccessMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getCallsStream() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_data')
        .doc(widget.clientId.id)
        .collection('calls');

    if (_filter != 'both') {
      query = query.where('paid', isEqualTo: _getFilterValue());
    }
    return query.orderBy('timestamp', descending: _isDescending).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final clientName = widget.clientId.name ?? '';

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
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isDescending ? loc.newestFirst : loc.oldestFirst,
            icon: Icon(
              _isDescending
                  ? Icons.south_rounded
                  : Icons.north_rounded,
            ),
            onPressed: () =>
                setState(() => _isDescending = !_isDescending),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Outstanding balance card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: _BalanceCard(
              label: loc.ramainingBalance,
              future: fetchOutstandingTotal(),
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _FilterChip(
                  label: loc.all,
                  selected: _filter == 'both',
                  onTap: () => setState(() => _filter = 'both'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: loc.statusPaid,
                  selected: _filter == 'paid',
                  onTap: () => setState(() => _filter = 'paid'),
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: loc.statusPending,
                  selected: _filter == 'notpaid',
                  onTap: () => setState(() => _filter = 'notpaid'),
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getCallsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final calls = snapshot.data!.docs;
                if (calls.isEmpty) {
                  return EmptyState(
                    icon: Icons.history_rounded,
                    title: loc.noCallsYet,
                    subtitle: loc.noCallsHint,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  itemCount: calls.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final call = calls[index].data() as Map<String, dynamic>;
                    return _CallTile(
                      call: call,
                      clientId: widget.clientId.id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final data = await fetchCallsData();
          _generateCsvFile(data);
        },
        icon: const Icon(Icons.file_download_outlined),
        label: Text(loc.export),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String label;
  final Future<double> future;
  const _BalanceCard({required this.label, required this.future});

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
                FutureBuilder<double>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 26,
                        width: 26,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      );
                    }
                    final total = snapshot.data ?? 0.0;
                    return Text(
                      '${total.toStringAsFixed(2)} ₪',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6),
                    );
                  },
                ),
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
    final c = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? c : Theme.of(context).colorScheme.surface,
          border: Border.all(
              color: selected ? c : Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CallTile extends StatelessWidget {
  final Map<String, dynamic> call;
  final String clientId;
  const _CallTile({required this.call, required this.clientId});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final callDetails = call['call'] ?? '';
    final paid = call['paid'] ?? false;
    final timestamp = call['timestamp'];

    // Display the actual profit: what the client paid (extraPayment) minus
    // the cost of parts. Computed on display so old records with the legacy
    // formula are corrected too.
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
    final profit = extra - partsCost;
    final formattedDate = timestamp != null
        ? DateFormat('dd MMM').format(
            DateTime.fromMillisecondsSinceEpoch(timestamp))
        : '—';
    final formattedYear = timestamp != null
        ? DateFormat('yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(timestamp))
        : '';

    return Slidable(
      key: ValueKey(call['id']),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.24,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => showDialogw(
                context,
                onConfirm: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('user_data')
                      .doc(clientId)
                      .collection('calls')
                      .doc(call['id'])
                      .delete();
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                      color: AppColors.danger.withOpacity(0.2)),
                ),
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
        ],
      ),
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ClientServiceScreen(call: call, user: clientId),
          ),
        ),
        child: Row(
          children: [
            // Date column
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withOpacity(0.6),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                  if (formattedYear.isNotEmpty)
                    Text(formattedYear,
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary.withOpacity(0.7))),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    callDetails.toString().isEmpty
                        ? loc.noDescription
                        : callDetails,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
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
              '${profit.toStringAsFixed(profit.truncateToDouble() == profit ? 0 : 1)} ₪',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: paid ? AppColors.ink : AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
