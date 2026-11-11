import 'package:clientsf/l10n/app_localizations.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../componenets/alertDialog.dart';
import '../componenets/app_prefs.dart';
import '../componenets/auth.dart';
import '../componenets/hourly_rate.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const double _sliderMax = 500;

  int hourlyRate = 0;
  String? _version;

  @override
  void initState() {
    super.initState();
    _loadRate();
    _loadVersion();
  }

  Future<void> _loadRate() async {
    final stored = await loadHourlyRate();
    if (mounted) setState(() => hourlyRate = stored);
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = '${info.version} (${info.buildNumber})');
      }
    } catch (_) {}
  }

  Future<void> _setRate(int value) async {
    setState(() => hourlyRate = value);
    await saveHourlyRate(value);
  }

  Future<void> _editRate() async {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: '$hourlyRate');
    final value = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.hourlyRateNative),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(suffixText: '₪'),
          onSubmitted: (v) => Navigator.pop(ctx, int.tryParse(v)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(loc.cancel)),
          ElevatedButton(
              onPressed: () =>
                  Navigator.pop(ctx, int.tryParse(controller.text)),
              child: Text(loc.save)),
        ],
      ),
    );
    controller.dispose();
    if (value != null) await _setRate(value);
  }

  Future<void> _changePassword(String email) async {
    final loc = AppLocalizations.of(context)!;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showToast(loc.passwordResetSent(email));
    } catch (e) {
      debugPrint('password reset failed: $e');
      showToast(loc.authGenericError);
    }
  }

  Future<void> _confirmSignOut() async {
    final loc = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.signOutConfirmTitle),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(loc.signout),
          ),
        ],
      ),
    );
    if (ok == true && mounted) await signOutUser(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    final identity = email ?? user?.phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          // ── Work
          _SectionTitle(loc.sectionWork),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _IconBadge(icon: Icons.access_time_rounded),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.hourlyRateNative,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(loc.tapToTypeRate,
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12.5)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _editRate,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$hourlyRate ₪',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.primary),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.edit_rounded,
                                size: 16, color: scheme.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: hourlyRate.toDouble().clamp(0, _sliderMax),
                  min: 0,
                  max: _sliderMax,
                  divisions: (_sliderMax / 5).round(),
                  label: '$hourlyRate',
                  onChanged: (v) => setState(() => hourlyRate = v.round()),
                  // Persist once, when the user lets go.
                  onChangeEnd: (v) => _setRate(v.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Appearance
          _SectionTitle(loc.sectionAppearance),
          SoftCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.themeLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 10),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: AppPrefs.themeMode,
                  builder: (context, mode, _) => SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(loc.followSystem),
                            icon: const Icon(Icons.brightness_auto_rounded,
                                size: 18)),
                        ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(loc.themeLight),
                            icon: const Icon(Icons.light_mode_rounded,
                                size: 18)),
                        ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(loc.themeDark),
                            icon: const Icon(Icons.dark_mode_rounded,
                                size: 18)),
                      ],
                      selected: {mode},
                      onSelectionChanged: (s) =>
                          AppPrefs.setThemeMode(s.first),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(loc.languageLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 10),
                ValueListenableBuilder<Locale?>(
                  valueListenable: AppPrefs.locale,
                  builder: (context, locale, _) => SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                            value: '', label: Text(loc.followSystem)),
                        const ButtonSegment(value: 'he', label: Text('עברית')),
                        const ButtonSegment(
                            value: 'en', label: Text('English')),
                      ],
                      selected: {locale?.languageCode ?? ''},
                      onSelectionChanged: (s) => AppPrefs.setLocale(
                          s.first.isEmpty ? null : Locale(s.first)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Account
          _SectionTitle(loc.sectionAccount),
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                if (identity.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        InitialAvatar(name: identity, size: 40),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.signedInAs,
                                  style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 12.5)),
                              Text(
                                identity,
                                textDirection: TextDirection.ltr,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _Divider(),
                ],
                if (email != null) ...[
                  _SettingsTile(
                    icon: Icons.lock_reset_rounded,
                    label: loc.changePassword,
                    onTap: () => _changePassword(email),
                  ),
                  const _Divider(),
                ],
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  label: loc.signout,
                  color: AppColors.danger,
                  showChevron: false,
                  onTap: _confirmSignOut,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── About
          _SectionTitle(loc.sectionMisc),
          SoftCard(
            padding: EdgeInsets.zero,
            child: _SettingsTile(
              icon: Icons.copyright_outlined,
              label: loc.openSourceLicenses,
              onTap: () => showLicensePage(
                context: context,
                applicationName: loc.appName,
                applicationVersion: _version,
              ),
            ),
          ),
          if (_version != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                loc.versionLabel(_version!),
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
              ),
            ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: scheme.primary, size: 20),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8, bottom: 10, top: 8),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool showChevron;
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: c, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            if (showChevron)
              // chevron_right mirrors itself in RTL.
              Icon(Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 54),
      child: Divider(height: 1, color: Theme.of(context).dividerColor),
    );
  }
}
