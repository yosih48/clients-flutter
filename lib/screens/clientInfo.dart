import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../objects/clients.dart';

class clientInfo extends StatelessWidget {

final Todo user;
 const clientInfo({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.yellow,
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                // backgroundImage: AssetImage('asset/images/avtar.png'),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
              '${user.name}',
                style: TextStyle(
                  fontFamily: 'Sacramento',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
               ' flutter',
                style: TextStyle(fontSize: 15, fontFamily: 'EBGaramond'),
              ),
              SizedBox(
                height: 10,
                width: 150,
                child: Divider(
                  thickness: 1,
                  color: Colors.black,
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                color: Colors.grey,
                
                child: GestureDetector(
                      onTap: () {
                final phoneNumber = '+972543462331'; // Replace with the actual phone number
                _launchPhoneDialer(phoneNumber);
              },
                  child: ListTile(
                    
                    leading: Icon(Icons.phone),
                    title: Text('${user.phone}'),
                  ),
                ),
              ),
              GestureDetector(
                  onTap: () {
    sendEmail('recipient@example.com');
  },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  color: Colors.grey,
                  child: ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('${user.email}'),
                  ),
                  
                ),
              ),
              InkWell(
                  onTap: () {
    openGoogleMaps('latitude,longitude');
  },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  color: Colors.grey,
                  child: ListTile(
                    leading: Icon(Icons.maps_home_work),
                    title: Text('${user.address}'),
                  ),
                ),
              ),
            ],
          ),
        ));
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
    throw 'Could not launch Waze';
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