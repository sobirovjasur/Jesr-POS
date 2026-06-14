import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/home/home_notifier.dart';
import '../../providers/main/main_notifier.dart';
import '../../providers/products/products_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_more_indicator.dart';
import '../../widgets/app_progress_indicator.dart';
import 'components/home_product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => onRefresh());
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() async {
    final productsState = ref.read(productsNotifierProvider);

    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      await ref.read(productsNotifierProvider.notifier).getAllProducts(offset: productsState.allProducts?.length);
    }
  }

  Future<void> onRefresh() async {
    await ref.read(productsNotifierProvider.notifier).getAllProducts();
    await ref.read(mainNotifierProvider.notifier).checkIsHasQueuedActions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: _ProductGrid(scrollController: scrollController, onRefresh: onRefresh),
            ),
            const _CartBar(),
          ],
        ),
      ),
    );
  }
}

class _CartBar extends ConsumerWidget {
  const _CartBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasItems = ref.watch(homeNotifierProvider.select((s) => s.orderedProducts.isNotEmpty));

    if (!hasItems) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: AppButton(
        text: 'Перейти в корзину',
        width: double.infinity,
        height: 52,
        fontSize: 18,
        onTap: () => context.push('/cart'),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';

    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) return '+$digits';

    final cc = digits.substring(0, digits.length - 9);
    final rest = digits.substring(digits.length - 9);
    final grouped = '${rest.substring(0, 2)} ${rest.substring(2, 5)} ${rest.substring(5, 7)} ${rest.substring(7, 9)}';

    return '+$cc $grouped';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(mainNotifierProvider.select((p) => p.user));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.padding,
        AppSizes.padding / 2,
        AppSizes.padding,
        AppSizes.padding / 2,
      ),
      child: Row(
        children: [
          AppImage(
            image: user?.imageUrl ?? '',
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            backgroundColor: colorScheme.surfaceContainerLow,
            errorWidget: Icon(Icons.person, color: colorScheme.outline, size: 24),
          ),
          const SizedBox(width: AppSizes.padding / 1.5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatPhone(user?.phone),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.padding / 2),
          const _SyncChip(),
        ],
      ),
    );
  }
}

class _SyncChip extends ConsumerWidget {
  const _SyncChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncronizing = ref.watch(mainNotifierProvider.select((p) => p.isSyncronizing));
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: () => ref.read(mainNotifierProvider.notifier).checkAndSyncAllData(),
        borderRadius: AppRadius.pillAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 1.5, vertical: AppSizes.padding / 2.5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: isSyncronizing
                    ? CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary)
                    : Icon(Icons.sync_rounded, size: 14, color: colorScheme.primary),
              ),
              const SizedBox(width: 4),
              Text(
                'Синхр.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  const _ProductGrid({required this.scrollController, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProducts = ref.watch(productsNotifierProvider.select((p) => p.allProducts));
    final isLoadingMore = ref.watch(productsNotifierProvider.select((p) => p.isLoadingMore));

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Scrollbar(
        child: CustomScrollView(
          controller: scrollController,
          physics: (allProducts?.isEmpty ?? true) ? const NeverScrollableScrollPhysics() : null,
          slivers: [
            if (allProducts == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(padding: EdgeInsets.only(bottom: 140), child: AppProgressIndicator()),
              )
            else if (allProducts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 140),
                  child: AppEmptyState(subtitle: 'Mahsulotlar yo\'q'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.padding,
                  AppSizes.padding,
                  AppSizes.padding,
                  AppSizes.padding,
                ),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1 / 1.55,
                    crossAxisSpacing: AppSizes.padding / 2,
                    mainAxisSpacing: AppSizes.padding / 2,
                  ),
                  itemCount: allProducts.length,
                  itemBuilder: (context, i) => HomeProductCard(product: allProducts[i]),
                ),
              ),
            SliverToBoxAdapter(child: AppLoadingMoreIndicator(isLoading: isLoadingMore)),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}
