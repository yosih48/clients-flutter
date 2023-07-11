import 'package:shared_preferences/shared_preferences.dart';

// Function to save the authentication token
  Future<void> saveAuthToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('authToken', token);
}

// Function to retrieve the authentication token
Future<String?> getAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('authToken');
}

// Function to check if the user is authenticated
bool isUserAuthenticated() {
  Future<String?> authToken = getAuthToken();
  return authToken != null;
}

Future<void> removeAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken');
}

Future<bool> checkAuthToken() async {
  String? token = await getAuthToken();
  return token != null && token.isNotEmpty;
}
