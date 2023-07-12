import 'package:shared_preferences/shared_preferences.dart';


class AppSingelton {
  double _hourlyRate = 0.0;
  // static AppSingelton? _instance;
   static AppSingelton _instance = AppSingelton._internal();

  AppSingelton._();

  factory AppSingelton() {
    if (_instance == null) {
      _instance = AppSingelton._();
    }
    return _instance;
  }
AppSingelton._internal();
 double get hourlyRate => _hourlyRate;

   Future<void> loadHourlyRate() async {
    final prefs = await SharedPreferences.getInstance();
    _hourlyRate = prefs.getDouble('hourlyRate') ?? 0.0;
  }
  Future<void> saveHourlyRate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('hourlyRate', _hourlyRate);
  }
  set hourlyRate(double rate) {
    _hourlyRate = rate;
  }

  void doSomething() {
    print('do');
  }
}
