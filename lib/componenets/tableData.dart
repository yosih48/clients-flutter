import 'package:clientsf/theme.dart';
import 'package:flutter/material.dart';

/// Full-width table laid out as flexible rows so it always spans the screen
/// regardless of how many clients are shown. Four columns: name, paid (שולם),
/// unpaid (לתשלום), and net (realized profit).
class DataTableWidget extends StatelessWidget {
  final Map<String, double> clientTotalPayments;
  final Map<String, double> clientNotPaidPayments;
  final Map<String, double> clientNetProfit;

  const DataTableWidget({
    super.key,
    required this.clientTotalPayments,
    required this.clientNotPaidPayments,
    required this.clientNetProfit,
  });

  @override
  Widget build(BuildContext context) {
    final names = clientTotalPayments.keys.toList();
    double totalPaid = 0;
    double totalUnpaid = 0;
    double totalNet = 0;
    for (final name in names) {
      totalPaid += clientTotalPayments[name] ?? 0;
      totalUnpaid += clientNotPaidPayments[name] ?? 0;
      totalNet += clientNetProfit[name] ?? 0;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _HeaderRow(),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          // Rows
          for (int i = 0; i < names.length; i++) ...[
            _ClientRow(
              name: names[i],
              paid: clientTotalPayments[names[i]] ?? 0,
              unpaid: clientNotPaidPayments[names[i]] ?? 0,
              net: clientNetProfit[names[i]] ?? 0,
              isEven: i.isEven,
            ),
          ],
          // Totals
          Container(
            color: AppColors.primarySoft.withOpacity(0.45),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'סהכ',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.primary),
                  ),
                ),
                _NumCell(value: totalPaid, color: AppColors.success, bold: true),
                _NumCell(value: totalUnpaid, color: AppColors.warning, bold: true),
                _NumCell(
                    value: totalNet,
                    color: totalNet >= 0
                        ? AppColors.primary
                        : AppColors.danger,
                    bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMuted.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 4, child: _HeaderLabel('שם לקוח', align: TextAlign.start)),
          Expanded(flex: 3, child: _HeaderLabel('שולם', align: TextAlign.end)),
          Expanded(flex: 3, child: _HeaderLabel('לתשלום', align: TextAlign.end)),
          Expanded(flex: 3, child: _HeaderLabel('Net', align: TextAlign.end)),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _HeaderLabel(this.text, {required this.align});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        color: AppColors.inkMuted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  final String name;
  final double paid;
  final double unpaid;
  final double net;
  final bool isEven;

  const _ClientRow({
    required this.name,
    required this.paid,
    required this.unpaid,
    required this.net,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? Colors.transparent : AppColors.surfaceMuted.withOpacity(0.25),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              name,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          _NumCell(
              value: paid,
              color: paid > 0 ? AppColors.success : AppColors.inkFaint),
          _NumCell(
              value: unpaid,
              color: unpaid > 0 ? AppColors.warning : AppColors.inkFaint),
          _NumCell(
              value: net,
              color: net == 0
                  ? AppColors.inkFaint
                  : (net > 0 ? AppColors.primary : AppColors.danger)),
        ],
      ),
    );
  }
}

class _NumCell extends StatelessWidget {
  final double value;
  final Color color;
  final bool bold;
  const _NumCell({required this.value, required this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final whole = value.truncateToDouble() == value;
    final formatted = whole ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return Expanded(
      flex: 3,
      child: Text(
        formatted,
        textAlign: TextAlign.end,
        style: TextStyle(
          color: color,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
          fontSize: bold ? 15 : 14,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
