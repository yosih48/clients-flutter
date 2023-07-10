import 'package:shared_preferences/shared_preferences.dart';

// Function to save the authentication token
void saveAuthToken(String token) async {
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
  String authToken = getAuthToken() as String;
  return authToken != null;
}
