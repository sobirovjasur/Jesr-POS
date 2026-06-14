import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_radius.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../../domain/entities/product_entity.dart';

/// Catalog card for the Товары grid. Matches the Home/POS card style (image,
/// name, a grey subtitle line with a stock dot, bold price) but taps through to
/// the product detail instead of adding to the cart.
class ProductsCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final bool enabled;

  const ProductsCard({super.key, required this.product, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isOutOfStock = product.stock <= 0;
    final dotColor = product.stock <= 5 ? AppColors.warning : AppColors.success;

    return RepaintBoundary(
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashColor: Colors.black.withValues(alpha: 0.06),
        borderRadius: AppRadius.cardAll,
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.cardAll,
            border: Border.all(width: 1, color: colorScheme.surfaceContainerHighest),
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
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Остаток: ${product.stock}',
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(product.price),
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutOfStockOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.72), borderRadius: AppRadius.cardAll),
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
