import 'package:flutter/material.dart';

import '../../../../../core/themes/app_radius.dart';
import '../../../../../core/themes/app_sizes.dart';

/// Onboarding input styled per the new design:
/// - empty + focused → white fill with a purple border
/// - empty + idle → white fill with a subtle grey border
/// - filled → grey fill, no border
class OnboardingTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<OnboardingTextField> createState() => _OnboardingTextFieldState();
}

class _OnboardingTextFieldState extends State<OnboardingTextField> {
  final _focusNode = FocusNode();
  late bool _obscure = widget.isPassword;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: textTheme.bodySmall?.copyWith(fontSize: 14, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.padding / 2),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: AppRadius.cardAll,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: _obscure,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                  cursorColor: colorScheme.primary,
                  cursorWidth: 1.5,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.outlineVariant),
                  ),
                ),
              ),
              if (widget.isPassword)
                GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSizes.padding / 2),
                    child: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
