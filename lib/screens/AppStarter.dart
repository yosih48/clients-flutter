import 'package:clientsf/singelton/AppSingelton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:rest_api/Screens/UserListScreen.dart';

import '../Feature/Login Screen/Login_Screen.dart';
import '../componenets/auth.dart';
import '../componenets/parts.dart';
import '../main.dart';
import '../objects/clients.dart';
import 'PhoneLogin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'actions.dart';

class AppStarter extends StatefulWidget {
  const AppStarter({super.key});

  @override
  State<AppStarter> createState() => _AppStarterState();
}

class _AppStarterState extends State<AppStarter> {
 
  // This widget is the root of your application.
  late Future<bool> _checkToken;
 User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    _checkToken = checkAuthToken();
    print('appStarter ${user!.uid}');
    AppSingelton().userID = '${user!.uid}';
      // print(AppSingelton().userID );
  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
         routes: {
        // '/actions': (context) => actions(user: user),
        // '/': (context) => TodoApp(),
        // '/date': (context) => HomePage(),
        // '/time': (context) => ScreenOne(),
        '/action': (context) => actions(),
        // '/callinfo': (context) => ClientServiceScreen(),
      },
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

      // home: const TodoApp(),
      // home: ProductForm(),

      // home: PhoneLoginPage(),
      // home: LoginScreen(),
      //         home: FutureBuilder<bool>(
      // future: Future.delayed(Duration.zero, () => isUserAuthenticated()),
      //     builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return Scaffold(
      //     body: Center(
      //       child: CircularProgressIndicator(),
      //     ),
      //   );
      //       } else {
      //         if (snapshot.data == true) {
      //           print('snapshot   ${snapshot}');
      //           return TodoApp();
      //         } else {
      //           print('snapshotdata   ${snapshot.data}');
      //           return LoginScreen();
      //         }
      //       }
      //     },
      //   ),
// home: StreamBuilder<User?>(
//   stream: FirebaseAuth.instance.authStateChanges(),
//   builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     } else {
//       if (snapshot.hasData) {
//         return TodoApp();
//       } else {
//         return LoginScreen();
//       }
//     }
//   },
// ),
      home: FutureBuilder<bool>(
        future: _checkToken,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.data == true) {
              print('yes token');
              print(snapshot.data);
              return const TodoApp();
              // return LoginScreen();
            } else {
              print('no token');
              return LoginScreen();
            }
          }
        },
      ),
    );
  }
}
