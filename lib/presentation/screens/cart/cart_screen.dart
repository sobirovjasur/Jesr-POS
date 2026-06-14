import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../domain/entities/ordered_product_entity.dart';
import '../../providers/home/home_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_snack_bar.dart';
import 'components/checkout_dialog.dart';

/// Cart screen (Figma 07/08 — "Корзина").
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  void _confirmClearAll(WidgetRef ref) {
    AppDialog.show(
      title: L10n.trc('common_attention'),
      text: L10n.trc('cart_confirm_clear_all'),
      leftButtonText: L10n.trc('common_no'),
      rightButtonText: L10n.trc('common_yes'),
      onTapRightButton: (context) {
        ref.read(homeNotifierProvider.notifier).onRemoveAllOrderedProduct();
        context.pop();
      },
    );
  }

  Future<void> _onPostpone(BuildContext context, WidgetRef ref) async {
    final res = await AppDialog.showProgress(ref.read(homeNotifierProvider.notifier).postpone);

    if (res.isSuccess) {
      if (context.mounted) context.pop();
    } else {
      AppSnackBar.showError(res.error?.toString() ?? L10n.trc('common_error'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(homeNotifierProvider.select((s) => s.orderedProducts));
    final unselectedIds = ref.watch(homeNotifierProvider.select((s) => s.unselectedProductIds));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final selected = items.where((e) => !unselectedIds.contains(e.productId)).toList();
    final unselected = items.where((e) => unselectedIds.contains(e.productId)).toList();
    final selectedTotal = selected.fold<int>(0, (sum, e) => sum + e.price * e.quantity);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr('cart_title'), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: items.isEmpty
          ? AppEmptyState(title: context.tr('empty_cart_title'), subtitle: context.tr('empty_cart_subtitle'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: AppRadius.cardAll,
                            border: Border.all(color: colorScheme.surfaceContainerHighest, width: 1),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSizes.padding,
                                  AppSizes.padding / 1.5,
                                  AppSizes.padding / 2,
                                  AppSizes.padding / 1.5,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.tr('cart_title'), style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
                                      onPressed: () => _confirmClearAll(ref),
                                    ),
                                  ],
                                ),
                              ),
                              for (final e in selected) ...[
                                Divider(height: 1, color: colorScheme.surfaceContainerHighest),
                                _CartItemTile(item: e, selected: true),
                              ],
                              if (unselected.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSizes.padding,
                                    AppSizes.padding,
                                    AppSizes.padding,
                                    AppSizes.padding / 2,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      context.tr('cart_returns_section'),
                                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                for (final e in unselected) ...[
                                  Divider(height: 1, color: colorScheme.surfaceContainerHighest),
                                  _CartItemTile(item: e, selected: false),
                                ],
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.padding),
                        _SummaryRow(
                          label: '${context.tr('cart_items')} (${selected.length})',
                          value: CurrencyFormatter.withoutSymbol(selectedTotal),
                        ),
                        const SizedBox(height: AppSizes.padding / 2),
                        _SummaryRow(
                          label: context.tr('cart_total_amount'),
                          value: CurrencyFormatter.withoutSymbol(selectedTotal),
                          bold: true,
                        ),
                        const SizedBox(height: AppSizes.padding),
                        AppButton(
                          text: context.tr('cart_postpone'),
                          width: double.infinity,
                          height: 50,
                          buttonColor: colorScheme.surfaceContainerLow,
                          borderColor: colorScheme.surfaceContainerLow,
                          textColor: colorScheme.onSurface,
                          onTap: () => _onPostpone(context, ref),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  color: colorScheme.surfaceContainerLowest,
                  child: AppButton(
                    text: context.tr('cart_checkout'),
                    width: double.infinity,
                    height: 52,
                    fontSize: 18,
                    enabled: selected.isNotEmpty,
                    disabledButtonColor: colorScheme.surfaceContainerLow,
                    onTap: () => CheckoutDialog.show(),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: bold ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: (bold ? textTheme.titleMedium : textTheme.bodyLarge)?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final OrderedProductEntity item;
  final bool selected;

  const _CartItemTile({required this.item, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final notifier = ref.read(homeNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(AppSizes.padding / 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(
            image: item.imageUrl,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            borderRadius: AppRadius.smallAll,
            backgroundColor: AppColors.imageBackground,
            errorWidget: Icon(Icons.image, color: colorScheme.surfaceDim, size: 20),
          ),
          const SizedBox(width: AppSizes.padding / 1.5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.withoutSymbol(item.price * item.quantity),
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${CurrencyFormatter.format(item.price)}${context.tr('product_per_unit')}',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSizes.padding / 2),
                _QuantityStepper(
                  quantity: item.quantity,
                  onDecrement: () {
                    if (item.quantity > 1) {
                      notifier.onChangedOrderedProductQuantity(item.productId, item.quantity - 1);
                    } else {
                      notifier.onRemoveOrderedProduct(item);
                    }
                  },
                  onIncrement: () {
                    if (item.quantity < item.stock) {
                      notifier.onChangedOrderedProductQuantity(item.productId, item.quantity + 1);
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: selected,
              onChanged: (_) => notifier.toggleSelection(item.productId),
              activeColor: colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              side: BorderSide(color: colorScheme.surfaceContainerHighest, width: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityStepper({required this.quantity, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        _StepperButton(icon: Icons.remove_rounded, onTap: onDecrement),
        SizedBox(
          width: 44,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        _StepperButton(icon: Icons.add_rounded, onTap: onIncrement, color: colorScheme.primary),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _StepperButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: AppRadius.smallAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smallAll,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: color ?? colorScheme.onSurface),
        ),
      ),
    );
  }
}
