import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_button.dart';

/// Placeholder for not-yet-built features (Figma 24 — "Скоро будет доступно").
///
/// Greyed-out / future menu items route here instead of a dead tap.
class SoonScreen extends StatelessWidget {
  const SoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.padding * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_outlined, size: 64, color: colorScheme.outlineVariant),
                const SizedBox(height: AppSizes.padding * 1.5),
                Text(
                  context.tr('soon_title'),
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.padding / 2),
                Text(
                  context.tr('soon_message'),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSizes.padding * 1.5),
                AppButton(
                  text: context.tr('common_back'),
                  width: 200,
                  height: 50,
                  fontSize: 16,
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
