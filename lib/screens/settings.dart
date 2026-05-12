import 'package:clientsf/singelton/AppSingelton.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int hourlyRate = 0;

  bool lockAppSwitchVal = true;
  bool fingerprintSwitchVal = false;
  bool changePassSwitchVal = true;

  Future<void> getStoredHourlyRate() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt('${AppSingelton().userID}_newValue') ?? 0;
    setState(() => hourlyRate = stored);
  }

  Future<void> _saveRate(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${AppSingelton().userID}_newValue', value);
  }

  @override
  void initState() {
    super.initState();
    getStoredHourlyRate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          _SectionTitle('Work'),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.access_time_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('שווי שעת עבודה',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          Text('Hourly rate',
                              style: TextStyle(
                                  color: AppColors.inkMuted,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                      '${hourlyRate.toString()} ₪',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: hourlyRate.toDouble().clamp(0, 400),
                  min: 0,
                  max: 400,
                  divisions: 100,
                  label: '$hourlyRate',
                  onChanged: (v) {
                    setState(() => hourlyRate = v.toInt());
                    _saveRate(v.toInt());
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Account'),
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                    icon: Icons.phone_outlined,
                    label: 'Phone number',
                    onTap: () {}),
                _Divider(),
                _SettingsTile(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    onTap: () {}),
                _Divider(),
                _SettingsTile(
                    icon: Icons.logout_rounded,
                    label: 'Sign out',
                    color: AppColors.danger,
                    onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Security'),
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SwitchTile(
                  icon: Icons.phonelink_lock_outlined,
                  label: 'Lock app in background',
                  value: lockAppSwitchVal,
                  onChanged: (v) => setState(() => lockAppSwitchVal = v),
                ),
                _Divider(),
                _SwitchTile(
                  icon: Icons.fingerprint_rounded,
                  label: 'Use fingerprint',
                  value: fingerprintSwitchVal,
                  onChanged: (v) =>
                      setState(() => fingerprintSwitchVal = v),
                ),
                _Divider(),
                _SwitchTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change password',
                  value: changePassSwitchVal,
                  onChanged: (v) => setState(() => changePassSwitchVal = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Misc'),
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                    icon: Icons.description_outlined,
                    label: 'Terms of service',
                    onTap: () {}),
                _Divider(),
                _SettingsTile(
                    icon: Icons.copyright_outlined,
                    label: 'Open source & licenses',
                    onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10, top: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.inkMuted,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.0,
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
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
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
                      color: c,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: AppColors.inkMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 54),
      child: Divider(height: 1, color: Theme.of(context).dividerColor),
    );
  }
}
