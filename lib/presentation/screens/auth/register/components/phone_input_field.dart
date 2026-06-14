import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/themes/app_radius.dart';
import 'country_code.dart';

/// Phone input with a country-code selector, following the onboarding field
/// style: white + purple border when focused/empty, grey fill when filled.
class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final CountryCode country;
  final ValueChanged<String> onChanged;
  final VoidCallback onCountryTap;
  final bool autofocus;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.country,
    required this.onChanged,
    required this.onCountryTap,
    this.autofocus = false,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasText = widget.controller.text.isNotEmpty;
    final isFocused = _focusNode.hasFocus;

    final Color fillColor;
    final Color borderColor;
    final double borderWidth;

    if (hasText) {
      fillColor = colorScheme.surfaceContainerLow;
      borderColor = Colors.transparent;
      borderWidth = 1;
    } else if (isFocused) {
      fillColor = colorScheme.surface;
      borderColor = colorScheme.primary;
      borderWidth = 1.5;
    } else {
      fillColor = colorScheme.surface;
      borderColor = colorScheme.surfaceContainerHighest;
      borderWidth = 1;
    }

    final valueStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
    );

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: widget.onCountryTap,
            borderRadius: AppRadius.smallAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.country.flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 4),
                  Text(widget.country.dialCode, style: valueStyle),
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
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.phone,
              cursorColor: colorScheme.primary,
              cursorWidth: 1.5,
              maxLength: widget.country.phoneLength,
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
