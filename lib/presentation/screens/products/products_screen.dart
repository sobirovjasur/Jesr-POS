import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/products/products_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_more_indicator.dart';
import '../../widgets/app_progress_indicator.dart';
import 'components/products_card.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final scrollController = ScrollController();
  final searchFieldController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsNotifierProvider.notifier).getAllProducts();
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    searchFieldController.dispose();
    super.dispose();
  }

  void scrollListener() async {
    if (_query.isNotEmpty) return;

    final productsState = ref.read(productsNotifierProvider);

    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      await ref.read(productsNotifierProvider.notifier).getAllProducts(offset: productsState.allProducts?.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(productsNotifierProvider.select((s) => s.allProducts));
    final isLoadingMore = ref.watch(productsNotifierProvider.select((s) => s.isLoadingMore));

    final results = _query.isEmpty
        ? const <ProductEntity>[]
        : (allProducts ?? []).where((p) => p.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Товары'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: const [_AddButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.padding,
              AppSizes.padding / 4,
              AppSizes.padding,
              AppSizes.padding / 2,
            ),
            child: _SearchBar(
              controller: searchFieldController,
              onChanged: (v) => setState(() => _query = v.trim()),
              onClear: () => setState(() => _query = ''),
            ),
          ),
          Expanded(
            child: _query.isNotEmpty
                ? _SearchResults(results: results)
                : _ProductGrid(
                    scrollController: scrollController,
                    products: allProducts,
                    isLoadingMore: isLoadingMore,
                    onRefresh: () => ref.read(productsNotifierProvider.notifier).getAllProducts(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({required this.controller, required this.onChanged, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLow, borderRadius: AppRadius.cardAll),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: colorScheme.primary, size: 22),
          const SizedBox(width: AppSizes.padding / 2),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: colorScheme.primary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Поиск товаров',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.outlineVariant),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () {
                  controller.clear();
                  onClear();
                },
                child: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant, size: 20),
              );
            },
          ),
          const SizedBox(width: AppSizes.padding / 2),
          Icon(Icons.qr_code_scanner_rounded, color: colorScheme.onSurfaceVariant, size: 22),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<ProductEntity> results;

  const _SearchResults({required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: colorScheme.outlineVariant),
            const SizedBox(height: AppSizes.padding),
            Text(
              'Ничего не найдено',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding, vertical: AppSizes.padding / 2),
      itemCount: results.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: Theme.of(context).colorScheme.surfaceContainerHighest),
      itemBuilder: (context, i) => _SearchResultTile(product: results[i]),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final ProductEntity product;

  const _SearchResultTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.push('/products/product-detail/${product.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.padding / 1.5),
        child: Row(
          children: [
            AppImage(
              image: product.imageUrl,
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
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.withoutSymbol(product.price),
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '  ·  Ост: ${product.stock}',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Text(
                    '${product.id}',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.outlineVariant),
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

class _ProductGrid extends StatelessWidget {
  final ScrollController scrollController;
  final List<ProductEntity>? products;
  final bool isLoadingMore;
  final Future<void> Function() onRefresh;

  const _ProductGrid({
    required this.scrollController,
    required this.products,
    required this.isLoadingMore,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Scrollbar(
        child: CustomScrollView(
          controller: scrollController,
          physics: (products?.isEmpty ?? true) ? const NeverScrollableScrollPhysics() : null,
          slivers: [
            if (products == null)
              const SliverFillRemaining(hasScrollBody: false, child: AppProgressIndicator())
            else if (products!.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  subtitle: 'Нет товаров, добавьте товар',
                  buttonText: 'Добавить товар',
                  onTapButton: () => context.push('/products/product-create'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSizes.padding, 2, AppSizes.padding, AppSizes.padding),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1 / 1.55,
                    crossAxisSpacing: AppSizes.padding / 2,
                    mainAxisSpacing: AppSizes.padding / 2,
                  ),
                  itemCount: products!.length,
                  itemBuilder: (context, i) => ProductsCard(
                    product: products![i],
                    onTap: () => context.push('/products/product-detail/${products![i].id}'),
                  ),
                ),
              ),
            SliverToBoxAdapter(child: AppLoadingMoreIndicator(isLoading: isLoadingMore)),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding),
      child: AppButton(
        height: 28,
        borderRadius: AppRadius.smallAll,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 1.5),
        buttonColor: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Row(
          children: [
            Icon(Icons.add_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppSizes.padding / 4),
            Text(
              'Добавить',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        onTap: () => context.push('/products/product-create'),
      ),
    );
  }
}
