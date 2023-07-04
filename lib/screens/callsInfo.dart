import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../objects/clientsCalls.dart';

class ClientServiceScreen extends StatelessWidget {
  final Map<String, dynamic> call;
  const ClientServiceScreen({super.key, required this.call});
  @override
  Widget build(BuildContext context) {
    print(call); // Print the call map
    List<dynamic> products = call['products'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Service Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type of Service:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${call['type']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${call['call']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Payment Amount:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${call['payment']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Payment Status:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${call['paid']}',
              style: TextStyle(
                fontSize: 16,
                color: call['paid'] ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 16),
     
            Text(
              'Purchased Products:',
              // AppLocalizations.of(context)!.PaymentStatus,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 12.0,
            ),
            Row(
              children: [
                if (products.isNotEmpty)
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Product',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                SizedBox(
                  height: 8.0,
                ),
                if (products.isNotEmpty)
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Price',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            // SizedBox(height: 8),
            if (products.isEmpty)
              Text(
                '-',
                style: TextStyle(fontSize: 16),
              ),
            if (products.isNotEmpty)
              Column(
                children: products.map((product) {
                  final productName = product['name'];
                  final productPrice = product['price'];

                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          productName,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          '\$$productPrice',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Handle edit button click
              },
              child: Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
