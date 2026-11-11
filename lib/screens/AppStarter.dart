import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clientsf/l10n/app_localizations.dart';

import '../Feature/Login Screen/Login_Screen.dart';
import '../componenets/app_prefs.dart';
import '../main.dart';
import 'actions.dart';

/// The single [MaterialApp] of the app. Which root screen is shown is driven
/// by Firebase's auth state: signing in or out anywhere swaps the root
/// automatically, so screens never push a new app on top of the old one.
class AppStarter extends StatefulWidget {
  const AppStarter({super.key});

  @override
  State<AppStarter> createState() => _AppStarterState();
}

class _AppStarterState extends State<AppStarter> {
  // Kept across rebuilds (theme/language changes) so the auth gate doesn't
  // re-subscribe and flash the loading screen.
  final Stream<User?> _authStream = FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([AppPrefs.themeMode, AppPrefs.locale]),
      builder: (context, _) => MaterialApp(
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
        themeMode: AppPrefs.themeMode.value,
        locale: AppPrefs.locale.value,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: StreamBuilder<User?>(
          stream: _authStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }
            if (snapshot.data != null) return const TodoApp();
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
