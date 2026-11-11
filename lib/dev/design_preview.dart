// Development-only visual preview of the design system with sample data.
// Run: flutter run -d web-server --web-port 8787 -t lib/dev/design_preview.dart
// Not used by the app itself.
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatefulWidget {
  const _PreviewApp();

  @override
  State<_PreviewApp> createState() => _PreviewAppState();
}

class _PreviewAppState extends State<_PreviewApp> {
  ThemeMode _mode = Uri.base.queryParameters['dark'] == '1'
      ? ThemeMode.dark
      : ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('he'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('he')],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _mode,
      home: _Shell(
        onToggleTheme: () => setState(() => _mode =
            _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
      ),
    );
  }
}

class _Shell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const _Shell({required this.onToggleTheme});

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _tab = int.tryParse(Uri.base.queryParameters['tab'] ?? '') ?? 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _ClientsPreview(onToggleTheme: widget.onToggleTheme),
      const _CallPreview(),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: pages[_tab.clamp(0, 1)]),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('הוסף לקוח'),
            )
          : null,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor))),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i.clamp(0, 1)),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_rounded),
                label: 'לקוחות'),
            NavigationDestination(
                icon: Icon(Icons.task_alt_outlined),
                selectedIcon: Icon(Icons.task_alt_rounded),
                label: 'לביצוע'),
            NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights_rounded),
                label: 'הכנסות'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'הגדרות'),
          ],
        ),
      ),
    );
  }
}

class _ClientsPreview extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const _ClientsPreview({required this.onToggleTheme});

  static const _clients = [
    ['דוד לוי', '050-1234567', 'הרצל 12, תל אביב'],
    ['מיכל כהן', '052-7654321', 'רמת גן'],
    ['יוסי אברהם', '054-1112233', ''],
    ['שרה מזרחי', '', 'חיפה'],
    ['אבי פרץ', '053-9988776', 'ירושלים'],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        PageHeader(
          overline: 'ערב טוב, יוסי',
          title: 'לקוחות',
          actions: [
            IconButton(
                onPressed: onToggleTheme,
                icon: const Icon(Icons.dark_mode_outlined)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                  child: StatTile(
                      icon: Icons.people_alt_rounded,
                      label: 'לקוחות',
                      value: '24',
                      color: scheme.primary)),
              const SizedBox(width: 8),
              const Expanded(
                  child: StatTile(
                      icon: Icons.inbox_rounded,
                      label: 'פתוחות',
                      value: '5',
                      color: AppColors.warning)),
              const SizedBox(width: 8),
              const Expanded(
                  child: StatTile(
                      icon: Icons.build_circle_rounded,
                      label: 'בעבודה',
                      value: '2',
                      color: Color(0xFF0891B2))),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'חפש לקוח',
              prefixIcon: Icon(Icons.search_rounded),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: Text('24 לקוחות', style: theme.textTheme.labelMedium),
        ),
        for (final c in _clients)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SoftCard(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
              onTap: () {},
              child: Row(
                children: [
                  InitialAvatar(name: c[0], size: 46),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c[0],
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          [c[1], c[2]].where((s) => s.isNotEmpty).join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (c[1].isNotEmpty)
                    _round(context, Icons.call_rounded, AppColors.success),
                  _round(context, Icons.add_rounded, scheme.primary),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _round(BuildContext context, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 6),
      child: Material(
        color: color.withOpacity(isDark ? 0.22 : 0.10),
        shape: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon,
              size: 20,
              color: isDark ? Color.lerp(color, Colors.white, 0.3) : color),
        ),
      ),
    );
  }
}

class _CallPreview extends StatelessWidget {
  const _CallPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        const PageHeader(
            title: 'פרטי קריאה',
            overline: 'דוד לוי · 12 בנובמבר 2026',
            padding: EdgeInsets.fromLTRB(4, 12, 4, 16)),
        AmountCard(
          label: 'סכום לתשלום',
          amount: '450 ₪',
          color: AppColors.warning,
          icon: Icons.receipt_long_rounded,
          caption: 'חיוב נוסף 200  + שעתיים × 150  − סה"כ עלויות 50',
          badge: StatusPill.warning('ממתין', icon: Icons.schedule_rounded),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.payments_outlined, size: 18),
                    label: const Text('סמן כשולם'))),
            const SizedBox(width: 10),
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.task_alt_rounded, size: 18),
                    label: const Text('סמן כבוצע'))),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 6, children: [
          StatusPill.info('בעבודה', icon: Icons.build_rounded),
          StatusPill.success('חלקים שולמו',
              icon: Icons.inventory_2_outlined),
        ]),
        const SizedBox(height: 16),
        const SectionHeader('תיאור קריאה'),
        SoftCard(
          padding: const EdgeInsets.all(16),
          child: Text('המחשב לא עולה, החלפת ספק כוח ובדיקת זיכרון.',
              style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: 16),
        const SectionHeader('כללי'),
        const SoftCard(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Column(children: [
            InfoRow(label: 'סוג שירות', value: 'בית הלקוח'),
            Divider(height: 1),
            InfoRow(label: 'שעות עבודה', value: '1:30'),
          ]),
        ),
        const SizedBox(height: 16),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 0, label: Text('פתוח')),
            ButtonSegment(value: 1, label: Text('בעבודה')),
            ButtonSegment(value: 2, label: Text('בוצע')),
          ],
          selected: const {1},
          onSelectionChanged: (_) {},
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () {}, child: const Text('שמור שינויים')),
      ],
    );
  }
}
