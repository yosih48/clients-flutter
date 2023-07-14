import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AppSingelton {
  static AppSingelton? _instance;

  AppSingelton._();
 
 

  factory AppSingelton() {
    if (_instance == null) {
      _instance = AppSingelton._();
    }
    return _instance!;
  }
  User? user = FirebaseAuth.instance.currentUser;
  //  String userID = user!.uid;
  double hourlyRate = 0.0;
  String userID = '';


  void doSomething() {
    print(user);
    print('do');
  }

}
