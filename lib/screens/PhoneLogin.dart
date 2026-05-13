import 'package:clientsf/Feature/auth_scaffold.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:clientsf/theme.dart';
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
    super.initState();
  }

  void _snack(String msg) =>
      _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(msg)));

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _verifyPhone() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        verificationCompleted: _verificationCompleted,
        verificationFailed: _verificationFailed,
        codeSent: _codeSent,
        codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
      );
    } catch (e) {
      _snack(AppLocalizations.of(context)!.phoneVerifyFail);
    }
  }

  void _verificationCompleted(PhoneAuthCredential credential) async {
    try {
      await _auth.signInWithCredential(credential);
      if (!mounted) return;
      _snack(AppLocalizations.of(context)!.phoneVerifiedAuto);
    } catch (_) {
      if (!mounted) return;
      _snack(AppLocalizations.of(context)!.signInFail);
    }
  }

  void _verificationFailed(FirebaseAuthException exception) {
    _snack(AppLocalizations.of(context)!.phoneVerifyFail);
  }

  void _codeSent(String verificationId, int? resendToken) {
    _verificationId = verificationId;
  }

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
      if (!mounted) return;
      _snack(AppLocalizations.of(context)!.phoneVerifiedSuccess);
    } catch (_) {
      if (!mounted) return;
      _snack(AppLocalizations.of(context)!.signInFail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: AuthScaffold(
        title: loc.welcomeBack,
        subtitle: loc.phoneLoginSubtitle,
        icon: Icons.smartphone_rounded,
        children: [
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: loc.phoneNumber,
              hintText: '+972…',
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifyPhone,
              child: Text(loc.sendVerificationCode),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.verificationCode,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          PinCodeTextField(
            controller: _codeController,
            appContext: context,
            length: 6,
            onChanged: (_) {},
            keyboardType: TextInputType.number,
            enableActiveFill: true,
            animationDuration: const Duration(milliseconds: 200),
            cursorColor: Theme.of(context).colorScheme.primary,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(AppRadius.md),
              fieldHeight: 52,
              fieldWidth: 42,
              borderWidth: 1.2,
              activeColor: Theme.of(context).colorScheme.primary,
              selectedColor: Theme.of(context).colorScheme.primary,
              inactiveColor: Theme.of(context).dividerColor,
              activeFillColor: Theme.of(context).colorScheme.surface,
              inactiveFillColor: Theme.of(context).colorScheme.surface,
              selectedFillColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.08),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _signInWithPhoneNumber,
              child: Text(loc.signIn),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: signOut,
                child: Text(loc.signout),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
