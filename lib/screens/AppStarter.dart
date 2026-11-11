import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clientsf/l10n/app_localizations.dart';

import '../Feature/Login Screen/Login_Screen.dart';
import '../main.dart';
import 'actions.dart';

/// The single [MaterialApp] of the app. Which root screen is shown is driven
/// by Firebase's auth state: signing in or out anywhere swaps the root
/// automatically, so screens never push a new app on top of the old one.
class AppStarter extends StatelessWidget {
  const AppStarter({super.key});

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.data != null) return const TodoApp();
          return const LoginScreen();
        },
      ),
    );
  }
}
