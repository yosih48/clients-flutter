import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final Map<String, double> clientTotalPayments;
  final Map<String, double> clientNotPaidPayments;

  DataTableWidget({required this.clientTotalPayments, required this.clientNotPaidPayments});

  @override
  Widget build(BuildContext context) {
    List<DataRow> rows = [];
double totalSum = 0.0; // Initialize the total sum
double totalSumNotpaid = 0.0; // Initialize the total sum
    clientTotalPayments.forEach((clientName, totalPayment) {
        double notPaid = clientNotPaidPayments[clientName] ?? 0.0;
      // print( totalPayment);
      rows.add(DataRow(
        cells: <DataCell>[
          DataCell(Text(clientName)),
          DataCell(Text(totalPayment.toStringAsFixed(2))),
             DataCell(Text(notPaid.toStringAsFixed(2))),
        
            
        ],
      ));
       totalSum += totalPayment; // Add the current totalPayment to the total sum
       totalSumNotpaid += notPaid; // Add the current totalPayment to the total sum
    });
rows.add(DataRow(
  cells: <DataCell>[
    DataCell(Text('סהכ תשלומים',style: TextStyle(fontWeight: FontWeight.bold),)),
    DataCell(Text(totalSum.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold),)),
    DataCell(Text(totalSumNotpaid.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold),)),
  ],
));
    return Container(

      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          
          DataTable(
    
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'שם לקוח',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'שולם',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'לתשלום',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
       
            ],
            rows: rows,
          ),
        ],
      ),
      
    );
  }
}