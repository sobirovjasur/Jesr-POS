import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../providers/auth/auth_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../register/components/country_code.dart';
import '../register/components/country_code_picker.dart';
import '../register/components/onboarding_text_field.dart';
import '../register/components/phone_input_field.dart';

/// Login screen (Figma 06 — "Авторизация"): phone + password.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _errorNotifier = ValueNotifier<String?>(null);
  CountryCode _country = kCountryCodes.first;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _phoneController.text.trim().length == _country.phoneLength && _passwordController.text.isNotEmpty;

  Future<void> _pickCountry() async {
    final picked = await CountryCodePicker.show(context, _country);
    if (picked != null) setState(() => _country = picked);
  }

  Future<void> _onSubmit() async {
    if (!_isValid) return;

    _errorNotifier.value = null;
    final authNotifier = ref.read(authNotifierProvider.notifier);

    final res = await AppDialog.showProgress(() async {
      return authNotifier.signIn(
        phone: '${_country.dialCode}${_phoneController.text.trim()}',
        password: _passwordController.text,
      );
    });

    if (res.isSuccess) {
      ref.read(appRoutesProvider).router.refresh();
    } else {
      _errorNotifier.value = res.error?.toString() ?? 'Неверный логин или пароль, попробуйте ещё раз.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final labelStyle = textTheme.bodySmall?.copyWith(fontSize: 14, color: colorScheme.onSurfaceVariant);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSizes.padding, AppSizes.padding, AppSizes.padding, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.padding / 2),
                    Text(
                      'Авторизация',
                      style: textTheme.displayLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
                    ),
                    const SizedBox(height: AppSizes.padding * 1.5),
                    Text('Логин', style: labelStyle),
                    const SizedBox(height: AppSizes.padding / 2),
                    PhoneInputField(
                      controller: _phoneController,
                      country: _country,
                      onChanged: (_) => setState(() {}),
                      onCountryTap: _pickCountry,
                    ),
                    const SizedBox(height: AppSizes.padding),
                    OnboardingTextField(
                      controller: _passwordController,
                      label: 'Пароль',
                      hint: 'Введите',
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
                    listenable: Listenable.merge([_phoneController, _passwordController]),
                    builder: (context, _) {
                      return AppButton(
                        text: 'Войти',
                        width: double.infinity,
                        height: 52,
                        fontSize: 18,
                        enabled: _isValid,
                        disabledButtonColor: colorScheme.surfaceContainerLow,
                        onTap: _onSubmit,
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.padding / 2),
                  _RegisterLink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Нет аккаунта?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => context.push('/register'),
          child: Text(
            'Регистрация',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
