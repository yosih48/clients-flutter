import 'package:clientsf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'alertDialog.dart';

/// Helpers that hand a client's contact details to other apps (dialer, mail,
/// WhatsApp, Waze/Maps). They never throw: when nothing can handle the link
/// the user gets a toast instead.

Future<void> _open(BuildContext context, Uri uri) async {
  final message = AppLocalizations.of(context)!.noAppToOpen;
  bool ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('launch $uri failed: $e');
  }
  if (!ok) showToast(message);
}

String _dialable(String phone) => phone.replaceAll(RegExp(r'[^\d+]'), '');

/// Converts a local Israeli number (050-1234567) to international digits
/// (972501234567) as wa.me expects. Numbers already international are kept.
String toInternationalDigits(String phone) {
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.startsWith('0')) digits = '972${digits.substring(1)}';
  return digits;
}

Future<void> dialPhone(BuildContext context, String phone) =>
    _open(context, Uri(scheme: 'tel', path: _dialable(phone)));

Future<void> sendEmail(BuildContext context, String email) =>
    _open(context, Uri(scheme: 'mailto', path: email.trim()));

Future<void> openWhatsApp(BuildContext context, String phone) => _open(
    context, Uri.https('wa.me', '/${toInternationalDigits(phone)}'));

/// Opens Waze navigation to a free-text address. The https link opens the
/// Waze app when installed and falls back to the browser otherwise.
Future<void> openNavigation(BuildContext context, String address) => _open(
      context,
      Uri.https('waze.com', '/ul', {'q': address.trim(), 'navigate': 'yes'}),
    );
