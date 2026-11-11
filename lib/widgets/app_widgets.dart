import 'package:clientsf/theme.dart';
import 'package:flutter/material.dart';

/// Flat card with a hairline border. The base surface for every screen.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double radius;
  final bool bordered;
  final List<BoxShadow>? shadow;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.color,
    this.radius = AppRadius.lg,
    this.bordered = true,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = color ?? theme.colorScheme.surface;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: bordered
          ? BorderSide(color: theme.dividerColor)
          : BorderSide.none,
    );

    Widget content = Padding(padding: padding, child: child);
    if (onTap != null || onLongPress != null) {
      content = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: shape,
        child: content,
      );
    }

    final card = Material(
      color: bg,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    final decorated = shadow == null
        ? card
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: shadow,
            ),
            child: card,
          );

    return margin == null
        ? decorated
        : Padding(padding: margin!, child: decorated);
  }
}

/// Round avatar with initials. Each name gets a stable colour from a small
/// palette so lists are easy to scan.
class InitialAvatar extends StatelessWidget {
  final String? name;
  final double size;
  final Color? color;

  const InitialAvatar(
      {super.key, required this.name, this.size = 44, this.color});

  static const List<Color> _palette = [
    Color(0xFF4F46E5), // indigo
    Color(0xFF0891B2), // cyan
    Color(0xFF16A34A), // green
    Color(0xFFD97706), // amber
    Color(0xFFDB2777), // pink
    Color(0xFF7C3AED), // violet
    Color(0xFF0D9488), // teal
    Color(0xFFEA580C), // orange
  ];

  static Color colorFor(String? name) {
    final key = (name ?? '').trim();
    if (key.isEmpty) return _palette.first;
    final hash = key.codeUnits.fold<int>(0, (a, c) => (a * 31 + c) & 0x7fffffff);
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = color ?? colorFor(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withOpacity(isDark ? 0.24 : 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: TextStyle(
          color: isDark ? Color.lerp(tint, Colors.white, 0.35) : tint,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
        ),
      ),
    );
  }

  static String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }
}

/// Small pill displaying a status (paid / pending / etc).
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final Color? background;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.background,
  });

  factory StatusPill.success(String label, {IconData? icon}) =>
      StatusPill(label: label, color: AppColors.success, icon: icon);
  factory StatusPill.warning(String label, {IconData? icon}) =>
      StatusPill(label: label, color: AppColors.warning, icon: icon);
  factory StatusPill.danger(String label, {IconData? icon}) =>
      StatusPill(label: label, color: AppColors.danger, icon: icon);
  factory StatusPill.info(String label, {IconData? icon}) =>
      StatusPill(label: label, color: AppColors.primary, icon: icon);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Color.lerp(color, Colors.white, 0.3)! : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
                color: fg, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Large page title used at the top of the main tabs: a small overline,
/// a big bold title and optional trailing actions.
class PageHeader extends StatelessWidget {
  final String title;
  final String? overline;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  const PageHeader({
    super.key,
    required this.title,
    this.overline,
    this.actions = const [],
    this.padding = const EdgeInsets.fromLTRB(20, 12, 12, 16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (overline != null)
                  Text(
                    overline!,
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                Text(title, style: theme.textTheme.headlineLarge),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Compact KPI tile: tinted icon, a big number and a label.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? footnote;
  final Color? footnoteColor;
  final VoidCallback? onTap;

  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.footnote,
    this.footnoteColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SoftCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(icon,
                size: 18,
                color: isDark ? Color.lerp(color, Colors.white, 0.3) : color),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium,
          ),
          if (footnote != null) ...[
            const SizedBox(height: 2),
            Text(
              footnote!,
              maxLines: 1,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: footnoteColor, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tonal summary card for a key amount (balance, call total…). Replaces the
/// old heavy gradient heroes with a flat tinted surface.
class AmountCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;
  final String? caption;
  final Widget? badge;
  final Widget? trailing;

  const AmountCard({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.caption,
    this.badge,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strong = isDark ? Color.lerp(color, Colors.white, 0.35)! : color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withOpacity(isDark ? 0.30 : 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: strong),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(label,
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: strong)),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      badge!,
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  amount,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontSize: 34,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (caption != null && caption!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(caption!,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Small grey heading above a group of cards.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Empty-state widget shown when a list has no items.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              alignment: Alignment.center,
              child: Icon(icon,
                  size: 34, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? background;
  final double size;
  final String? tooltip;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.background,
    this.size = 40,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? Theme.of(context).colorScheme.onSurface;
    final bg =
        background ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    final btn = Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: fg, size: size * 0.48),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 4,
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2.6),
        ),
      ),
    );
  }
}
