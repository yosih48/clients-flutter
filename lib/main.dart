import 'package:clientsf/screens/AppStarter.dart';
import 'package:clientsf/screens/callsTodo.dart';
import 'package:clientsf/screens/settings.dart';
import 'package:clientsf/screens/tableScreen.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clientsf/l10n/app_localizations.dart';

import 'Feature/Login Screen/Login_Screen.dart';
import 'clientdCarsd.dart';
import 'componenets/addClientDialof.dart';
import 'componenets/auth.dart';
import 'screens/actions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(AppStarter());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/action': (context) => actions(),
      },
      title: 'Todo Manage',
      debugShowCheckedModeBanner: false,
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
      home: MyHomePage(title: AppLocalizations.of(context)!.clients),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _TodoListState();
}

class _TodoListState extends State<MyHomePage> {
  void getDataFromFirestore() async {}

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: const _AppDrawer(),
      body: UserListView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => displayDialog(context, null),
        icon: const Icon(Icons.add, size: 22),
        label: Text(loc.addUser),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? user?.phoneNumber ?? '';

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                  InitialAvatar(name: email.isEmpty ? 'A' : email, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.appName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.inkMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Theme.of(context).dividerColor, height: 1),
            const SizedBox(height: 12),
            _DrawerItem(
              icon: Icons.dashboard_rounded,
              label: loc.clients,
              onTap: () => Navigator.pop(context),
              selected: true,
            ),
            _DrawerItem(
              icon: Icons.check_circle_outline_rounded,
              label: loc.todo,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const callsTodo()));
              },
            ),
            _DrawerItem(
              icon: Icons.bar_chart_rounded,
              label: loc.incomeTable,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DataTableExample()));
              },
            ),
            _DrawerItem(
              icon: Icons.tune_rounded,
              label: loc.settings,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
            const Spacer(),
            Divider(color: Theme.of(context).dividerColor, height: 1),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: loc.signout,
              destructive: true,
              onTap: () async {
                await removeAuthToken();
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool destructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive
        ? AppColors.danger
        : (selected ? theme.colorScheme.primary : theme.colorScheme.onSurface);
    final bg = selected
        ? theme.colorScheme.primary.withOpacity(0.10)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
