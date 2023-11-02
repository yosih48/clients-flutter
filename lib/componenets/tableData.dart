import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final Map<String, double> clientTotalPayments;

  DataTableWidget({required this.clientTotalPayments});

  @override
  Widget build(BuildContext context) {
    List<DataRow> rows = [];

    clientTotalPayments.forEach((clientName, totalPayment) {
      rows.add(DataRow(
        cells: <DataCell>[
          DataCell(Text(clientName)),
          DataCell(Text(totalPayment.toStringAsFixed(2))),
        ],
      ));
    });

    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text(
            'Client Name',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(
            'Total Payment',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
      rows: rows,
    );
  }
}