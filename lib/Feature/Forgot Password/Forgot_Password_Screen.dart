import 'package:clientsf/theme.dart';
import 'package:flutter/material.dart';

import '../Login Screen/Login_Screen.dart';
import '../Pin Code/Pin_Code_Screen.dart';
import '../auth_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password',
      subtitle: "We'll send a verification code to your phone",
      icon: Icons.lock_reset_rounded,
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline_rounded),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const PinCodeVerificationScreen(phoneNumber: '0102756960'),
              ));
            },
            child: const Text('Continue'),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Remember it?',
                style: TextStyle(color: AppColors.inkMuted)),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              child: const Text('Sign in'),
            ),
          ],
        ),
      ],
    );
  }
}
