import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:rest_api/Screens/UserListScreen.dart';

import '../componenets/parts.dart';
import '../main.dart';
import 'PhoneLogin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppStarter extends StatelessWidget {
  const AppStarter({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
           localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('he'), // Spanish
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: const TodoApp(),
      // home: ProductForm(),
  

      // home: PhoneLoginPage(),
    );
  }
}
