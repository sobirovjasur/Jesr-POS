import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../core/utilities/date_time_formatter.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/products/product_detail_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';

/// Product detail (Figma 15 — "Детали товара").
class ProductDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const ProductDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late final Future<ProductEntity?> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(productDetailNotifierProvider.notifier).getProductDetail(widget.id);
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/products');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Детали товара', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _onBack,
        ),
      ),
      body: FutureBuilder<ProductEntity?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppProgressIndicator();
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const AppEmptyState(title: 'Товар не найден');
          }

          final product = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: _DetailBody(product: product),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: AppButton(
                    text: 'Изменить товар',
                    width: double.infinity,
                    height: 52,
                    fontSize: 18,
                    onTap: () => context.push('/products/product-edit/${product.id}'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final ProductEntity product;

  const _DetailBody({required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image on a neutral card.
        AppImage(
          image: product.imageUrl,
          width: double.infinity,
          height: 280,
          fit: BoxFit.contain,
          borderRadius: AppRadius.cardAll,
          backgroundColor: AppColors.imageBackground,
          errorWidget: Icon(Icons.image, color: colorScheme.surfaceDim, size: 40),
        ),
        const SizedBox(height: AppSizes.padding),
        Text(
          product.name,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSizes.padding / 3),
        Text(
          CurrencyFormatter.format(product.price),
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
        ),
        const SizedBox(height: AppSizes.padding * 1.5),
        Text('Информация о товаре', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSizes.padding),
        Row(
          children: [
            _InfoChip(label: 'Остаток', value: '${product.stock}'),
            const SizedBox(width: AppSizes.padding / 2),
            _InfoChip(label: 'Продано', value: '${product.sold ?? 0}'),
          ],
        ),
        const SizedBox(height: AppSizes.padding / 2),
        _InfoChip(label: 'Добавлено', value: DateTimeFormatter.dotDateWithSlashClock(product.createdAt ?? '')),
        const SizedBox(height: AppSizes.padding / 2),
        _InfoChip(
          label: 'Последнее обновление',
          value: DateTimeFormatter.dotDateWithSlashClock(product.updatedAt ?? ''),
        ),
        const SizedBox(height: AppSizes.padding * 1.5),
        _DescriptionTabs(product: product),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: RichText(
        text: TextSpan(
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionTabs extends StatefulWidget {
  final ProductEntity product;

  const _DescriptionTabs({required this.product});

  @override
  State<_DescriptionTabs> createState() => _DescriptionTabsState();
}

class _DescriptionTabsState extends State<_DescriptionTabs> {
  int _tab = 0; // 0 = Описание, 1 = Характеристики
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isDescription = _tab == 0;
    final content = isDescription ? widget.product.description : widget.product.specifications;
    final text = content?.isNotEmpty == true
        ? content!
        : (isDescription ? 'Нет описания' : 'Нет характеристик');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: AppRadius.cardAll,
          ),
          child: Row(
            children: [
              _TabButton(label: 'Описание', selected: isDescription, onTap: () => setState(() => _tab = 0)),
              _TabButton(label: 'Характеристики', selected: !isDescription, onTap: () => setState(() => _tab = 1)),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.padding),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topCenter,
          child: Text(
            text,
            maxLines: _expanded ? null : 4,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.4),
          ),
        ),
        if (text.length > 140)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.padding / 2),
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Скрыть' : 'Показать ещё',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
            ),
          ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.small + 4),
          ),
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: selected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
