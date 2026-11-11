import 'package:clientsf/l10n/app_localizations.dart';
import 'package:clientsf/objects/clients.dart';
import 'package:clientsf/screens/tableScreen.dart';
import 'package:clientsf/theme.dart';
import 'package:flutter/material.dart';

enum _SortColumn { name, paid, unpaid, net }

/// Full-width income table laid out as flexible rows. Four columns: name,
/// paid (שולם), unpaid (לתשלום) and net (realized profit). Column headers
/// sort the rows; tapping a row opens that client.
class DataTableWidget extends StatefulWidget {
  final List<ClientStats> stats;
  final ValueChanged<Todo> onClientTap;

  const DataTableWidget({
    super.key,
    required this.stats,
    required this.onClientTap,
  });

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  _SortColumn _sortBy = _SortColumn.net;
  bool _descending = true;

  void _sort(_SortColumn column) {
    setState(() {
      if (_sortBy == column) {
        _descending = !_descending;
      } else {
        _sortBy = column;
        // Names read naturally A→Z, amounts biggest first.
        _descending = column != _SortColumn.name;
      }
    });
  }

  List<ClientStats> get _sorted {
    int compare(ClientStats a, ClientStats b) {
      switch (_sortBy) {
        case _SortColumn.name:
          return a.clientName.toLowerCase().compareTo(b.clientName.toLowerCase());
        case _SortColumn.paid:
          return a.totalPayment.compareTo(b.totalPayment);
        case _SortColumn.unpaid:
          return a.totalNotPaid.compareTo(b.totalNotPaid);
        case _SortColumn.net:
          return a.netProfit.compareTo(b.netProfit);
      }
    }

    final list = [...widget.stats]..sort(compare);
    return _descending ? list.reversed.toList() : list;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final rows = _sorted;

    double totalPaid = 0, totalUnpaid = 0, totalNet = 0;
    for (final s in rows) {
      totalPaid += s.totalPayment;
      totalUnpaid += s.totalNotPaid;
      totalNet += s.netProfit;
    }

    Widget header(String label, _SortColumn column, int flex,
        {TextAlign align = TextAlign.end}) {
      final active = _sortBy == column;
      final color = active ? scheme.primary : scheme.onSurfaceVariant;
      return Expanded(
        flex: flex,
        child: InkWell(
          onTap: () => _sort(column),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: align == TextAlign.start
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (active)
                  Icon(
                    _descending
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 13,
                    color: color,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: scheme.surfaceContainerHighest.withOpacity(isDark ? 1 : 0.6),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              header(loc.clientName, _SortColumn.name, 4,
                  align: TextAlign.start),
              header(loc.statusPaid, _SortColumn.paid, 3),
              header(loc.totalToCharge, _SortColumn.unpaid, 3),
              header(loc.net, _SortColumn.net, 3),
            ],
          ),
        ),
        Divider(height: 1, color: theme.dividerColor),
        for (int i = 0; i < rows.length; i++)
          _ClientRow(
            stats: rows[i],
            striped: i.isOdd,
            onTap: () => widget.onClientTap(rows[i].client),
          ),
        // Totals
        Container(
          color: scheme.primary.withOpacity(isDark ? 0.18 : 0.10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  loc.totalRow,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: scheme.primary),
                ),
              ),
              _NumCell(value: totalPaid, color: AppColors.success, bold: true),
              _NumCell(
                  value: totalUnpaid, color: _unpaidColor, bold: true),
              _NumCell(
                  value: totalNet,
                  color: totalNet >= 0 ? scheme.primary : AppColors.danger,
                  bold: true),
            ],
          ),
        ),
      ],
    );
  }
}

/// Darker than AppColors.warning so it stays readable on white.
const Color _unpaidColor = Color(0xFFD9822B);

class _ClientRow extends StatelessWidget {
  final ClientStats stats;
  final bool striped;
  final VoidCallback onTap;

  const _ClientRow({
    required this.stats,
    required this.striped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final faint = scheme.onSurfaceVariant.withOpacity(0.6);
    final paid = stats.totalPayment;
    final unpaid = stats.totalNotPaid;
    final net = stats.netProfit;

    return Material(
      color: striped
          ? scheme.surfaceContainerHighest.withOpacity(0.35)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  stats.clientName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              _NumCell(
                  value: paid, color: paid > 0 ? AppColors.success : faint),
              _NumCell(
                  value: unpaid, color: unpaid > 0 ? _unpaidColor : faint),
              _NumCell(
                  value: net,
                  color: net == 0
                      ? faint
                      : (net > 0 ? scheme.primary : AppColors.danger)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumCell extends StatelessWidget {
  final double value;
  final Color color;
  final bool bold;
  const _NumCell(
      {required this.value, required this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final whole = value.truncateToDouble() == value;
    final formatted =
        whole ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
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
