import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/l10n.dart';
import '../../../../core/themes/app_radius.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../widgets/app_button.dart';
import 'components/country_code.dart';
import 'components/country_code_picker.dart';

/// Registration step 02 — phone number entry (Figma: "Ваш номер телефона").
class PhoneNumberScreen extends ConsumerStatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  ConsumerState<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  CountryCode _country = kCountryCodes.first;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isValid => _controller.text.trim().length == _country.phoneLength;

  Future<void> _pickCountry() async {
    final picked = await CountryCodePicker.show(context, _country);
    if (picked != null) setState(() => _country = picked);
  }

  void _onConfirm() {
    if (!_isValid) return;

    context.push('/register-details', extra: '${_country.dialCode}${_controller.text.trim()}');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.padding / 2),
              Text(
                context.tr('auth_phone_number_title'),
                style: textTheme.displayLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
              ),
              const SizedBox(height: AppSizes.padding / 2),
              Text(
                context.tr('auth_confirmation_code_telegram'),
                style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: colorScheme.outlineVariant, height: 1.3),
              ),
              const SizedBox(height: AppSizes.padding * 1.75),
              Text(
                context.tr('auth_phone_number_label'),
                style: textTheme.bodySmall?.copyWith(fontSize: 14, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSizes.padding / 2),
              _PhoneInput(
                controller: _controller,
                focusNode: _focusNode,
                country: _country,
                onChanged: (_) => setState(() {}),
                onCountryTap: _pickCountry,
              ),
              const Spacer(),
              AppButton(
                text: context.tr('auth_confirm_button'),
                width: double.infinity,
                height: 52,
                fontSize: 18,
                enabled: _isValid,
                disabledButtonColor: colorScheme.surfaceContainerLow,
                onTap: _onConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final CountryCode country;
  final ValueChanged<String> onChanged;
  final VoidCallback onCountryTap;

  const _PhoneInput({
    required this.controller,
    required this.focusNode,
    required this.country,
    required this.onChanged,
    required this.onCountryTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFocused = focusNode.hasFocus;

    final valueStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
    );

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(
          color: isFocused ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onCountryTap,
            borderRadius: AppRadius.smallAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(country.flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 4),
                  Text(country.dialCode, style: valueStyle),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: colorScheme.surfaceContainerHighest,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              autofocus: true,
              keyboardType: TextInputType.phone,
              cursorColor: colorScheme.primary,
              cursorWidth: 1.5,
              maxLength: country.phoneLength,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: valueStyle,
              decoration: const InputDecoration(
                counterText: '',
                isCollapsed: true,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
