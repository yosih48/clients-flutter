import 'dart:async';

import 'package:clientsf/l10n/app_localizations.dart';
import 'package:clientsf/theme.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../Login Screen/Login_Screen.dart';
import '../auth_scaffold.dart';

class PinCodeVerificationScreen extends StatefulWidget {
  final String? phoneNumber;

  const PinCodeVerificationScreen({
    Key? key,
    this.phoneNumber,
  }) : super(key: key);
  @override
  State<PinCodeVerificationScreen> createState() =>
      _PinCodeVerificationScreenState();
}

class _PinCodeVerificationScreenState extends State<PinCodeVerificationScreen> {
  final TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController?.close();
    super.dispose();
  }

  void _snack(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? '')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AuthScaffold(
      title: loc.verifyNumber,
      subtitle: loc.enterCodeSentTo(widget.phoneNumber ?? ''),
      icon: Icons.sms_outlined,
      children: [
        Form(
          key: formKey,
          child: PinCodeTextField(
            appContext: context,
            length: 6,
            obscureText: false,
            animationType: AnimationType.fade,
            keyboardType: TextInputType.number,
            enableActiveFill: true,
            errorAnimationController: errorController,
            controller: textEditingController,
            cursorColor: Theme.of(context).colorScheme.primary,
            animationDuration: const Duration(milliseconds: 220),
            pastedTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(AppRadius.md),
              fieldHeight: 56,
              fieldWidth: 44,
              borderWidth: 1.2,
              activeColor: Theme.of(context).colorScheme.primary,
              selectedColor: Theme.of(context).colorScheme.primary,
              inactiveColor: Theme.of(context).dividerColor,
              activeFillColor: Theme.of(context).colorScheme.surface,
              inactiveFillColor: Theme.of(context).colorScheme.surface,
              selectedFillColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.08),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? loc.pleaseEnterAllDigits : null,
            onChanged: (value) => setState(() => currentText = value),
            beforeTextPaste: (_) => true,
            onCompleted: (_) {},
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '*${loc.fillCellsProperly}',
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.didntReceiveCode,
                style: TextStyle(color: AppColors.inkMuted)),
            TextButton(
              onPressed: () => _snack(loc.otpResend),
              child: Text(loc.resend),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              formKey.currentState!.validate();
              if (currentText.length != 6 || currentText != "123456") {
                errorController!.add(ErrorAnimationType.shake);
                setState(() => hasError = true);
              } else {
                setState(() => hasError = false);
                _snack(loc.otpVerified);
              }
            },
            child: Text(loc.verify),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.wantTryAgain,
                style: TextStyle(color: AppColors.inkMuted)),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              child: Text(loc.signIn),
            ),
          ],
        ),
      ],
    );
  }
}
