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
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            SizedBox(height: 16),
            //       Column(
            //   children: products.map((product) {
            //     final productName = product['name'];
            //     final productPrice = product['price'];
            //     final productDiscountedPrice = product['discountedPrice'];

            //     return ListTile(
            //       title: Text(productName),
            //       subtitle: Text(
            //         'Price: $productPrice, Discounted Price: $productDiscountedPrice',
            //       ),
            //     );
            //   }).toList(),
            //       ),
            // Text(
            //   'Purchased Products:',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 3,
            //       child: Text(
            //         'Product',
            //         style: TextStyle(fontSize: 16),
            //       ),
            //     ),
            //     Expanded(
            //       flex: 2,
            //       child: Text(
            //         'Price',
            //         style: TextStyle(fontSize: 16),
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(height: 8),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 3,
            //       child: Text(
            //         'Shower Head',
            //         style: TextStyle(fontSize: 16),
            //       ),
            //     ),
            //     Expanded(
            //       flex: 2,
            //       child: Text(
            //         '\$20',
            //         style: TextStyle(fontSize: 16),
            //       ),
            //     ),
            //   ],
            // ),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 3,
            //       child: Text(
            //         'Faucet',
            //         style: TextStyle(fontSize: 16),
            //       ),
            //     ),
            //     Expanded(
            //       flex: 2,
            //       child: Text(
            //         '\$30',
            //         style: TextStyle(fontSize: 16),
            //       ),
            //     ),
            //   ],
            // ),
            Text(
              'Purchased Products:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Product',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Price',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
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
                      flex: 2,
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
