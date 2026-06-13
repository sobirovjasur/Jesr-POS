import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../widgets/app_text_field.dart';

/// Phone-number input with a fixed country-code prefix (e.g. `+998`).
///
/// Accepts digits only; the [controller] holds the local number digits while
/// the prefix is rendered visually. Use [fullNumber] to read the complete
/// `+998XXXXXXXXX` value for authentication.
class AuthPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;

  const AuthPhoneField({
    super.key,
    required this.controller,
    this.labelText,
  });

  /// The complete phone number including the country code.
  static String fullNumber(String localDigits) => '${Constants.phoneCountryCode}$localDigits';

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: labelText,
      hintText: '10 000 00 00',
      keyboardType: TextInputType.phone,
      maxLength: 9,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      prefixWidget: Padding(
        padding: const EdgeInsets.only(left: AppSizes.padding, right: AppSizes.padding / 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🇺🇿',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: AppSizes.padding / 3),
            Text(
              Constants.phoneCountryCode,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
