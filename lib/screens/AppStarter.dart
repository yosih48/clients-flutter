import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clientsf/l10n/app_localizations.dart';

import '../Feature/Login Screen/Login_Screen.dart';
import '../componenets/auth.dart';
import '../main.dart';
import 'actions.dart';

class AppStarter extends StatefulWidget {
  const AppStarter({super.key});

  @override
  State<AppStarter> createState() => _AppStarterState();
}

class _AppStarterState extends State<AppStarter> {
  late Future<bool> _checkToken;

  @override
  void initState() {
    super.initState();
    _checkToken = checkAuthToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/action': (context) => actions(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Clients',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('he')],
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: FutureBuilder<bool>(
        future: _checkToken,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.data == true) return const TodoApp();
          return LoginScreen();
        },
      ),
    );
  }
}
