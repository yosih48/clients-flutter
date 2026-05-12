import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart';
import '../componenets/tableData.dart';

class DataTableExample extends StatefulWidget {
  const DataTableExample({Key? key}) : super(key: key);

  @override
  State<DataTableExample> createState() => _DataTableExampleState();
}

class _DataTableExampleState extends State<DataTableExample> {
  DateTime _currentMonth = DateTime.now();
  bool _showAllTime = false;

  Map<String, double> clientTotalPayments = {};
  Map<String, double> clientNotPaidPayments = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final int startTimestamp =
        DateTime(_currentMonth.year, _currentMonth.month, 1)
            .millisecondsSinceEpoch;
    final int endTimestamp = DateTime(
            _currentMonth.year, _currentMonth.month + 1, 0, 23, 59, 59)
        .millisecondsSinceEpoch;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final userDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_data')
          .get();

      final futures = userDataSnapshot.docs.map((userDataDoc) async {
        final clientName =
            userDataDoc.get('name')?.toString() ?? 'Unknown Client';
        final callsCollection = userDataDoc.reference.collection('calls');
        QuerySnapshot callsSnapshot;
        if (_showAllTime) {
          callsSnapshot = await callsCollection.get();
        } else {
          callsSnapshot = await callsCollection
              .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
              .where('timestamp', isLessThanOrEqualTo: endTimestamp)
              .get();
        }
        return _processClientCalls(clientName, callsSnapshot.docs);
      });

      final results = await Future.wait(futures);

      clientTotalPayments.clear();
      clientNotPaidPayments.clear();
      for (final result in results) {
        if (result != null) {
          clientTotalPayments[result.clientName] = result.totalPayment;
          clientNotPaidPayments[result.clientName] = result.totalNotPaid;
        }
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  ClientStats? _processClientCalls(
      String clientName, List<QueryDocumentSnapshot> callDocs) {
    if (callDocs.isEmpty) return null;
    double totalPayment = 0;
    double totalNotPaidPayment = 0;
    double sumPrice = 0;

    for (final callDoc in callDocs) {
      final data = callDoc.data() as Map<String, dynamic>;
      final bool documentPaid = data['paid'] ?? false;
      final List productList = (data['products'] as List<dynamic>?) ?? [];
      final double payment = (data['payment'] is int)
          ? (data['payment'] as int).toDouble()
          : (data['payment'] as double? ?? 0.0);

      if (documentPaid) {
        totalPayment += payment;
      } else {
        totalNotPaidPayment += payment;
      }

      for (final product in productList) {
        sumPrice += (product['price'] is int)
            ? (product['price'] as int).toDouble()
            : (product['price'] as double? ?? 0.0);
      }
    }

    return ClientStats(
      clientName: clientName,
      totalPayment: totalPayment - sumPrice,
      totalNotPaid: totalNotPaidPayment,
    );
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _currentMonth = picked;
        _showAllTime = false;
      });
      _loadData();
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + offset);
      _showAllTime = false;
    });
    _loadData();
  }

  void _toggleAllTime() {
    setState(() => _showAllTime = !_showAllTime);
    _loadData();
  }

  double get _paidTotal => clientTotalPayments.values.fold(0, (a, b) => a + b);
  double get _outstandingTotal =>
      clientNotPaidPayments.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('טבלת הכנסות')),
      body: Column(
        children: [
          _buildFilterBar(),
          if (!_isLoading && clientTotalPayments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'שולם',
                      value: _paidTotal,
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'לתשלום',
                      value: _outstandingTotal,
                      icon: Icons.schedule_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : clientTotalPayments.isEmpty
                    ? EmptyState(
                        icon: Icons.bar_chart_rounded,
                        title: _showAllTime
                            ? 'אין נתונים בכלל'
                            : 'אין נתונים ל-${DateFormat('MMMM yyyy').format(_currentMonth)}',
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        child: SoftCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: DataTableWidget(
                            clientTotalPayments: clientTotalPayments,
                            clientNotPaidPayments: clientNotPaidPayments,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final monthLabel = _showAllTime
        ? 'סיכום כל הזמנים'
        : DateFormat('MMMM yyyy').format(_currentMonth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        children: [
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                CircleIconButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: _showAllTime ? null : () => _changeMonth(-1),
                  tooltip: 'חודש קודם',
                ),
                Expanded(
                  child: InkWell(
                    onTap: _showAllTime ? null : _pickMonth,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_rounded,
                              size: 18,
                              color: _showAllTime
                                  ? AppColors.inkMuted
                                  : AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            monthLabel,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _showAllTime
                                  ? AppColors.inkMuted
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                CircleIconButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: _showAllTime ? null : () => _changeMonth(1),
                  tooltip: 'חודש הבא',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _toggleAllTime,
              icon: Icon(
                  _showAllTime
                      ? Icons.filter_list_rounded
                      : Icons.public_rounded,
                  size: 18),
              label:
                  Text(_showAllTime ? "הצג סיכום חודשי" : "הצג סיכום כל הזמנים"),
            ),
          ),
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
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: AppColors.inkMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${value.toStringAsFixed(2)} ₪',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClientStats {
  final String clientName;
  final double totalPayment;
  final double totalNotPaid;

  ClientStats(
      {required this.clientName,
      required this.totalPayment,
      required this.totalNotPaid});
}
