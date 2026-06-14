import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../providers/auth/auth_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../components/auth_phone_field.dart';
import 'components/onboarding_text_field.dart';

/// Registration step 04 — user details (Figma: "Введите свои данные").
///
/// Keeps the inputs required for phone+password auth (name, password, confirm)
/// while adopting the new onboarding input style. The phone number is carried
/// from the previous step via [phone].
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
    if (_nameController.text.trim().isEmpty) return 'Введите имя';
    if (!_hasPhone) return 'Введите номер телефона';
    if (_passwordController.text.length < 6) return 'Пароль должен содержать не менее 6 символов';
    if (_passwordController.text != _confirmController.text) return 'Пароли не совпадают';

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
      _errorNotifier.value = res.error?.toString() ?? 'Не удалось зарегистрироваться. Попробуйте ещё раз.';
    }
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSizes.padding, AppSizes.padding / 2, AppSizes.padding, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Введите свои данные',
                      style: textTheme.displayLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
                    ),
                    const SizedBox(height: AppSizes.padding * 1.5),
                    OnboardingTextField(
                      controller: _nameController,
                      label: 'Имя',
                      hint: 'Введите',
                      textInputAction: TextInputAction.next,
                    ),
                    if (widget.phone == null) ...[
                      const SizedBox(height: AppSizes.padding),
                      AuthPhoneField(controller: _phoneController, labelText: 'Номер телефона'),
                    ],
                    const SizedBox(height: AppSizes.padding),
                    OnboardingTextField(
                      controller: _passwordController,
                      label: 'Пароль',
                      hint: 'Введите пароль',
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.padding),
                    OnboardingTextField(
                      controller: _confirmController,
                      label: 'Подтвердите пароль',
                      hint: 'Повторите пароль',
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: _onSubmit,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<String?>(
                    valueListenable: _errorNotifier,
                    builder: (context, error, _) {
                      if (error == null) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
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
                        text: 'Подтвердить',
                        width: double.infinity,
                        height: 52,
                        fontSize: 18,
                        enabled: _isFilled,
                        disabledButtonColor: colorScheme.surfaceContainerLow,
                        onTap: _onSubmit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
