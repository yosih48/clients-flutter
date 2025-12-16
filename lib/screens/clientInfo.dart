import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clientsf/objects/clients.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import '../componenets/addClientDialof.dart';

class clientInfo extends StatelessWidget {
  final Todo user;
  const clientInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name ?? ''),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              displayDialog(context, '${user.id}');
            },
            tooltip: AppLocalizations.of(context)!.editClient,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                user.name != null && user.name!.isNotEmpty
                    ? user.name![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 40,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              user.name ?? '',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _buildInfoCard(
              context,
              icon: Icons.phone,
              text: user.phone ?? '',
              onTap: () => _launchPhoneDialer(user.phone ?? ''),
            ),
            _buildInfoCard(
              context,
              icon: Icons.mail,
              text: user.email ?? '',
              onTap: () => launchEmailSubmission(user.email ?? ''),
            ),
            _buildInfoCard(
              context,
              icon: Icons.map,
              text: user.address ?? '',
              onTap: () => openWaze(user.address ?? ''),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  displayDialog(context, '${user.id}');
                },
                icon: Icon(Icons.edit),
                label: Text(AppLocalizations.of(context)!.editClient),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required IconData icon, required String text, required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// link to phone call
void _launchPhoneDialer(String phoneNumber) async {
  final url = 'tel:$phoneNumber';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

// link to phone gmail
void sendEmail(String emailAddress) async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: emailAddress,
  );

  if (await canLaunch(emailLaunchUri.toString())) {
    await launch(emailLaunchUri.toString());
  } else {
    throw 'Could not launch email';
  }
}

// email option2
void launchEmailSubmission(String emailAddress) async {
  final Uri params = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {'subject': 'Default Subject', 'body': 'Default body'});
  String url = params.toString();
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('Could not launch $url');
  }
}

// link to phone waze
void openWaze(String address) async {
  final Uri wazeUri = Uri(
    scheme: 'waze',
    path: '/ul',
    queryParameters: {'ll': address},
  );

  if (await canLaunch(wazeUri.toString())) {
    await launch(wazeUri.toString());
  } else {
    openGoogleMaps(address);
    // throw 'Could not launch Waze';
  }
}

// link to phone maps
void openGoogleMaps(String address) async {
  final Uri mapsUri = Uri(
    scheme: 'https',
    host: 'www.google.com',
    path: '/maps/search/',
    queryParameters: {'api': '1', 'query': address},
  );

  if (await canLaunch(mapsUri.toString())) {
    await launch(mapsUri.toString());
  } else {
    throw 'Could not launch Google Maps';
  }
}
