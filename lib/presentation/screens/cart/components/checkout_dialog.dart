import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/locale/l10n.dart';
import '../../../../core/themes/app_radius.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../providers/home/home_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_text_field.dart';

/// Payment dialog shown from the cart's "Оплата" button. Collects the received
/// amount, payment method and optional customer details, then creates the
/// transaction and navigates to its detail screen.
class CheckoutDialog {
  CheckoutDialog._();

  static void show() {
    AppDialog.show(
      title: L10n.trc('cart_checkout'),
      child: const _CheckoutDialogBody(),
      showButtons: false,
    );
  }
}

class _CheckoutDialogBody extends ConsumerStatefulWidget {
  const _CheckoutDialogBody();

  @override
  ConsumerState<_CheckoutDialogBody> createState() => _CheckoutDialogBodyState();
}

class _CheckoutDialogBodyState extends ConsumerState<_CheckoutDialogBody> {
  final _amountController = TextEditingController();
  final _customerController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear any received amount left over from a previously cancelled checkout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).onChangedReceivedAmount(0);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _customerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onPay() async {
    final homeNotifier = ref.read(homeNotifierProvider.notifier);
    final router = ref.read(appRoutesProvider).router;

    context.pop();

    final res = await AppDialog.showProgress(homeNotifier.pay);

    if (res.isSuccess) {
      router.go('/transactions/transaction-detail/${res.data}');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeNotifier = ref.read(homeNotifierProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          controller: _amountController,
          labelText: context.tr('checkout_received_amount_label'),
          hintText: context.tr('checkout_amount_hint'),
          onChanged: (v) {
            homeNotifier.onChangedReceivedAmount(int.tryParse(v) ?? 0);
            // Rebuild so the "Оплатить" button re-evaluates its enabled state.
            setState(() {});
          },
        ),
        const SizedBox(height: AppSizes.padding),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.tr('checkout_payment_method'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.padding / 2),
        Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.cardAll,
          ),
          child: Text(
            context.tr('checkout_cash'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: AppSizes.padding),
        AppTextField(
          controller: _customerController,
          labelText: context.tr('checkout_customer_name_label'),
          hintText: context.tr('checkout_customer_hint'),
          onChanged: homeNotifier.onChangedCustomerName,
        ),
        const SizedBox(height: AppSizes.padding),
        AppTextField(
          controller: _descriptionController,
          labelText: context.tr('checkout_description_label'),
          hintText: context.tr('checkout_description_hint'),
          onChanged: homeNotifier.onChangedDescription,
        ),
        const SizedBox(height: AppSizes.padding * 1.5),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: context.tr('common_cancel'),
                buttonColor: Theme.of(context).colorScheme.surface,
                borderColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.primary,
                onTap: () => context.pop(),
              ),
            ),
            const SizedBox(width: AppSizes.padding / 2),
            Expanded(
              flex: 2,
              child: AppButton(
                text: context.tr('checkout_pay_button'),
                enabled: (int.tryParse(_amountController.text) ?? 0) >= homeNotifier.getSelectedTotal(),
                onTap: _onPay,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
