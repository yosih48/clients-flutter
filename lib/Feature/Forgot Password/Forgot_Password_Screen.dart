import 'dart:async';

import 'package:clientsf/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth_common.dart';
import '../auth_scaffold.dart';

/// Seconds the user must wait before asking for another reset email.
const int _resendCooldown = 30;

class ForgotPasswordScreen extends StatefulWidget {
  /// Email already typed on the login screen, if any.
  final String initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController emailController =
      TextEditingController(text: widget.initialEmail);

  bool _loading = false;
  String? _error;

  /// Email the link was sent to; non-null switches to the "check inbox" view.
  String? _sentTo;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _send() async {
    final loc = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (_sentTo == null && !_formKey.currentState!.validate()) return;

    final email = _sentTo ?? emailController.text.trim();
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() => _sentTo = email);
      _startCooldown();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Don't reveal whether an account exists for this address.
      if (e.code == 'user-not-found') {
        setState(() => _sentTo = email);
        _startCooldown();
      } else {
        setState(() => _error = authErrorMessage(e, loc));
      }
    } catch (e) {
      if (mounted) setState(() => _error = authErrorMessage(e, loc));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return _sentTo == null ? _buildForm(loc) : _buildSent(loc);
  }

  Widget _buildForm(AppLocalizations loc) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return AuthScaffold(
      title: loc.resetPassword,
      subtitle: loc.resetPasswordSubtitle,
      icon: Icons.lock_reset_rounded,
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
            controller: emailController,
            enabled: !_loading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            autocorrect: false,
            enableSuggestions: false,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _send(),
            decoration: InputDecoration(
              labelText: loc.email,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
            ),
            validator: (v) => validateEmail(v, loc),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _error == null
              ? const SizedBox(width: double.infinity)
              : AuthErrorBanner(message: _error!),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _send,
            child: _loading ? const ButtonSpinner() : Text(loc.sendResetLink),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(loc.rememberIt, style: TextStyle(color: muted)),
            TextButton(
              onPressed: _loading ? null : () => Navigator.pop(context),
              child: Text(loc.signIn),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSent(AppLocalizations loc) {
    final theme = Theme.of(context);
    return AuthScaffold(
      title: loc.checkYourInbox,
      subtitle: loc.resetLinkSentIfExists,
      icon: Icons.mark_email_read_rounded,
      children: [
        Text(
          _sentTo!,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          loc.checkSpamHint,
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (_error != null) AuthErrorBanner(message: _error!),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.backToSignIn),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: (_loading || _cooldown > 0) ? null : _send,
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_cooldown > 0
                    ? loc.resendIn(_cooldown)
                    : loc.resendEmail),
          ),
        ),
        TextButton(
          onPressed: _loading
              ? null
              : () => setState(() {
                    _sentTo = null;
                    _error = null;
                  }),
          child: Text(loc.useDifferentEmail),
        ),
      ],
    );
  }
}
