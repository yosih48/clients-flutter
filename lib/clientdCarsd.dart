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

/// The "Clients" tab: greeting header, today's work at a glance, search and
/// the client list.
class ClientsHome extends StatelessWidget {
  final VoidCallback onOpenTodo;
  const ClientsHome({super.key, required this.onOpenTodo});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: UserListView(onOpenTodo: onOpenTodo),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => displayDialog(context, null),
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 22),
        label: Text(loc.addUser),
      ),
    );
  }
}

class UserListView extends StatefulWidget {
  final VoidCallback? onOpenTodo;
  const UserListView({super.key, this.onOpenTodo});

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

  /// Not-done calls (same query and index as the todo tab) for the
  /// "at a glance" tiles.
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _openCallsStream =
      FirebaseFirestore.instance
          .collectionGroup('calls')
          .where('done', isEqualTo: false)
          .where('userRef', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

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
    return qDigits.isNotEmpty &&
        _digitsOnly(user.phone ?? '').contains(qDigits);
  }

  String _greeting(AppLocalizations loc) {
    final hour = DateTime.now().hour;
    final name =
        (FirebaseAuth.instance.currentUser?.displayName ?? '').trim();
    final first = name.isEmpty ? '' : name.split(RegExp(r'\s+')).first;
    final base = hour < 12
        ? loc.goodMorning
        : hour < 18
            ? loc.goodAfternoon
            : loc.goodEvening;
    return first.isEmpty ? base : '$base, $first';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _clientsStream,
      builder: (context, snapshot) {
        final users = (snapshot.data?.docs ?? []).map((doc) {
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
        final filtered = users.where((u) => _matches(u, searchQuery)).toList();

        Widget listBody;
        if (snapshot.hasError) {
          debugPrint('clients query error: ${snapshot.error}');
          listBody = SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              title: loc.loadClientsError,
              subtitle: loc.authNetworkError,
            ),
          );
        } else if (!snapshot.hasData) {
          listBody = const SliverToBoxAdapter(child: _ClientListSkeleton());
        } else if (filtered.isEmpty) {
          listBody = SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.people_outline_rounded,
              title: searchQuery.isEmpty
                  ? loc.noClientsYet
                  : loc.noMatchingClients,
              subtitle: searchQuery.isEmpty
                  ? loc.noClientsHint
                  : loc.tryDifferentSearch,
            ),
          );
        } else {
          listBody = SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _ClientCard(user: filtered[i]),
            ),
          );
        }

        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: PageHeader(
                overline: _greeting(loc),
                title: loc.clients,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _GlanceRow(
                  clientsCount: snapshot.hasData ? users.length : null,
                  openCallsStream: _openCallsStream,
                  onOpenTodo: widget.onOpenTodo,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: loc.searchcustomer,
                    prefixIcon: const Icon(Icons.search_rounded),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    suffixIcon: searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: loc.clear,
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => searchQuery = '');
                            },
                          ),
                  ),
                  onChanged: (value) =>
                      setState(() => searchQuery = value.trim()),
                ),
              ),
            ),
            if (snapshot.hasData && users.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: Text(
                    searchQuery.isEmpty
                        ? loc.clientsCount(users.length)
                        : loc.showingOfTotal(filtered.length, users.length),
                    style: theme.textTheme.labelMedium?.copyWith(color: muted),
                  ),
                ),
              ),
            if (_showSwipeHint && filtered.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _SwipeHint(onDismiss: _dismissSwipeHint),
                ),
              ),
            listBody,
          ],
        );
      },
    );
  }
}

/// Three KPI tiles under the greeting: clients, open calls, in progress.
class _GlanceRow extends StatelessWidget {
  final int? clientsCount;
  final Stream<QuerySnapshot<Map<String, dynamic>>> openCallsStream;
  final VoidCallback? onOpenTodo;

  const _GlanceRow({
    required this.clientsCount,
    required this.openCallsStream,
    required this.onOpenTodo,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: openCallsStream,
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        final inProgress =
            docs.where((d) => d.data()['inProgress'] == true).length;
        final open = docs.length - inProgress;
        String v(int? n) => n == null ? '–' : '$n';

        return Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.people_alt_rounded,
                label: loc.clients,
                value: v(clientsCount),
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                icon: Icons.inbox_rounded,
                label: loc.glanceOpen,
                value: v(snap.hasData ? open : null),
                color: AppColors.warning,
                onTap: onOpenTodo,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                icon: Icons.build_circle_rounded,
                label: loc.glanceInProgress,
                value: v(snap.hasData ? inProgress : null),
                color: const Color(0xFF0891B2),
                onTap: onOpenTodo,
              ),
            ),
          ],
        );
      },
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
      padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 4, 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.swipe_rounded,
              size: 20, color: scheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loc.swipeHint,
              style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: Icon(Icons.close_rounded,
                size: 18, color: scheme.onPrimaryContainer),
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
    final scheme = theme.colorScheme;
    final phone = (user.phone ?? '').trim();
    final address = (user.address ?? '').trim();
    final subtitle = [if (phone.isNotEmpty) phone, if (address.isNotEmpty) address];

    return Slidable(
      key: ValueKey(user.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.42,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: _SwipeAction(
              icon: Icons.edit_rounded,
              label: loc.edit,
              color: scheme.primary,
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
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => clientInfo(user: user)),
        ),
        onLongPress: phone.isEmpty
            ? null
            : () async {
                await Clipboard.setData(ClipboardData(text: phone));
                showToast(loc.phoneCopied);
              },
        child: Row(
          children: [
            InitialAvatar(name: user.name, size: 46),
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
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            if (phone.isNotEmpty)
              _RoundAction(
                icon: Icons.call_rounded,
                color: AppColors.success,
                tooltip: loc.callAction,
                onTap: () => dialPhone(context, phone),
              ),
            _RoundAction(
              icon: Icons.add_rounded,
              color: scheme.primary,
              tooltip: loc.openTicket,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => actions(user: user)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tonal circular quick action on a client row.
class _RoundAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 6),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: color.withOpacity(isDark ? 0.22 : 0.10),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(icon,
                  size: 20,
                  color: isDark ? Color.lerp(color, Colors.white, 0.3) : color),
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: color.withOpacity(isDark ? 0.22 : 0.10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
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
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder rows shown while the client list loads.
class _ClientListSkeleton extends StatelessWidget {
  const _ClientListSkeleton();

  @override
  Widget build(BuildContext context) {
    final block = Theme.of(context).colorScheme.surfaceContainerHighest;

    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: block,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          for (var i = 0; i < 6; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SoftCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration:
                          BoxDecoration(color: block, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bar(130, 14),
                          const SizedBox(height: 8),
                          bar(190, 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
