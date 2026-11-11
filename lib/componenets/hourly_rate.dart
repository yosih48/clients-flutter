import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The hourly rate is stored per signed-in user. Older versions saved it
/// under "_newValue" (the user id was never filled in), shared by everyone
/// on the device; that value is used as a one-time fallback.
const _legacyKey = '_newValue';

String _keyForCurrentUser() =>
    '${FirebaseAuth.instance.currentUser?.uid ?? ''}_newValue';

Future<int> loadHourlyRate() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_keyForCurrentUser()) ?? prefs.getInt(_legacyKey) ?? 0;
}

Future<void> saveHourlyRate(int value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_keyForCurrentUser(), value);
}
