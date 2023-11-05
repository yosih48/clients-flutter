import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final Map<String, double> clientTotalPayments;

  DataTableWidget({required this.clientTotalPayments});

  @override
  Widget build(BuildContext context) {
    List<DataRow> rows = [];
double totalSum = 0.0; // Initialize the total sum
    clientTotalPayments.forEach((clientName, totalPayment) {
      print( totalPayment);
      rows.add(DataRow(
        cells: <DataCell>[
          DataCell(Text(clientName)),
          DataCell(Text(totalPayment.toStringAsFixed(2))),
        
            
        ],
      ));
       totalSum += totalPayment; // Add the current totalPayment to the total sum
    });
rows.add(DataRow(
  cells: <DataCell>[
    DataCell(Text('סהכ תשלומים',style: TextStyle(fontWeight: FontWeight.bold),)),
    DataCell(Text(totalSum.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold),)),
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
          ),
        ],
      ),
      
    );
  }
}