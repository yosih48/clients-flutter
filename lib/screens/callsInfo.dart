import 'package:clientsf/componenets/editCallDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../objects/clients.dart';
import '../objects/clientsCalls.dart';

class ClientServiceScreen extends StatelessWidget {
  final Map<String, dynamic> call;
  final user;
  const ClientServiceScreen(
      {super.key, required this.call, required this.user});
  @override
  Widget build(BuildContext context) {
    print(call); // Print the call map
    // print('userID ${user}'); // Print the call map
    List<dynamic> products = call['products'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.callDetails,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.typeofService,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${call['type']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.description,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${call['call']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.paymentAmount,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${call['payment']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.paymentStatus,
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
              // 'Purchased Products:',
              AppLocalizations.of(context)!.products,
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
                      AppLocalizations.of(context)!.product,
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
                      AppLocalizations.of(context)!.productPrice,
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
                          '$productPrice ₪',
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
                //  editCallDialog(context);
                Navigator.pushReplacementNamed(context, '/action', arguments: {
                  'id': call['id'],
                  'call': call['call'],
                  'type': call['type'],
                  'hour': call['hour'],
                  'paid': call['paid'],
                  'payment': call['payment'],
                  'products': call['products'],
                  'usera': user,
                  'fromScreen1': true
                });
              },
              child: Text(    AppLocalizations.of(context)!.edit),
            ),
          ],
        ),
      ),
    );
  }
}
