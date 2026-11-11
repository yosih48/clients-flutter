import 'package:clientsf/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Helpers shared by the login, sign-up and forgot-password screens.

final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Validator for an email field.
String? validateEmail(String? value, AppLocalizations loc) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return loc.emailRequired;
  if (!emailPattern.hasMatch(v)) return loc.emailInvalid;
  return null;
}

/// Maps a Firebase Auth error to a message the user can act on.
String authErrorMessage(Object error, AppLocalizations loc) {
  if (error is! FirebaseAuthException) return loc.authGenericError;
  switch (error.code) {
    case 'invalid-email':
      return loc.emailInvalid;
    case 'user-disabled':
      return loc.authUserDisabled;
    case 'too-many-requests':
      return loc.authTooManyRequests;
    case 'network-request-failed':
      return loc.authNetworkError;
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
    case 'INVALID_LOGIN_CREDENTIALS':
      return loc.invalidCredentials;
    case 'email-already-in-use':
      return loc.emailAlreadyInUse;
    case 'weak-password':
      return loc.weakPassword;
    default:
      return loc.authGenericError;
  }
}

/// Inline error shown inside an auth form.
class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.error.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.error.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style:
                  TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small white spinner for primary buttons.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.onPrimary),
      );
}
