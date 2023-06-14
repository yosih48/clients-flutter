import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PhoneLoginPage extends StatefulWidget {
  @override
  _PhoneLoginPageState createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  String _verificationId = "";

  @override
  void initState() {
    isUserLoggedIn();
    super.initState();
  }

  isUserLoggedIn() {
    if (FirebaseAuth.instance.currentUser != null) {
      print("User logged in");
      return true;
    } else {
      print("User not logged in");
      return false;
    }
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
    print("User Signed out");
  }

  Future<void> _verifyPhone() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        // timeoutDuration: const Duration(seconds: 60),
        verificationCompleted: _verificationCompleted,
        verificationFailed: _verificationFailed,
        codeSent: _codeSent,
        codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
      );
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
            content: Text("Failed to verify phone number. Please try again.")),
      );
    }
  }

  void _verificationCompleted(PhoneAuthCredential credential) async {
    try {
      await _auth.signInWithCredential(credential);
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text("Phone number automatically verified.")),
      );
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text("Failed to sign in. Please try again.")),
      );
    }
  }

  void _verificationFailed(FirebaseAuthException exception) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
          content: Text("Failed to verify phone number. Please try again.")),
    );
  }

  void _codeSent(String verificationId, int? resendToken) {
    _verificationId = verificationId;
  }
  // void _codeSent(PhoneAuthCredential credential) async {
  //   try {
  //     await _auth.signInWithCredential(credential);
  //     _scaffoldKey.currentState?.showSnackBar(
  //       SnackBar(content: Text("Phone number verified successfully.")),
  //     );
  //   } catch (e) {
  //     _scaffoldKey.currentState?.showSnackBar(
  //       SnackBar(content: Text("Failed to sign in. Please try again.")),
  //     );
  //   }
  // }

  void _codeAutoRetrievalTimeout(String verificationId) {
    _verificationId = verificationId;
  }

  Future<void> _signInWithPhoneNumber() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codeController.text,
      );
      await _auth.signInWithCredential(credential);
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text("Phone number verified successfully.")),
      );
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text("Failed to sign in. Please try again.")),
      );
    }
  }

  _userStatus() {
    isUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Firebase Phone Login"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Phone number",
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _verifyPhone,
                child: Text("Verify Phone Number"),
              ),
              SizedBox(height: 32.0),
              PinCodeTextField(
                controller: _codeController,
                appContext: context,
                length: 6,
                onChanged: (value) {},
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _signInWithPhoneNumber,
                child: Text("Sign In"),
              ),
              ElevatedButton(
                onPressed: _userStatus,
                child: Text("User status"),
              ),
              ElevatedButton(
                onPressed: signOut,
                child: Text("User logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
