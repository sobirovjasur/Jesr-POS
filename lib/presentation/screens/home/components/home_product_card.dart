import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_radius.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../../domain/entities/product_entity.dart';
import '../../../providers/home/home_notifier.dart';

/// Product card on the Home/POS grid. Tapping adds one unit to the cart; once
/// selected, the card shows the ordered quantity, a per-unit line and a stock
/// indicator dot (green = sufficient, yellow = low / ≤ 5 left).
class HomeProductCard extends ConsumerWidget {
  final ProductEntity product;

  const HomeProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final quantity = ref.watch(
      homeNotifierProvider.select(
        (s) => s.orderedProducts.where((e) => e.productId == product.id).firstOrNull?.quantity ?? 0,
      ),
    );

    final isSelected = quantity > 0;
    final displayQty = isSelected ? quantity : 1;
    final isOutOfStock = product.stock <= 0;
    final dotColor = product.stock <= 5 ? AppColors.warning : AppColors.success;

    return RepaintBoundary(
      child: InkWell(
        onTap: isOutOfStock ? null : () => _addOne(ref, quantity),
        splashColor: Colors.black.withValues(alpha: 0.06),
        borderRadius: AppRadius.cardAll,
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.cardAll,
            border: Border.all(
              width: isSelected ? 1.5 : 1,
              color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      image: product.imageUrl,
                      fit: BoxFit.contain,
                      borderRadius: AppRadius.cardAll,
                      backgroundColor: AppColors.imageBackground,
                      errorWidget: Icon(Icons.image, color: colorScheme.surfaceDim, size: 32),
                    ),
                    if (isOutOfStock) _OutOfStockOverlay(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (isSelected) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      '$displayQty x ${CurrencyFormatter.format(product.price)}/шт',
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.withoutSymbol(product.price * displayQty),
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addOne(WidgetRef ref, int currentQty) {
    final next = currentQty + 1 <= product.stock ? currentQty + 1 : product.stock;
    ref.read(homeNotifierProvider.notifier).onAddOrderedProduct(product, next == 0 ? 1 : next);
  }
}

class _OutOfStockOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: AppRadius.cardAll,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.padding / 4, horizontal: AppSizes.padding / 2),
          decoration: BoxDecoration(color: colorScheme.surface, borderRadius: AppRadius.smallAll),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.remove_circle, color: colorScheme.outline, size: 12),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Нет в наличии',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
