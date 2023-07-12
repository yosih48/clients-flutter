class AppSingelton {
  static AppSingelton? _instance;

  AppSingelton._();

  factory AppSingelton() {
    if (_instance == null) {
      _instance = AppSingelton._();
    }
    return _instance!;
  }

  double hourlyRate = 0.0;

  void doSomething() {
    print('do');
  }
}
