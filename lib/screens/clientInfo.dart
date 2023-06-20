import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                child: ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('${user.phone}'),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                color: Colors.grey,
                child: ListTile(
                  leading: Icon(Icons.mail),
                  title: Text('${user.email}'),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                color: Colors.grey,
                child: ListTile(
                  leading: Icon(Icons.maps_home_work),
                  title: Text('${user.address}'),
                ),
              ),
            ],
          ),
        ));
  }
}