import 'package:flutter/material.dart';

import '../../../../core/themes/app_sizes.dart';
import '../../../widgets/app_text_field.dart';

/// Password input with a show/hide (eye) toggle, matching the auth design.
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText ?? 'Enter password',
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      suffixWidget: Padding(
        padding: const EdgeInsets.only(right: AppSizes.padding / 2),
        child: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          splashRadius: 20,
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
