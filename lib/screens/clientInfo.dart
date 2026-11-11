import 'package:clientsf/clientdCarsd.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clientsf/objects/clients.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import '../componenets/addClientDialof.dart';
import '../componenets/alertDialog.dart';
import '../componenets/launchers.dart';
import 'actions.dart';
import 'clientCalls.dart';

/// Darker orange than [AppColors.warning], readable on white.
const Color _directionsColor = Color(0xFFD9822B);

class clientInfo extends StatefulWidget {
  final Todo user;
  const clientInfo({super.key, required this.user});

  @override
  State<clientInfo> createState() => _ClientInfoState();
}

class _ClientInfoState extends State<clientInfo> {
  final _scrollController = ScrollController();
  bool _showTitle = false;

  // Live client document, so edits made from this screen show up at once.
  late final DocumentReference<Map<String, dynamic>> _clientRef =
      clientsCollection().doc(widget.user.id);
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _clientStream =
      _clientRef.snapshots();
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _callsStream =
      _clientRef.collection('calls').snapshots();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 140;
      if (show != _showTitle) setState(() => _showTitle = show);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Todo _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data() ?? const {};
    return Todo(
      id: snap.id,
      name: data['name'],
      email: data['email'],
      address: data['address'],
      phone: data['phone'],
      completed: false,
    );
  }

  void _confirmDelete(Todo user) {
    final loc = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialogw(
      context,
      onConfirm: () async {
        try {
          await deleteClientWithCalls(user.id);
          // The confirm dialog is already closed here; leave this screen.
          if (mounted) navigator.pop();
          messenger.showSnackBar(
              SnackBar(content: Text(loc.clientDeleted(user.name ?? ''))));
        } catch (e) {
          debugPrint('delete client failed: $e');
          messenger.showSnackBar(SnackBar(content: Text(loc.deleteFailed)));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _clientStream,
      builder: (context, snapshot) {
        final snap = snapshot.data;
        // Until the first snapshot arrives show what the list passed in.
        final user = snap == null
            ? widget.user
            : (snap.exists ? _fromSnapshot(snap) : null);

        return Scaffold(
          appBar: AppBar(
            title: AnimatedOpacity(
              opacity: _showTitle ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Text(user?.name ?? ''),
            ),
            actions: user == null
                ? null
                : [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      tooltip: loc.editClient,
                      onPressed: () => displayDialog(context, user.id),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') _confirmDelete(user);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.danger),
                              const SizedBox(width: 12),
                              Text(loc.deleteClient,
                                  style:
                                      const TextStyle(color: AppColors.danger)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                  ],
          ),
          body: user == null
              ? EmptyState(
                  icon: Icons.person_off_outlined,
                  title: loc.clientNotFound,
                  subtitle: '',
                )
              : _buildBody(context, user),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, Todo user) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final phone = (user.phone ?? '').trim();
    final email = (user.email ?? '').trim();
    final address = (user.address ?? '').trim();

    return SingleChildScrollView(
      controller: _scrollController,
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
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: muted, fontWeight: FontWeight.w500),
                  ),
                ],
                const SizedBox(height: 12),
                _CallsSummary(stream: _callsStream),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick actions row
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.call_rounded,
                  label: loc.callAction,
                  color: AppColors.success,
                  onTap: () => dialPhone(context, phone),
                  enabled: phone.isNotEmpty,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.chat_rounded,
                  label: loc.whatsappAction,
                  color: const Color(0xFF1FA855),
                  onTap: () => openWhatsApp(context, phone),
                  enabled: phone.isNotEmpty,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.mail_outline_rounded,
                  label: loc.emailAction,
                  color: theme.colorScheme.primary,
                  onTap: () => sendEmail(context, email),
                  enabled: email.isNotEmpty,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.directions_rounded,
                  label: loc.directionsAction,
                  color: _directionsColor,
                  onTap: () => openNavigation(context, address),
                  enabled: address.isNotEmpty,
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
                  value: phone,
                  ltr: true,
                  onTap: () => dialPhone(context, phone),
                ),
                _DetailTile(
                  icon: Icons.mail_outline_rounded,
                  label: loc.emailLabel,
                  value: email,
                  ltr: true,
                  onTap: () => sendEmail(context, email),
                ),
                _DetailTile(
                  icon: Icons.place_outlined,
                  label: loc.addressLabel,
                  value: address,
                  onTap: () => openNavigation(context, address),
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => actions(user: user)),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: Text(loc.openTicket),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CallsScreen(clientId: user)),
              ),
              icon: const Icon(Icons.history_rounded, size: 20),
              label: Text(loc.callHistory),
            ),
          ),
        ],
      ),
    );
  }
}

/// "3 open calls · last call 5 days ago" pill under the client's name.
class _CallsSummary extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  const _CallsSummary({required this.stream});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 28);
        final docs = snapshot.data!.docs;

        final String text;
        if (docs.isEmpty) {
          text = loc.clientNoCalls;
        } else {
          final open = docs.where((d) => d.data()['done'] != true).length;
          int? latest;
          for (final d in docs) {
            final t = d.data()['timestamp'];
            if (t is int && (latest == null || t > latest)) latest = t;
          }
          final parts = <String>[loc.clientOpenCalls(open)];
          if (latest != null) {
            final last = DateTime.fromMillisecondsSinceEpoch(latest);
            final now = DateTime.now();
            final days = DateTime(now.year, now.month, now.day)
                .difference(DateTime(last.year, last.month, last.day))
                .inDays;
            parts.add(loc.clientLastCall(days < 0 ? 0 : days));
          }
          text = parts.join(' · ');
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        );
      },
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
      opacity: enabled ? 1 : 0.45,
      child: SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
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
  final String value;
  final VoidCallback onTap;
  final bool isLast;

  /// Phone numbers and emails read left-to-right even in Hebrew.
  final bool ltr;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.isLast = false,
    this.ltr = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final hasValue = value.isNotEmpty;
    final dir = Directionality.of(context);

    return InkWell(
      onTap: hasValue ? onTap : null,
      onLongPress: hasValue
          ? () async {
              await Clipboard.setData(ClipboardData(text: value));
              showToast(loc.copiedToClipboard);
            }
          : null,
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
                    color: scheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 20, color: scheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text(
                        hasValue ? value : '—',
                        textDirection:
                            hasValue && ltr ? TextDirection.ltr : null,
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: hasValue
                                ? null
                                : scheme.onSurfaceVariant.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
                if (hasValue)
                  Icon(
                    dir == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          if (!isLast)
            Divider(height: 1, color: theme.dividerColor, indent: 70),
        ],
      ),
    );
  }
}
