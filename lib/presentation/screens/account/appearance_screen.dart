import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/locale/locale_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_drop_down.dart';
import '../../widgets/app_snack_bar.dart';

/// Appearance / language settings (Figma 19.1 — "Тема оформления").
///
/// For now only the language selector is functional. The theme selector is
/// shown but disabled — the app is light-only.
class AppearanceScreen extends ConsumerStatefulWidget {
  const AppearanceScreen({super.key});

  @override
  ConsumerState<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends ConsumerState<AppearanceScreen> {
  static const _languages = [
    (locale: Locale('uz'), label: 'Ўзбекча'),
    (locale: Locale('ru'), label: 'Русский'),
    (locale: Locale('en'), label: 'English'),
  ];

  late Locale _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(localeNotifierProvider);
  }

  void _save() {
    ref.read(localeNotifierProvider.notifier).setLocale(_selected);
    AppSnackBar.show(L10n.trc('appearance_saved'), message: L10n.trc('appearance_settings_updated'));
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr('appearance_title'), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.padding),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: AppRadius.cardAll,
                  border: Border.all(width: 1, color: colorScheme.surfaceContainerHighest),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppDropDown<Locale>(
                      labelText: context.tr('appearance_language_label'),
                      selectedValue: _selected,
                      dropdownItems: _languages
                          .map((l) => DropdownMenuItem<Locale>(value: l.locale, child: Text(l.label)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selected = value);
                      },
                    ),
                    const SizedBox(height: AppSizes.padding),
                    AppDropDown<String>(
                      labelText: context.tr('appearance_theme_label'),
                      selectedValue: 'system',
                      enabled: false,
                      dropdownItems: [
                        DropdownMenuItem<String>(value: 'system', child: Text(context.tr('appearance_theme_system'))),
                      ],
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: AppButton(
                text: context.tr('common_save'),
                width: double.infinity,
                height: 52,
                fontSize: 18,
                buttonColor: AppColors.primary,
                onTap: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
