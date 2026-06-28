import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../viewmodels/theme_viewmodel.dart';

/// Settings row that lets the user pick Light / Dark / System theme.
///
/// Drop into SettingsScreen:
/// ```dart
/// const ThemeModeSelector()
/// ```
class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeViewModelProvider);
    final vm      = ref.read(themeViewModelProvider.notifier);
    final theme   = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.06),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.dark_mode_rounded,
                size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              'Appearance',
              style: TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w700,
                color:      theme.colorScheme.primary,
                letterSpacing: 0.3,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          ...AppThemeMode.values.map((mode) => _ThemeOption(
                mode:     mode,
                selected: current == mode,
                onTap:    () => vm.setThemeMode(mode),
              )),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });
  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (mode) {
      AppThemeMode.light  => Icons.light_mode_rounded,
      AppThemeMode.dark   => Icons.dark_mode_rounded,
      AppThemeMode.system => Icons.brightness_auto_rounded,
    };
    final subtitle = switch (mode) {
      AppThemeMode.light  => 'Always use light colors',
      AppThemeMode.dark   => 'Always use dark colors',
      AppThemeMode.system => 'Match device setting',
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.08),
            width: selected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    style: TextStyle(
                      fontSize:   14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  size: 20, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}