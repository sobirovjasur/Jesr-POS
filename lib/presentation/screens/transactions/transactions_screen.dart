import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../providers/transactions/transactions_notifier.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_more_indicator.dart';
import '../../widgets/app_progress_indicator.dart';
import 'components/transaction_card.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final scrollController = ScrollController();
  int _tab = 0;

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsNotifierProvider.notifier).getAllTransactions();
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() async {
    final state = ref.read(transactionsNotifierProvider);

    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      await ref.read(transactionsNotifierProvider.notifier).getAllTransactions(offset: state.allTransactions?.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionsNotifierProvider.select((s) => s.allTransactions));
    final isLoadingMore = ref.watch(transactionsNotifierProvider.select((s) => s.isLoadingMore));

    final List<TransactionEntity>? filtered = allTransactions
        ?.where((t) => _tab == 0 ? t.status != 'postponed' : t.status == 'postponed')
        .toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(context.tr('receipts_title'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
            child: _SegmentedTabs(
              current: _tab,
              labels: const ['Чеки', 'Отложенный'],
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(transactionsNotifierProvider.notifier).getAllTransactions(),
              child: _TransactionList(
                scrollController: scrollController,
                transactions: filtered,
                isLoadingMore: isLoadingMore,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final ScrollController scrollController;
  final List<TransactionEntity>? transactions;
  final bool isLoadingMore;

  const _TransactionList({
    required this.scrollController,
    required this.transactions,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions == null) {
      return const CustomScrollView(
        slivers: [SliverFillRemaining(hasScrollBody: false, child: AppProgressIndicator())],
      );
    }

    if (transactions!.isEmpty) {
      return const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(hasScrollBody: false, child: AppEmptyState(subtitle: 'Чеков пока нет'))],
      );
    }

    return Scrollbar(
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSizes.padding, 2, AppSizes.padding, AppSizes.padding),
            sliver: SliverList.builder(
              itemCount: transactions!.length,
              itemBuilder: (context, i) => TransactionCard(transaction: transactions![i]),
            ),
          ),
          SliverToBoxAdapter(child: AppLoadingMoreIndicator(isLoading: isLoadingMore)),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final int current;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({required this.current, required this.labels, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLow, borderRadius: AppRadius.cardAll),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == current ? colorScheme.surface : Colors.transparent,
                    // Concentric with the outer container (radius 12, padding 4).
                    borderRadius: BorderRadius.circular(AppRadius.card - 4),
                  ),
                  child: Text(
                    labels[i],
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: i == current ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
