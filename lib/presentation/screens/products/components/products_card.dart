import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_radius.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../../domain/entities/product_entity.dart';

class ProductsCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final bool enabled;

  const ProductsCard({
    super.key,
    required this.product,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashColor: Colors.black.withValues(alpha: 0.06),
        splashFactory: InkRipple.splashFactory,
        highlightColor: Colors.black12,
        borderRadius: AppRadius.cardAll,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadius.cardAll,
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 146, maxHeight: 226),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: AppImage(
                        image: product.imageUrl,
                        borderRadius: AppRadius.cardAll,
                        border: Border.all(width: 0.5, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                        errorWidget: Icon(
                          Icons.image,
                          color: Theme.of(context).colorScheme.surfaceDim,
                          size: 32,
                        ),
                      ),
                    ),
                    product.stock <= 0 ? _OutOfStock() : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 8,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stock ${product.stock}  |  Sold ${product.sold}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(product.price),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutOfStock extends StatelessWidget {
  const _OutOfStock();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: AppRadius.smallAll,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.padding / 4,
            horizontal: AppSizes.padding / 2,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: AppRadius.smallAll,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove_circle,
                color: Theme.of(context).colorScheme.outline,
                size: 10,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Out of stock',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
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
