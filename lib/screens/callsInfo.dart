import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:clientsf/l10n/app_localizations.dart';

class ClientServiceScreen extends StatelessWidget {
  final Map<String, dynamic> call;
  final user;
  const ClientServiceScreen(
      {super.key, required this.call, required this.user});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final List<dynamic> products = call['products'] ?? [];

    final computerProduct = call['computerProduct'];
    final quantity = call['quantity'];
    final officeVersion = call['officeVersion'];
    final windowsLicense = call['windowsLicense'] ?? false;
    final officeLicense = call['officeLicense'] ?? false;
    final extraPayment = call['extraPayment'];
    final partsPaid = call['partsPaid'] ?? false;
    final done = call['done'] ?? false;
    final inProgress = call['inProgress'] ?? false;
    final paid = call['paid'] ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(loc.callDetails)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero payment summary
            Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: paid
                      ? [AppColors.success, const Color(0xFF1F9569)]
                      : [AppColors.warning, const Color(0xFFE08A3D)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: (paid ? AppColors.success : AppColors.warning)
                        .withOpacity(0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          paid ? loc.yes : loc.no,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        paid
                            ? Icons.check_circle_outline_rounded
                            : Icons.schedule_rounded,
                        color: Colors.white.withOpacity(0.85),
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.paymentAmount,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${call['payment'] ?? 0} ₪',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Status chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (done)
                  StatusPill.success(loc.done,
                      icon: Icons.check_circle_outline_rounded)
                else
                  StatusPill.warning(loc.statusOpen,
                      icon: Icons.radio_button_unchecked_rounded),
                if (inProgress)
                  StatusPill.info(loc.statusInProgress,
                      icon: Icons.work_history),
                if (partsPaid)
                  StatusPill.success(loc.partsPaidLabel,
                      icon: Icons.inventory_2_outlined),
              ],
            ),
            const SizedBox(height: 20),

            // General info
            _Section(title: loc.sectionGeneral),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Column(
                children: [
                  InfoRow(
                      label: loc.typeofService,
                      value: '${call['type'] ?? '—'}'),
                  Divider(color: Theme.of(context).dividerColor, height: 1),
                  InfoRow(
                      label: loc.description,
                      value: '${call['call'] ?? '—'}'),
                  Divider(color: Theme.of(context).dividerColor, height: 1),
                  InfoRow(label: loc.sumHours, value: '${call['hour'] ?? '—'}'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _Section(title: loc.sectionPayment),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Column(
                children: [
                  InfoRow(
                    label: loc.paymentStatus,
                    value: paid ? loc.yes : loc.no,
                    valueColor:
                        paid ? AppColors.success : AppColors.warning,
                  ),
                  if (extraPayment != null && extraPayment != 0) ...[
                    Divider(
                        color: Theme.of(context).dividerColor, height: 1),
                    InfoRow(
                        label: loc.extraPayment,
                        value: '$extraPayment ₪'),
                  ],
                  Divider(color: Theme.of(context).dividerColor, height: 1),
                  InfoRow(
                    label: loc.partsPaidLabel,
                    value: partsPaid ? loc.yes : loc.no,
                    valueColor:
                        partsPaid ? AppColors.success : AppColors.inkMuted,
                  ),
                ],
              ),
            ),

            if (computerProduct != null ||
                officeVersion != null ||
                windowsLicense ||
                officeLicense) ...[
              const SizedBox(height: 20),
              _Section(title: loc.sectionAdditional),
              SoftCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Column(
                  children: [
                    if (computerProduct != null) ...[
                      InfoRow(
                          label: loc.selectProduct,
                          value: '$computerProduct'),
                      if (quantity != null)
                        InfoRow(
                            label: loc.quantity, value: '$quantity'),
                    ],
                    if (officeVersion != null)
                      InfoRow(
                          label: loc.officeVersion,
                          value: '$officeVersion'),
                    if (windowsLicense)
                      InfoRow(
                          label: loc.windowsLicense, value: loc.yes,
                          valueColor: AppColors.success),
                    if (officeLicense)
                      InfoRow(
                          label: loc.officeLicense, value: loc.yes,
                          valueColor: AppColors.success),
                  ],
                ),
              ),
            ],

            if (products.isNotEmpty) ...[
              const SizedBox(height: 20),
              _Section(title: loc.products),
              SoftCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  children: products
                      .asMap()
                      .entries
                      .map((entry) {
                        final i = entry.key;
                        final p = entry.value;
                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      p['name'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text(
                                    '${p['discountedPrice'] ?? 0} ₪',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            if (i < products.length - 1)
                              Divider(
                                  color:
                                      Theme.of(context).dividerColor,
                                  height: 1),
                          ],
                        );
                      })
                      .toList(),
                ),
              ),
            ],

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_rounded, size: 20),
                label: Text(loc.edit),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/action',
                      arguments: {
                        'id': call['id'],
                        'call': call['call'],
                        'type': call['type'],
                        'hour': call['hour'],
                        'paid': call['paid'],
                        'payment': call['payment'],
                        'done': call['done'],
                        'extraPayment': call['extraPayment'],
                        'products': call['products'],
                        'usera': user,
                        'partsPaid': call['partsPaid'],
                        'computerProduct': call['computerProduct'],
                        'quantity': call['quantity'],
                        'officeVersion': call['officeVersion'],
                        'windowsLicense': call['windowsLicense'],
                        'officeLicense': call['officeLicense'],
                        'inProgress': call['inProgress'],
                        'fromScreen1': true
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.inkMuted,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
