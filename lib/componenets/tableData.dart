import 'package:clientsf/theme.dart';
import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final Map<String, double> clientTotalPayments;
  final Map<String, double> clientNotPaidPayments;

  const DataTableWidget({
    super.key,
    required this.clientTotalPayments,
    required this.clientNotPaidPayments,
  });

  @override
  Widget build(BuildContext context) {
    final List<DataRow> rows = [];
    double totalSum = 0;
    double totalSumNotpaid = 0;

    clientTotalPayments.forEach((clientName, totalPayment) {
      final double notPaid = clientNotPaidPayments[clientName] ?? 0.0;
      rows.add(DataRow(
        cells: [
          DataCell(Text(
            clientName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          )),
          DataCell(Text(
            totalPayment.toStringAsFixed(2),
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.success),
          )),
          DataCell(Text(
            notPaid.toStringAsFixed(2),
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: notPaid > 0
                    ? AppColors.warning
                    : AppColors.inkMuted),
          )),
        ],
      ));
      totalSum += totalPayment;
      totalSumNotpaid += notPaid;
    });

    // Totals row
    rows.add(DataRow(
      color: WidgetStateProperty.all(AppColors.primarySoft.withOpacity(0.5)),
      cells: [
        const DataCell(Text(
          'סהכ',
          style: TextStyle(fontWeight: FontWeight.w800),
        )),
        DataCell(Text(
          totalSum.toStringAsFixed(2),
          style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.success,
              fontSize: 15),
        )),
        DataCell(Text(
          totalSumNotpaid.toStringAsFixed(2),
          style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.warning,
              fontSize: 15),
        )),
      ],
    ));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 44,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 56,
        horizontalMargin: 12,
        columnSpacing: 28,
        dividerThickness: 0.5,
        headingRowColor:
            WidgetStateProperty.all(AppColors.surfaceMuted.withOpacity(0.6)),
        headingTextStyle: TextStyle(
          color: AppColors.inkMuted,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
        columns: const [
          DataColumn(label: Text('שם לקוח')),
          DataColumn(label: Text('שולם'), numeric: true),
          DataColumn(label: Text('לתשלום'), numeric: true),
        ],
        rows: rows,
      ),
    );
  }
}
