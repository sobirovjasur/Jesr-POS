import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../providers/auth/auth_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_text_field.dart';
import '../components/auth_password_field.dart';
import '../components/auth_phone_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  /// Full phone number (`+998...`) carried from the phone-entry step. When
  /// provided, the phone field is hidden and this value is used for sign-up.
  final String? phone;

  const RegisterScreen({super.key, this.phone});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _errorNotifier = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  bool get _hasPhone => widget.phone != null || _phoneController.text.trim().length == 9;

  String get _fullPhone => widget.phone ?? AuthPhoneField.fullNumber(_phoneController.text.trim());

  bool get _isFilled =>
      _nameController.text.trim().isNotEmpty &&
      _hasPhone &&
      _passwordController.text.isNotEmpty &&
      _confirmController.text.isNotEmpty;

  String? _validate() {
    if (_nameController.text.trim().isEmpty) return 'Please enter your name.';
    if (!_hasPhone) return 'Please enter a valid phone number.';
    if (_passwordController.text.length < 6) return 'Password must be at least 6 characters.';
    if (_passwordController.text != _confirmController.text) return 'Passwords do not match.';

    return null;
  }

  Future<void> _onSubmit() async {
    final validationError = _validate();
    if (validationError != null) {
      _errorNotifier.value = validationError;
      return;
    }

    _errorNotifier.value = null;
    final authNotifier = ref.read(authNotifierProvider.notifier);

    final res = await AppDialog.showProgress(() async {
      return authNotifier.signUp(
        phone: _fullPhone,
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
    });

    if (res.isSuccess) {
      ref.read(appRoutesProvider).router.refresh();
    } else {
      _errorNotifier.value = res.error?.toString() ?? 'Registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _nameController,
                labelText: 'Full name',
                hintText: 'Enter your name',
                textInputAction: TextInputAction.next,
              ),
              if (widget.phone == null) ...[
                const SizedBox(height: AppSizes.padding),
                AuthPhoneField(
                  controller: _phoneController,
                  labelText: 'Phone number',
                ),
              ],
              const SizedBox(height: AppSizes.padding),
              AuthPasswordField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'At least 6 characters',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSizes.padding),
              AuthPasswordField(
                controller: _confirmController,
                labelText: 'Confirm password',
                hintText: 'Re-enter password',
                textInputAction: TextInputAction.done,
                onEditingComplete: _onSubmit,
              ),
              const SizedBox(height: AppSizes.padding * 1.5),
              ValueListenableBuilder<String?>(
                valueListenable: _errorNotifier,
                builder: (context, error, _) {
                  if (error == null) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                },
              ),
              ListenableBuilder(
                listenable: Listenable.merge([
                  _nameController,
                  _phoneController,
                  _passwordController,
                  _confirmController,
                ]),
                builder: (context, _) {
                  return AppButton(
                    text: 'Register',
                    width: double.infinity,
                    height: 48,
                    enabled: _isFilled,
                    onTap: _onSubmit,
                  );
                },
              ),
              const SizedBox(height: AppSizes.padding / 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Sign in',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
