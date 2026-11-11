import 'package:clientsf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Forgot Password/Forgot_Password_Screen.dart';
import '../Sign Up Screen/SignUp_Screen.dart';
import '../auth_common.dart';
import '../auth_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  /// Error from the last sign-in attempt, shown inside the form.
  String? _authError;


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final loc = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    setState(() => _authError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (!mounted) return;
      // AppStarter swaps the root to the home screen on auth change; drop any
      // auth screens (sign up, forgot password…) still stacked above it.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _authError = authErrorMessage(e, loc));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AuthScaffold(
      title: loc.welcomeBack,
      subtitle: loc.signInSubtitle,
      icon: Icons.waving_hand_rounded,
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: emailController,
                  enabled: !_loading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.username,
                  ],
                  decoration: InputDecoration(
                    labelText: loc.email,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (value) => validateEmail(value, loc),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passwordController,
                  enabled: !_loading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => login(),
                  decoration: InputDecoration(
                    labelText: loc.password,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? loc.passwordRequired
                      : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: _loading
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ForgotPasswordScreen(
                        initialEmail: emailController.text.trim()))),
            child: Text(loc.cantLogIn),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _authError == null
              ? const SizedBox(width: double.infinity)
              : AuthErrorBanner(message: _authError!),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : login,
            child: _loading ? const ButtonSpinner() : Text(loc.signIn),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(loc.noAccountYet, style: TextStyle(color: muted)),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen())),
              child: Text(loc.signUp),
            ),
          ],
        ),
      ],
    );
  }
}
