import 'package:clientsf/screens/clientCalls.dart';
import 'package:clientsf/screens/clientInfo.dart';
import 'package:clientsf/theme.dart';
import 'package:clientsf/widgets/app_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'componenets/addClientDialof.dart';
import 'componenets/alertDialog.dart';
import 'objects/clients.dart';
import 'screens/actions.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class UserListView extends StatefulWidget {
  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: loc.searchcustomer,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => searchQuery = '');
                      },
                    ),
            ),
            onChanged: (value) =>
                setState(() => searchQuery = value.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('user_data')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<Todo> users = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Todo(
                  id: doc.id,
                  name: data['name'],
                  email: data['email'],
                  address: data['address'],
                  phone: data['phone'],
                  completed: false,
                );
              }).toList();

              final filteredUsers = users.where((user) {
                return (user.name ?? '').toLowerCase().contains(searchQuery) ||
                    (user.email ?? '').toLowerCase().contains(searchQuery) ||
                    (user.phone ?? '').toLowerCase().contains(searchQuery) ||
                    (user.address ?? '').toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredUsers.isEmpty) {
                return EmptyState(
                  icon: Icons.people_outline_rounded,
                  title: searchQuery.isEmpty
                      ? 'No clients yet'
                      : 'No matching clients',
                  subtitle: searchQuery.isEmpty
                      ? 'Tap the + button to add your first client'
                      : 'Try a different search term',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _ClientCard(user: user);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Todo user;
  const _ClientCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
              onTap: () => displayDialog(context, user.id),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SwipeAction(
              icon: Icons.delete_outline_rounded,
              label: loc.delete,
              color: AppColors.danger,
              onTap: () => showDialogw(
                context,
                onConfirm: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('user_data')
                      .doc(user.id)
                      .delete();
                },
              ),
            ),
          ),
        ],
      ),
      child: SoftCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => clientInfo(user: user)),
        ),
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
                        if ((user.phone ?? '').isNotEmpty)
                          _MetaRow(
                              icon: Icons.phone_outlined,
                              text: user.phone!),
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
                    icon: Icons.info_outline_rounded,
                    label: loc.clientInfo,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => clientInfo(user: user)),
                    ),
                  ),
                ),
                Container(
                    width: 1, height: 36, color: theme.dividerColor),
                Expanded(
                  child: _CardAction(
                    icon: Icons.history_rounded,
                    label: 'History',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CallsScreen(clientId: user)),
                    ),
                  ),
                ),
                Container(
                    width: 1, height: 36, color: theme.dividerColor),
                Expanded(
                  child: _CardAction(
                    icon: Icons.add_circle_outline_rounded,
                    label: loc.openTicket,
                    color: theme.colorScheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => actions(user: user)),
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
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.inkMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkMuted, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.inkMuted;
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
              style: TextStyle(
                color: fg,
                fontSize: 11.5,
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
  final VoidCallback onTap;

  const _SwipeAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
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
