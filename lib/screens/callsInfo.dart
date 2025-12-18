import 'package:clientsf/componenets/editCallDialog.dart';
import 'package:flutter/material.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
    List<dynamic> products = call['products'] ?? [];
    
    // Extract new fields
    final computerProduct = call['computerProduct'];
    final quantity = call['quantity'];
    final officeVersion = call['officeVersion'];
    final windowsLicense = call['windowsLicense'] ?? false;
    final officeLicense = call['officeLicense'] ?? false;
    final extraPayment = call['extraPayment'];
    final partsPaid = call['partsPaid'] ?? false;
    final done = call['done'] ?? false;
    final inProgress = call['inProgress'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.callDetails,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(context, AppLocalizations.of(context)!.typeofService, '${call['type']}'),
                    Divider(),
                    _buildInfoRow(context, AppLocalizations.of(context)!.description, '${call['call']}'),
                    Divider(),
                    _buildInfoRow(context, AppLocalizations.of(context)!.sumHours, '${call['hour']}'),
                    Divider(),
                    _buildInfoRow(context, AppLocalizations.of(context)!.done, done ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no, 
                      valueColor: done ? Colors.green : Colors.red),
                    Divider(),
                    _buildInfoRow(context, 'In Progress', inProgress ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no, 
                      valueColor: inProgress ? Colors.blue : Colors.grey),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Payment Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow(context, AppLocalizations.of(context)!.paymentAmount, '${call['payment']} ₪'),
                    Divider(),
                    if (extraPayment != null && extraPayment != 0) ...[
                       _buildInfoRow(context, AppLocalizations.of(context)!.extraPayment, '$extraPayment ₪'),
                       Divider(),
                    ],
                    _buildInfoRow(context, AppLocalizations.of(context)!.paymentStatus, '${call['paid']}', 
                      valueColor: call['paid'] ? Colors.green : Colors.red),
                    Divider(),
                     _buildInfoRow(context, 'Parts Paid', partsPaid ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no,
                      valueColor: partsPaid ? Colors.green : Colors.red),
                  ],
                ),
              ),
            ),
             SizedBox(height: 16),

            // Additional Details Card (Computer, Office, Licenses)
            if (computerProduct != null || officeVersion != null || windowsLicense || officeLicense)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        'Additional Details', // You might need to add this key or use a hardcoded string if not available
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      ),
                      SizedBox(height: 12),
                      if (computerProduct != null) ...[
                        _buildInfoRow(context, AppLocalizations.of(context)!.selectProduct, '$computerProduct'),
                        if (quantity != null)
                          _buildInfoRow(context, AppLocalizations.of(context)!.quantity, '$quantity'),
                        Divider(),
                      ],
                      if (officeVersion != null) ...[
                        _buildInfoRow(context, AppLocalizations.of(context)!.officeVersion, '$officeVersion'),
                        Divider(),
                      ],
                      if (windowsLicense) ...[
                        _buildInfoRow(context, AppLocalizations.of(context)!.windowsLicense, AppLocalizations.of(context)!.yes),
                         Divider(),
                      ],
                      if (officeLicense)
                        _buildInfoRow(context, AppLocalizations.of(context)!.officeLicense, AppLocalizations.of(context)!.yes),
                    ],
                  ),
                ),
              ),
            
            if (computerProduct != null || officeVersion != null || windowsLicense || officeLicense)
              SizedBox(height: 16),

            // Products Card
            if (products.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.products,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      ),
                      SizedBox(height: 12),
                      ...products.map((product) {
                        final productName = product['name'];
                        final costPrice = product['discountedPrice'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(productName, style: TextStyle(fontSize: 16))),
                              Text('$costPrice ₪', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/action', arguments: {
                    'id': call['id'],
                    'call': call['call'],
                    'type': call['type'],
                    'hour': call['hour'],
                    'paid': call['paid'],
                    'payment': call['payment'],
                    'done': call['done'],
                    'extraPayment': call['extraPayment'],
                    'products': call['products'],
                    'usera': user,
                    'partsPaid': call['partsPaid'],
                    'computerProduct': call['computerProduct'],
                    'quantity': call['quantity'],
                    'officeVersion': call['officeVersion'],
                    'windowsLicense': call['windowsLicense'],
                    'officeLicense': call['officeLicense'],
                    'inProgress': call['inProgress'],
                    'fromScreen1': true
                  });
                },
                child: Text(AppLocalizations.of(context)!.edit, style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black87),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
