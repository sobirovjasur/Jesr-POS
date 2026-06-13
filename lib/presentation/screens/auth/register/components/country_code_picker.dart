import 'package:flutter/material.dart';

import '../../../../../core/themes/app_radius.dart';
import '../../../../../core/themes/app_sizes.dart';
import 'country_code.dart';

/// Bottom sheet that lets the user pick a phone [CountryCode].
class CountryCodePicker {
  CountryCodePicker._();

  static Future<CountryCode?> show(BuildContext context, CountryCode selected) {
    return showModalBottomSheet<CountryCode>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheetLarge)),
      ),
      builder: (context) => _CountryCodeSheet(selected: selected),
    );
  }
}

class _CountryCodeSheet extends StatelessWidget {
  final CountryCode selected;

  const _CountryCodeSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.padding / 1.5),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.pillAll,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.padding, 0, AppSizes.padding, AppSizes.padding / 2),
            child: Row(
              children: [
                Text(
                  'Select country',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: kCountryCodes.length,
              itemBuilder: (context, index) {
                final country = kCountryCodes[index];
                final isSelected = country.name == selected.name && country.dialCode == selected.dialCode;

                return ListTile(
                  onTap: () => Navigator.of(context).pop(country),
                  leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(country.name, style: textTheme.bodyLarge),
                  trailing: Text(
                    country.dialCode,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.padding / 2),
        ],
      ),
    );
  }
}
