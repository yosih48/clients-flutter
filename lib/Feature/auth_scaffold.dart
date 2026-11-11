import 'package:clientsf/theme.dart';
import 'package:flutter/material.dart';

/// Shared layout for all auth screens: warm cream background with a gradient
/// brand badge at the top, then a soft-card form. Subtle decorative blobs
/// give the otherwise-minimal page some atmosphere.
class AuthScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> children;

  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brand badge
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadows.lifted,
                          ),
                          child: Icon(icon,
                              color: theme.colorScheme.onPrimary, size: 30),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(letterSpacing: -0.4),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                              color: Theme.of(context).dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
