import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../providers/auth/auth_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../components/auth_password_field.dart';
import '../components/auth_phone_field.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _errorNotifier = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  bool get _isValid => _phoneController.text.trim().length == 9 && _passwordController.text.isNotEmpty;

  Future<void> _onSubmit() async {
    if (!_isValid) return;

    _errorNotifier.value = null;
    final authNotifier = ref.read(authNotifierProvider.notifier);

    final res = await AppDialog.showProgress(() async {
      return authNotifier.signIn(
        phone: AuthPhoneField.fullNumber(_phoneController.text.trim()),
        password: _passwordController.text,
      );
    });

    if (res.isSuccess) {
      ref.read(appRoutesProvider).router.refresh();
    } else {
      _errorNotifier.value = res.error?.toString() ?? 'Sign in failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.padding),
              Text(
                'Authorization',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.padding * 1.5),
              AuthPhoneField(
                controller: _phoneController,
                labelText: 'Login',
              ),
              const SizedBox(height: AppSizes.padding),
              AuthPasswordField(
                controller: _passwordController,
                labelText: 'Password',
                textInputAction: TextInputAction.done,
                onEditingComplete: _onSubmit,
              ),
              const Spacer(),
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
                listenable: Listenable.merge([_phoneController, _passwordController]),
                builder: (context, _) {
                  return AppButton(
                    text: 'Sign in',
                    width: double.infinity,
                    height: 48,
                    enabled: _isValid,
                    onTap: _onSubmit,
                  );
                },
              ),
              const SizedBox(height: AppSizes.padding / 2),
              const _RegisterLink(),
            ],
          ),
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
          "Don't have an account?",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => context.push('/register'),
          child: Text(
            'Register',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
