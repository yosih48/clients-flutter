import 'package:clientsf/screens/AppStarter.dart';
import 'package:clientsf/screens/callsTodo.dart';
import 'package:clientsf/screens/settings.dart';
import 'package:clientsf/screens/tableScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:clientsf/l10n/app_localizations.dart';

import 'clientdCarsd.dart';
import 'componenets/app_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await AppPrefs.load();
  runApp(const AppStarter());
}

/// Signed-in root: the four main areas behind a bottom navigation bar.
class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  int _index = 0;

  // Tabs are built lazily the first time they are opened, then kept alive.
  final Set<int> _visited = {0};

  void _goTo(int index) => setState(() {
        _index = index;
        _visited.add(index);
      });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final pages = <Widget>[
      ClientsHome(onOpenTodo: () => _goTo(1)),
      const callsTodo(),
      const DataTableExample(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < pages.length; i++)
            _visited.contains(i) ? pages[i] : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goTo,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.people_outline_rounded),
              selectedIcon: const Icon(Icons.people_rounded),
              label: loc.clients,
            ),
            NavigationDestination(
              icon: const Icon(Icons.task_alt_outlined),
              selectedIcon: const Icon(Icons.task_alt_rounded),
              label: loc.todo,
            ),
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined),
              selectedIcon: const Icon(Icons.insights_rounded),
              label: loc.navIncome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: loc.settings,
            ),
          ],
        ),
      ),
    );
  }
}
