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
  
  Map<String, double> clientTotalPayments = {};
  Map<String, double> clientNotPaidPayments = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize to current month
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Start of the month
    int startTimestamp = DateTime(_currentMonth.year, _currentMonth.month, 1).millisecondsSinceEpoch;
    // End of the month (last millisecond of the last day)
    int endTimestamp = DateTime(_currentMonth.year, _currentMonth.month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      QuerySnapshot userDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_data')
          .get();

      // OPTIMIZATION: Fetch all client calls in parallel using Future.wait
      final futures = userDataSnapshot.docs.map((userDataDoc) async {
        String clientName = userDataDoc.get('name')?.toString() ?? 'Unknown Client';
        
        QuerySnapshot callsSnapshot = await userDataDoc.reference
            .collection('calls')
            .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
            .where('timestamp', isLessThanOrEqualTo: endTimestamp)
            .get();

        return _processClientCalls(clientName, callsSnapshot.docs);
      });

      final results = await Future.wait(futures);

      // Aggregate results
      clientTotalPayments.clear();
      clientNotPaidPayments.clear();
      
      for (var result in results) {
        if (result != null) {
          clientTotalPayments[result.clientName] = result.totalPayment;
          clientNotPaidPayments[result.clientName] = result.totalNotPaid;
        }
      }

    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  ClientStats? _processClientCalls(String clientName, List<QueryDocumentSnapshot> callDocs) {
    if (callDocs.isEmpty) return null;

    double totalPayment = 0;
    double totalNotPaidPayment = 0;
    double sumPrice = 0;

    for (var callDoc in callDocs) {
      final data = callDoc.data() as Map<String, dynamic>;
      bool documentPaid = data['paid'] ?? false;
      List productList = (data['products'] as List<dynamic>?) ?? [];

      double payment = (data['payment'] is int) 
          ? (data['payment'] as int).toDouble() 
          : (data['payment'] as double? ?? 0.0);

      if (documentPaid) {
        totalPayment += payment;
      } else {
        totalNotPaidPayment += payment;
      }

      for (var product in productList) {
        sumPrice += (product['price'] is int) 
            ? (product['price'] as int).toDouble() 
            : (product['price'] as double? ?? 0.0);
      }
    }

    return ClientStats(
      clientName: clientName, 
      totalPayment: totalPayment - sumPrice, 
      totalNotPaid: totalNotPaidPayment
    );
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      // locale: const Locale('he'), 
    );

    if (picked != null) {
      setState(() {
        _currentMonth = picked;
      });
      _loadData();
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('טבלת הכנסות', style: TextStyle(color: Colors.black87)),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : clientTotalPayments.isEmpty 
                    ? Center(child: Text('אין נתונים ל-${DateFormat('MMMM yyyy').format(_currentMonth)}'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: DataTableWidget(
                                clientTotalPayments: clientTotalPayments,
                                clientNotPaidPayments: clientNotPaidPayments,
                              ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.blueAccent),
            tooltip: 'חודש קודם',
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: _pickMonth,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('MMMM yyyy').format(_currentMonth),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.blueAccent),
             tooltip: 'חודש הבא',
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

  ClientStats({required this.clientName, required this.totalPayment, required this.totalNotPaid});
}
