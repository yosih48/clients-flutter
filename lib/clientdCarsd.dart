import 'package:clientsf/screens/clientCalls.dart';
import 'package:clientsf/screens/clientInfo.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'componenets/addClientDialof.dart';
import 'componenets/alertDialog.dart';
import 'componenets/launchers.dart';
import 'objects/clients.dart';
import 'screens/actions.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

const _swipeHintPrefKey = 'clientsSwipeHintDismissed';

CollectionReference<Map<String, dynamic>> clientsCollection() =>
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_data');

/// Deletes a client together with its `calls` subcollection. Firestore does
/// not cascade deletes, and the todo screen reads calls through a
/// collectionGroup query, so leftover calls would keep showing up there.
Future<void> deleteClientWithCalls(String clientId) async {
  final clientRef = clientsCollection().doc(clientId);
  final calls = await clientRef.collection('calls').get();

  // A batch holds at most 500 writes.
  const chunk = 450;
  for (var i = 0; i < calls.docs.length; i += chunk) {
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in calls.docs.skip(i).take(chunk)) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
  await clientRef.delete();
}

String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  /// Created once: rebuilding on every search keystroke must not
  /// re-subscribe to Firestore (that flashed a spinner and re-read the data).
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _clientsStream =
      clientsCollection().snapshots();

  bool _showSwipeHint = false;

  @override
  void initState() {
    super.initState();
    _loadSwipeHint();
  }

  Future<void> _loadSwipeHint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getBool(_swipeHintPrefKey) ?? false;
      if (mounted && !dismissed) setState(() => _showSwipeHint = true);
    } catch (_) {}
  }

  Future<void> _dismissSwipeHint() async {
    setState(() => _showSwipeHint = false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_swipeHintPrefKey, true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(Todo user, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    bool has(String? v) => (v ?? '').toLowerCase().contains(q);
    if (has(user.name) || has(user.email) || has(user.address)) return true;

    // Compare phones by digits only, so "0501234567" finds "050-123-4567".
    final qDigits = _digitsOnly(q);
    return qDigits.isNotEmpty && _digitsOnly(user.phone ?? '').contains(qDigits);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: loc.searchcustomer,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: IconButton(
                        tooltip: loc.clear,
                        icon: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child:
                              Icon(Icons.close_rounded, size: 14, color: muted),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      ),
                    ),
            ),
            onChanged: (value) => setState(() => searchQuery = value.trim()),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _clientsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('clients query error: ${snapshot.error}');
                return EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: loc.loadClientsError,
                  subtitle: loc.authNetworkError,
                );
              }
              if (!snapshot.hasData) return const _ClientListSkeleton();

              final users = snapshot.data!.docs.map((doc) {
                final data = doc.data();
                return Todo(
                  id: doc.id,
                  name: data['name'],
                  email: data['email'],
                  address: data['address'],
                  phone: data['phone'],
                  completed: false,
                );
              }).toList()
                ..sort((a, b) => (a.name ?? '')
                    .trim()
                    .toLowerCase()
                    .compareTo((b.name ?? '').trim().toLowerCase()));

              final filteredUsers =
                  users.where((u) => _matches(u, searchQuery)).toList();

              if (filteredUsers.isEmpty) {
                return EmptyState(
                  icon: Icons.people_outline_rounded,
                  title: searchQuery.isEmpty
                      ? loc.noClientsYet
                      : loc.noMatchingClients,
                  subtitle: searchQuery.isEmpty
                      ? loc.noClientsHint
                      : loc.tryDifferentSearch,
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                    child: Text(
                      searchQuery.isEmpty
                          ? loc.clientsCount(users.length)
                          : loc.showingOfTotal(
                              filteredUsers.length, users.length),
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: muted),
                    ),
                  ),
                  if (_showSwipeHint)
                    _SwipeHint(onDismiss: _dismissSwipeHint),
                  for (var i = 0; i < filteredUsers.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _ClientCard(user: filteredUsers[i]),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SwipeHint extends StatelessWidget {
  final VoidCallback onDismiss;
  const _SwipeHint({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 4, 6),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.swipe_rounded, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loc.swipeHint,
              style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: Icon(Icons.close_rounded, size: 18, color: scheme.primary),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Todo user;
  const _ClientCard({required this.user});

  void _confirmDelete(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    showDialogw(
      context,
      onConfirm: () async {
        try {
          await deleteClientWithCalls(user.id);
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
    final theme = Theme.of(context);
    final hasPhone = (user.phone ?? '').trim().isNotEmpty;

    void openInfo() => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => clientInfo(user: user)),
        );

    return Slidable(
      key: ValueKey(user.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.46,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: _SwipeAction(
              icon: Icons.edit_rounded,
              label: loc.edit,
              color: theme.colorScheme.primary,
              onTap: (ctx) {
                Slidable.of(ctx)?.close();
                displayDialog(context, user.id);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SwipeAction(
              icon: Icons.delete_outline_rounded,
              label: loc.delete,
              color: AppColors.danger,
              onTap: (ctx) {
                Slidable.of(ctx)?.close();
                _confirmDelete(context);
              },
            ),
          ),
        ],
      ),
      child: SoftCard(
        padding: EdgeInsets.zero,
        onTap: openInfo,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InitialAvatar(name: user.name, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? '',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        if (hasPhone)
                          _MetaRow(
                            icon: Icons.phone_outlined,
                            text: user.phone!,
                            onTap: () => dialPhone(context, user.phone!),
                            onLongPress: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: user.phone!));
                              showToast(loc.phoneCopied);
                            },
                          ),
                        if ((user.address ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: _MetaRow(
                                icon: Icons.place_outlined,
                                text: user.address!),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: theme.dividerColor),
            Row(
              children: [
                Expanded(
                  child: _CardAction(
                    icon: Icons.call_rounded,
                    label: loc.callAction,
                    color: hasPhone ? AppColors.success : null,
                    onTap: hasPhone ? () => dialPhone(context, user.phone!) : null,
                  ),
                ),
                Container(width: 1, height: 36, color: theme.dividerColor),
                Expanded(
                  child: _CardAction(
                    icon: Icons.history_rounded,
                    label: loc.history,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CallsScreen(clientId: user)),
                    ),
                  ),
                ),
                Container(width: 1, height: 36, color: theme.dividerColor),
                Expanded(
                  child: _CardAction(
                    icon: Icons.add_circle_outline_rounded,
                    label: loc.openTicket,
                    color: theme.colorScheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => actions(user: user)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _MetaRow({
    required this.icon,
    required this.text,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interactive = onTap != null;
    final color =
        interactive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    final row = Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            // Phone numbers stay left-to-right inside RTL layouts.
            textDirection: interactive ? TextDirection.ltr : null,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (!interactive) return row;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: row,
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = color ?? scheme.onSurfaceVariant;
    final fg = onTap == null ? base.withOpacity(0.4) : base;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  /// Receives a context below the [Slidable] so the pane can be closed.
  final void Function(BuildContext slidableContext) onTap;

  const _SwipeAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder cards shown while the client list loads.
class _ClientListSkeleton extends StatelessWidget {
  const _ClientListSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final block = theme.colorScheme.surfaceContainerHighest;

    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: block,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => SoftCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: block, shape: BoxShape.circle),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(140, 14),
                  const SizedBox(height: 10),
                  bar(100, 10),
                  const SizedBox(height: 6),
                  bar(170, 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
