import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../clientdCarsd.dart';
import '../componenets/alertDialog.dart';
import '../componenets/service_types.dart';
import 'callsInfo.dart';

/// Calls open longer than this get a warning colour.
const int _staleAfterDays = 7;

class callsTodo extends StatefulWidget {
  const callsTodo({super.key});

  @override
  State<callsTodo> createState() => _callsTodoState();
}

class _TodoCall {
  final DocumentReference<Map<String, dynamic>> ref;
  final Map<String, dynamic> data;
  _TodoCall(this.ref, this.data);

  String get id => (data['id'] as String?) ?? ref.id;
  String? get clientId => data['clientRef'] as String?;
  int get timestamp => data['timestamp'] is int ? data['timestamp'] as int : 0;
  bool get done => data['done'] == true;
  bool get inProgress => data['inProgress'] == true;
}

class _callsTodoState extends State<callsTodo> {
  bool _showInProgress = false;
  bool _cleaning = false;

  // Streams are created once (not on every build). These are the same two
  // queries as before, so the Firestore indexes they rely on still apply.
  late final String _uid = FirebaseAuth.instance.currentUser!.uid;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _notDoneStream =
      FirebaseFirestore.instance
          .collectionGroup('calls')
          .where('done', isEqualTo: false)
          .where('userRef', isEqualTo: _uid)
          .snapshots();
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _inProgressStream =
      FirebaseFirestore.instance
          .collectionGroup('calls')
          .where('inProgress', isEqualTo: true)
          .where('userRef', isEqualTo: _uid)
          .snapshots();

  /// Used to hide calls whose client was deleted (left over from before
  /// deleting a client also deleted its calls).
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _clientsStream =
      clientsCollection().snapshots();

  List<_TodoCall> _toCalls(QuerySnapshot<Map<String, dynamic>>? snap) =>
      snap?.docs.map((d) => _TodoCall(d.reference, d.data())).toList() ?? [];

  Future<void> _deleteOrphans(List<_TodoCall> orphans) async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _cleaning = true);
    try {
      const chunk = 450;
      for (var i = 0; i < orphans.length; i += chunk) {
        final batch = FirebaseFirestore.instance.batch();
        for (final c in orphans.skip(i).take(chunk)) {
          batch.delete(c.ref);
        }
        await batch.commit();
      }
      showToast(loc.orphanCallsDeleted(orphans.length));
    } catch (e) {
      debugPrint('orphan cleanup failed: $e');
      showToast(loc.deleteFailed);
    } finally {
      if (mounted) setState(() => _cleaning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.todo)),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _clientsStream,
          builder: (context, clientsSnap) =>
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _notDoneStream,
            builder: (context, notDoneSnap) =>
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _inProgressStream,
              builder: (context, inProgressSnap) => _buildContent(
                context,
                clientsSnap,
                notDoneSnap,
                inProgressSnap,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> clientsSnap,
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> notDoneSnap,
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> inProgressSnap,
  ) {
    final loc = AppLocalizations.of(context)!;
    final error = notDoneSnap.error ?? inProgressSnap.error;
    final loading = !notDoneSnap.hasData ||
        !inProgressSnap.hasData ||
        !clientsSnap.hasData;

    final clientIds = clientsSnap.data?.docs.map((d) => d.id).toSet();
    bool isOrphan(_TodoCall c) =>
        clientIds != null && c.clientId != null && !clientIds.contains(c.clientId);

    // Each call lands in exactly one tab: in progress wins over to-do.
    final todo = _toCalls(notDoneSnap.data)
        .where((c) => !c.inProgress)
        .toList();
    final inProgress = _toCalls(inProgressSnap.data)
        .where((c) => !c.done)
        .toList();

    final orphans = [...todo, ...inProgress].where(isOrphan).toList();
    int oldestFirst(_TodoCall a, _TodoCall b) =>
        a.timestamp.compareTo(b.timestamp);
    final visibleTodo = todo.where((c) => !isOrphan(c)).toList()
      ..sort(oldestFirst);
    final visibleInProgress = inProgress.where((c) => !isOrphan(c)).toList()
      ..sort(oldestFirst);
    final calls = _showInProgress ? visibleInProgress : visibleTodo;

    Widget body;
    if (error != null) {
      debugPrint('callsTodo query error: $error');
      body = Padding(
        padding: const EdgeInsets.all(24),
        child: EmptyState(
          icon: Icons.error_outline_rounded,
          title: loc.couldNotLoadCalls,
          subtitle: loc.firestoreIndexError,
        ),
      );
    } else if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (calls.isEmpty) {
      body = EmptyState(
        icon: _showInProgress
            ? Icons.work_history_rounded
            : Icons.check_circle_outline_rounded,
        title: _showInProgress ? loc.noCallsInProgress : loc.allCaughtUp,
        subtitle:
            _showInProgress ? loc.noCallsInProgressHint : loc.noPendingTickets,
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: calls.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _TodoTile(call: calls[index]),
      );
    }

    return Column(
      children: [
        // Segmented tab control
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SegmentTab(
                    label: loc.todoTab,
                    count: loading ? null : visibleTodo.length,
                    icon: Icons.list_rounded,
                    selected: !_showInProgress,
                    onTap: () => setState(() => _showInProgress = false),
                  ),
                ),
                Expanded(
                  child: _SegmentTab(
                    label: loc.inProgressTab,
                    count: loading ? null : visibleInProgress.length,
                    icon: Icons.work_history_rounded,
                    selected: _showInProgress,
                    onTap: () => setState(() => _showInProgress = true),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!loading && orphans.isNotEmpty)
          _OrphanBanner(
            count: orphans.length,
            busy: _cleaning,
            onClean: () => _deleteOrphans(orphans),
          ),
        Expanded(child: body),
      ],
    );
  }
}

class _OrphanBanner extends StatelessWidget {
  final int count;
  final bool busy;
  final VoidCallback onClean;
  const _OrphanBanner(
      {required this.count, required this.busy, required this.onClean});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 20, color: Color(0xFFB4651A)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loc.orphanCallsFound(count),
              style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: busy ? null : onClean,
            child: busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(loc.cleanUp),
          ),
        ],
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final _TodoCall call;
  const _TodoTile({required this.call});

  Future<void> _update(BuildContext context, Map<String, dynamic> fields,
      String successMessage) async {
    final loc = AppLocalizations.of(context)!;
    try {
      await call.ref.update(fields);
      showToast(successMessage);
    } catch (e) {
      debugPrint('update call failed: $e');
      showToast(loc.updateFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final data = call.data;
    final description = (data['call'] ?? '').toString().trim();
    final type = data['type']?.toString();

    int? ageDays;
    if (call.timestamp > 0) {
      final opened = DateTime.fromMillisecondsSinceEpoch(call.timestamp);
      final now = DateTime.now();
      ageDays = DateTime(now.year, now.month, now.day)
          .difference(DateTime(opened.year, opened.month, opened.day))
          .inDays
          .clamp(0, 100000);
    }
    final stale = ageDays != null && ageDays >= _staleAfterDays;
    final ageColor = stale ? const Color(0xFFB4651A) : scheme.onSurfaceVariant;

    Widget swipeAction(
        {required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap}) {
      return Expanded(
        child: Builder(
          builder: (slidableContext) => Material(
            color: color.withOpacity(0.14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: color.withOpacity(0.25)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Slidable.of(slidableContext)?.close();
                onTap();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color),
                  const SizedBox(height: 4),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Slidable(
      key: ValueKey(call.ref.path),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: call.inProgress ? 0.26 : 0.5,
        children: [
          const SizedBox(width: 8),
          if (!call.inProgress) ...[
            swipeAction(
              icon: Icons.play_arrow_rounded,
              label: loc.startWork,
              color: scheme.primary,
              onTap: () =>
                  _update(context, {'inProgress': true}, loc.movedToInProgress),
            ),
            const SizedBox(width: 8),
          ],
          swipeAction(
            icon: Icons.task_alt_rounded,
            label: loc.markDone,
            color: AppColors.success,
            onTap: () => _update(context, {'done': true, 'inProgress': false},
                loc.markedDone),
          ),
        ],
      ),
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        onTap: () {
          final clientId = call.clientId;
          if (clientId == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClientServiceScreen(
                call: {...data, 'id': call.id},
                user: clientId,
              ),
            ),
          );
        },
        child: Row(
          children: [
            InitialAvatar(name: data['clientName'] ?? '?', size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['clientName'] ?? '',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (ageDays != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.schedule_rounded, size: 13, color: ageColor),
                        const SizedBox(width: 3),
                        Text(
                          loc.openForDays(ageDays),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  stale ? FontWeight.w700 : FontWeight.w500,
                              color: ageColor),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description.isEmpty ? loc.noDescription : description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontStyle:
                          description.isEmpty ? FontStyle.italic : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((type ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    StatusPill.info(serviceTypeLabel(loc, type),
                        icon: serviceTypeIcon(type)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
                    // chevron_right mirrors itself in RTL.
                    Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final int? count;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.count,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? scheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: selected ? AppShadows.soft : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? scheme.primary : muted),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                count == null ? label : '$label ($count)',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? scheme.onSurface : muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
