import 'package:clientsf/l10n/app_localizations.dart';
import 'package:clientsf/objects/clients.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../componenets/tableData.dart';
import 'clientCalls.dart';

class DataTableExample extends StatefulWidget {
  const DataTableExample({Key? key}) : super(key: key);

  @override
  State<DataTableExample> createState() => _DataTableExampleState();
}

class _DataTableExampleState extends State<DataTableExample> {
  late DateTime _currentMonth;
  bool _showAllTime = false;

  /// One entry per client (keyed by id, so clients sharing a name stay apart).
  List<ClientStats> _stats = [];

  /// Net profit of the month before [_currentMonth], for the trend badge.
  double? _previousNet;

  bool _isLoading = false;
  bool _hasError = false;

  /// Incremented on every load; results of an outdated load are dropped so
  /// quickly switching months can't show another month's numbers.
  int _loadToken = 0;

  DateTime get _thisMonth =>
      DateTime(DateTime.now().year, DateTime.now().month);

  bool get _isCurrentMonth =>
      _currentMonth.year == _thisMonth.year &&
      _currentMonth.month == _thisMonth.month;

  @override
  void initState() {
    super.initState();
    _currentMonth = _thisMonth;
    _loadData();
  }

  Future<void> _loadData() async {
    final token = ++_loadToken;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final monthStart = DateTime(_currentMonth.year, _currentMonth.month);
    final monthEnd = DateTime(_currentMonth.year, _currentMonth.month + 1);
    final prevStart = DateTime(_currentMonth.year, _currentMonth.month - 1);
    final startMs = monthStart.millisecondsSinceEpoch;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final clientsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_data')
          .get();

      double prevNet = 0;
      final futures = clientsSnapshot.docs.map((clientDoc) async {
        final data = clientDoc.data();
        final client = Todo(
          id: clientDoc.id,
          name: data['name'],
          email: data['email'],
          address: data['address'],
          phone: data['phone'],
          completed: false,
        );
        final callsCollection = clientDoc.reference.collection('calls');

        if (_showAllTime) {
          final calls = await callsCollection.get();
          return _processClientCalls(
              client, calls.docs.map((d) => d.data()).toList());
        }

        // One query covering this month and the previous one; split locally.
        final calls = await callsCollection
            .where('timestamp',
                isGreaterThanOrEqualTo: prevStart.millisecondsSinceEpoch)
            .where('timestamp', isLessThan: monthEnd.millisecondsSinceEpoch)
            .get();
        final current = <Map<String, dynamic>>[];
        final previous = <Map<String, dynamic>>[];
        for (final d in calls.docs) {
          final t = d.data()['timestamp'];
          ((t is int && t >= startMs) ? current : previous).add(d.data());
        }
        prevNet += _processClientCalls(client, previous)?.netProfit ?? 0;
        return _processClientCalls(client, current);
      });

      final results = await Future.wait(futures);
      if (token != _loadToken || !mounted) return;

      setState(() {
        _stats = results.whereType<ClientStats>().toList();
        _previousNet = _showAllTime ? null : prevNet;
      });
    } catch (e, st) {
      debugPrint('Error loading income data: $e\n$st');
      if (token == _loadToken && mounted) setState(() => _hasError = true);
    } finally {
      if (token == _loadToken && mounted) setState(() => _isLoading = false);
    }
  }

  /// Amounts are unchanged from the previous version of this screen:
  /// paid = extraPayment of paid calls, pending = extraPayment of unpaid
  /// calls, net = paid − parts cost of paid calls.
  ClientStats? _processClientCalls(
      Todo client, List<Map<String, dynamic>> calls) {
    if (calls.isEmpty) return null;

    double totalPaidGross = 0;
    double totalUnpaidGross = 0;
    double paidPartsCost = 0;

    double asDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

    for (final data in calls) {
      final bool paid = data['paid'] == true;
      final double extra = asDouble(data['extraPayment']);
      final List products = (data['products'] as List<dynamic>?) ?? [];
      // Parts cost = what the parts cost ME ("מחיר עלות" → 'price'),
      // not what I charged the client for them ('discountedPrice').
      final double partsCost =
          products.fold<double>(0, (a, p) => a + asDouble(p['price']));

      if (paid) {
        totalPaidGross += extra;
        paidPartsCost += partsCost;
      } else {
        totalUnpaidGross += extra;
      }
    }

    return ClientStats(
      client: client,
      totalPayment: totalPaidGross,
      totalNotPaid: totalUnpaidGross,
      netProfit: totalPaidGross - paidPartsCost,
    );
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: _thisMonth,
    );
    if (picked != null) {
      setState(() => _currentMonth = DateTime(picked.year, picked.month));
      _loadData();
    }
  }

  void _changeMonth(int offset) {
    final next = DateTime(_currentMonth.year, _currentMonth.month + offset);
    if (next.isAfter(_thisMonth)) return;
    setState(() => _currentMonth = next);
    _loadData();
  }

  void _setAllTime(bool allTime) {
    if (allTime == _showAllTime) return;
    setState(() => _showAllTime = allTime);
    _loadData();
  }

  double get _paidTotal => _stats.fold(0, (a, s) => a + s.totalPayment);
  double get _outstandingTotal => _stats.fold(0, (a, s) => a + s.totalNotPaid);
  double get _netProfitTotal => _stats.fold(0, (a, s) => a + s.netProfit);

  /// Percent change of net profit vs. the previous month, or null when there
  /// is nothing meaningful to compare with.
  double? get _netTrend {
    final prev = _previousNet;
    if (prev == null || prev == 0) return null;
    return (_netProfitTotal - prev) / prev.abs() * 100;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    Widget content;
    if (_isLoading && _stats.isEmpty) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_hasError) {
      content = EmptyState(
        icon: Icons.error_outline_rounded,
        title: loc.couldNotLoadData,
        subtitle: loc.authNetworkError,
      );
    } else if (_stats.isEmpty) {
      content = EmptyState(
        icon: Icons.bar_chart_rounded,
        title: _showAllTime
            ? loc.noDataAllTime
            : loc.noDataForMonth(
                DateFormat('MMMM yyyy', locale).format(_currentMonth)),
      );
    } else {
      content = DataTableWidget(
        stats: _stats,
        onClientTap: (client) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CallsScreen(clientId: client)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc.incomeTable)),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildFilterBar(locale)),
            if (_isLoading && _stats.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              ),
            if (!_hasError && _stats.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: loc.statusPaid,
                          value: _paidTotal,
                          icon: Icons.check_circle_outline_rounded,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: loc.totalToCharge,
                          value: _outstandingTotal,
                          icon: Icons.schedule_rounded,
                          color: const Color(0xFFD9822B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: loc.net,
                          value: _netProfitTotal,
                          icon: Icons.trending_up_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          trend: _netTrend,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(String locale) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final monthLabel = DateFormat('MMMM yyyy', locale).format(_currentMonth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                    value: false,
                    label: Text(loc.periodMonthly),
                    icon: const Icon(Icons.calendar_month_rounded, size: 18)),
                ButtonSegment(
                    value: true,
                    label: Text(loc.periodAllTime),
                    icon: const Icon(Icons.all_inclusive_rounded, size: 18)),
              ],
              selected: {_showAllTime},
              onSelectionChanged: (s) => _setAllTime(s.first),
            ),
          ),
          if (!_showAllTime) ...[
            const SizedBox(height: 10),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _changeMonth(-1),
                    tooltip: loc.previousMonth,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _pickMonth,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                size: 18, color: scheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              monthLabel,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CircleIconButton(
                    icon: Icons.chevron_right_rounded,
                    color: _isCurrentMonth
                        ? scheme.onSurface.withOpacity(0.3)
                        : null,
                    onTap: _isCurrentMonth ? null : () => _changeMonth(1),
                    tooltip: loc.nextMonth,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final double? trend;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final formatted = NumberFormat.decimalPattern().format(
        value.truncateToDouble() == value ? value : (value * 10).round() / 10);

    return SoftCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  formatted,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  '₪',
                  style: TextStyle(
                      color: muted, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Text(
              '${trend! >= 0 ? '▲' : '▼'} ${trend!.abs().toStringAsFixed(0)}%',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: trend! >= 0 ? AppColors.success : AppColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ClientStats {
  final Todo client;
  final double totalPayment; // gross paid (extraPayment of paid calls)
  final double totalNotPaid; // gross pending (extraPayment of unpaid calls)
  final double netProfit; // realized profit = paid gross − parts cost of paid calls

  ClientStats({
    required this.client,
    required this.totalPayment,
    required this.totalNotPaid,
    required this.netProfit,
  });

  String get clientName => client.name ?? '';
}
