import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Signs the user out of Firebase. [AppStarter] listens to auth state, so the
/// root switches back to the login screen by itself; we only need to clear
/// any screens pushed on top of the home screen.
Future<void> signOutUser(BuildContext context) async {
  final navigator = Navigator.of(context);
  await FirebaseAuth.instance.signOut();
  // Clean up the legacy "authToken" flag older versions stored.
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken');
  navigator.popUntil((route) => route.isFirst);
}
