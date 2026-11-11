import 'package:clientsf/l10n/app_localizations.dart';
import 'package:clientsf/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../componenets/alertDialog.dart';
import '../auth_common.dart';
import '../auth_scaffold.dart';

/// Firebase rejects passwords shorter than this.
const int _minPasswordLength = 6;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _authError;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    final loc = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    setState(() => _authError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final name = nameController.text.trim();
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      // Keep the name on the Firebase profile (shown in the drawer/settings).
      try {
        await credential.user?.updateDisplayName(name);
      } catch (e) {
        debugPrint('updateDisplayName failed: $e');
      }
      if (!mounted) return;
      showToast(loc.welcomeName(name));
      // Firebase signs the new user in; AppStarter shows the home screen.
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
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final passwordsMatch = confirmPasswordController.text.isNotEmpty &&
        confirmPasswordController.text == passwordController.text;

    return AuthScaffold(
      title: loc.createAccount,
      subtitle: loc.signUpSubtitle,
      icon: Icons.person_add_alt_1_rounded,
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameController,
                  enabled: !_loading,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  decoration: InputDecoration(
                    labelText: loc.fullName,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? loc.nameRequired : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailController,
                  enabled: !_loading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: loc.email,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) => validateEmail(v, loc),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passwordController,
                  enabled: !_loading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: loc.password,
                    helperText: loc.passwordMinLength(_minPasswordLength),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? loc.showPassword
                          : loc.hidePassword,
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if ((v ?? '').isEmpty) return loc.passwordRequired;
                    if (v!.length < _minPasswordLength) {
                      return loc.passwordMinLength(_minPasswordLength);
                    }
                    return null;
                  },
                ),
                _PasswordStrength(password: passwordController.text),
                const SizedBox(height: 14),
                TextFormField(
                  controller: confirmPasswordController,
                  enabled: !_loading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => signUp(),
                  decoration: InputDecoration(
                    labelText: loc.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: passwordsMatch
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.success)
                        : null,
                  ),
                  validator: (v) => v != passwordController.text
                      ? loc.passwordsDontMatch
                      : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _authError == null
              ? const SizedBox(width: double.infinity)
              : AuthErrorBanner(message: _authError!),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : signUp,
            child: _loading ? const ButtonSpinner() : Text(loc.signUp),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(loc.haveAccount, style: TextStyle(color: muted)),
            TextButton(
              onPressed: _loading ? null : () => Navigator.pop(context),
              child: Text(loc.signIn),
            ),
          ],
        ),
      ],
    );
  }
}

/// Three-step bar under the password field: weak / medium / strong.
class _PasswordStrength extends StatelessWidget {
  final String password;
  const _PasswordStrength({required this.password});

  int get _score {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= _minPasswordLength) score++;
    if (password.length >= 10) score++;
    final variety = [
      RegExp(r'[a-z]'),
      RegExp(r'[A-Z]'),
      RegExp(r'\d'),
      RegExp(r'[^A-Za-z0-9]'),
    ].where((r) => r.hasMatch(password)).length;
    if (variety >= 3) score++;
    return score.clamp(1, 3);
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final score = _score;
    final color = [
      AppColors.danger,
      const Color(0xFFD9822B),
      AppColors.success
    ][score - 1];
    final label = [loc.passwordWeak, loc.passwordMedium, loc.passwordStrong][
        score - 1];

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, end: 4, top: 8),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4,
                decoration: BoxDecoration(
                  color: i < score ? color : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
