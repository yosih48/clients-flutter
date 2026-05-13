import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'callsInfo.dart';

class callsTodo extends StatefulWidget {
  const callsTodo({super.key});

  @override
  State<callsTodo> createState() => _callsTodoState();
}

class _callsTodoState extends State<callsTodo> {
  bool _showInProgress = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.todo)),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented tab control
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentTab(
                        label: loc.todoTab,
                        icon: Icons.list_rounded,
                        selected: !_showInProgress,
                        onTap: () =>
                            setState(() => _showInProgress = false),
                      ),
                    ),
                    Expanded(
                      child: _SegmentTab(
                        label: loc.inProgressTab,
                        icon: Icons.work_history_rounded,
                        selected: _showInProgress,
                        onTap: () =>
                            setState(() => _showInProgress = true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _showInProgress
                    ? FirebaseFirestore.instance
                        .collectionGroup('calls')
                        .where('inProgress', isEqualTo: true)
                        .where('userRef',
                            isEqualTo:
                                FirebaseAuth.instance.currentUser!.uid)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collectionGroup('calls')
                        .where('done', isEqualTo: false)
                        .where('userRef',
                            isEqualTo:
                                FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint('callsTodo query error: ${snapshot.error}');
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: EmptyState(
                        icon: Icons.error_outline_rounded,
                        title: loc.couldNotLoadCalls,
                        subtitle:
                            '${loc.firestoreIndexError}\n\n${snapshot.error}',
                      ),
                    );
                  }
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (!(snapshot.hasData) ||
                      snapshot.data!.docs.isEmpty) {
                    return EmptyState(
                      icon: _showInProgress
                          ? Icons.work_history_rounded
                          : Icons.check_circle_outline_rounded,
                      title: _showInProgress
                          ? loc.noCallsInProgress
                          : loc.allCaughtUp,
                      subtitle: _showInProgress
                          ? loc.noCallsInProgressHint
                          : loc.noPendingTickets,
                    );
                  }

                  final callDocs = snapshot.data!.docs;
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: callDocs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final callData =
                          callDocs[index].data() as Map<String, dynamic>;
                      return SoftCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClientServiceScreen(
                              call: callData,
                              user: callData['clientRef'],
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            InitialAvatar(
                                name: callData['clientName'] ?? '?',
                                size: 48),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    callData['clientName'] ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    callData['call'] ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: AppColors.inkMuted),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  StatusPill.info(
                                      callData['type']?.toString() ??
                                          '',
                                      icon: Icons.handyman_outlined),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Directionality.of(context) ==
                                      TextDirection.rtl
                                  ? Icons.chevron_left_rounded
                                  : Icons.chevron_right_rounded,
                              color: AppColors.inkMuted,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: selected ? AppShadows.soft : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : AppColors.inkMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.inkMuted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
