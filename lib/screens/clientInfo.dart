import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clientsf/objects/clients.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import '../componenets/addClientDialof.dart';

class clientInfo extends StatelessWidget {
  final Todo user;
  const clientInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: loc.editClient,
              onPressed: () => displayDialog(context, user.id),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  InitialAvatar(name: user.name, size: 96),
                  const SizedBox(height: 18),
                  Text(
                    user.name ?? '',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  if ((user.email ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      user.email!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkMuted,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Quick actions row
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.call_rounded,
                    label: loc.callAction,
                    color: AppColors.success,
                    onTap: () => _launchPhoneDialer(user.phone ?? ''),
                    enabled: (user.phone ?? '').isNotEmpty,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.mail_outline_rounded,
                    label: loc.emailAction,
                    color: AppColors.primary,
                    onTap: () => launchEmailSubmission(user.email ?? ''),
                    enabled: (user.email ?? '').isNotEmpty,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.directions_rounded,
                    label: loc.directionsAction,
                    color: AppColors.warning,
                    onTap: () => openWaze(user.address ?? ''),
                    enabled: (user.address ?? '').isNotEmpty,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Contact details
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _DetailTile(
                    icon: Icons.phone_outlined,
                    label: loc.phoneLabel,
                    value: user.phone,
                    onTap: () => _launchPhoneDialer(user.phone ?? ''),
                  ),
                  _DetailTile(
                    icon: Icons.mail_outline_rounded,
                    label: loc.emailLabel,
                    value: user.email,
                    onTap: () => launchEmailSubmission(user.email ?? ''),
                  ),
                  _DetailTile(
                    icon: Icons.place_outlined,
                    label: loc.addressLabel,
                    value: user.address,
                    onTap: () => openWaze(user.address ?? ''),
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => displayDialog(context, user.id),
                icon: const Icon(Icons.edit_rounded, size: 20),
                label: Text(loc.editClient),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 18),
        onTap: enabled ? onTap : null,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool isLast;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = (value ?? '').isNotEmpty;
    final dir = Directionality.of(context);

    return InkWell(
      onTap: hasValue ? onTap : null,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon,
                      size: 20, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: AppColors.inkMuted)),
                      const SizedBox(height: 2),
                      Text(
                        hasValue ? value! : '—',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: hasValue ? null : AppColors.inkFaint),
                      ),
                    ],
                  ),
                ),
                if (hasValue)
                  Icon(
                    dir == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: AppColors.inkMuted,
                  ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
                height: 1, color: Theme.of(context).dividerColor, indent: 70),
        ],
      ),
    );
  }
}

void _launchPhoneDialer(String phoneNumber) async {
  final url = 'tel:$phoneNumber';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void launchEmailSubmission(String emailAddress) async {
  final Uri params = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {'subject': 'Default Subject', 'body': 'Default body'});
  final String url = params.toString();
  if (await canLaunch(url)) {
    await launch(url);
  }
}

void openWaze(String address) async {
  final Uri wazeUri = Uri(
    scheme: 'waze',
    path: '/ul',
    queryParameters: {'ll': address},
  );
  if (await canLaunch(wazeUri.toString())) {
    await launch(wazeUri.toString());
  } else {
    openGoogleMaps(address);
  }
}

void openGoogleMaps(String address) async {
  final Uri mapsUri = Uri(
    scheme: 'https',
    host: 'www.google.com',
    path: '/maps/search/',
    queryParameters: {'api': '1', 'query': address},
  );
  if (await canLaunch(mapsUri.toString())) {
    await launch(mapsUri.toString());
  }
}
