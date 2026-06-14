import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/l10n.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_radius.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../../core/utilities/date_time_formatter.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../providers/home/home_notifier.dart';
import '../../../providers/main/main_notifier.dart';

/// Status label key + color for a transaction (Продан / Возвращен / Отложенный).
/// Resolve [labelKey] with `context.tr(...)` (reactive) or `L10n.trc(...)`.
({String labelKey, Color color}) transactionStatusInfo(String status) {
  switch (status) {
    case 'returned':
      return (labelKey: 'transaction_status_returned', color: AppColors.error);
    case 'postponed':
      return (labelKey: 'transaction_status_postponed', color: AppColors.warning);
    case 'sold':
    default:
      return (labelKey: 'transaction_status_sold', color: AppColors.success);
  }
}

class TransactionCard extends ConsumerWidget {
  final TransactionEntity transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // While offline, data isn't synced yet — surface every receipt as pending.
    final isOnline = ref.watch(mainNotifierProvider.select((s) => s.isHasInternet));
    final info = transactionStatusInfo(transaction.status);
    final statusLabel = isOnline ? context.tr(info.labelKey) : context.tr('transaction_status_processing');
    final statusColor = isOnline ? info.color : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.padding),
      child: Material(
        color: colorScheme.surface,
        borderRadius: AppRadius.cardAll,
        child: InkWell(
          onTap: () async {
            if (transaction.status == 'postponed') {
              await ref.read(homeNotifierProvider.notifier).resumePostponed(transaction);
              if (context.mounted) context.push('/cart');
            } else {
              context.push('/transactions/transaction-detail/${transaction.id}');
            }
          },
          borderRadius: AppRadius.cardAll,
          child: Ink(
            padding: const EdgeInsets.all(AppSizes.padding),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: AppRadius.cardAll,
              border: Border.all(width: 1, color: colorScheme.surfaceContainerHighest),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '№ ${transaction.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateTimeFormatter.dotDateWithClock(transaction.createdAt ?? ''),
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      statusLabel,
                      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.padding / 1.5),
                Divider(height: 1, color: colorScheme.surfaceContainerHighest),
                const SizedBox(height: AppSizes.padding / 1.5),
                _InfoRow(
                  label: context.tr('transaction_card_contact'),
                  value: transaction.customerName?.isNotEmpty == true ? transaction.customerName! : '-',
                ),
                const SizedBox(height: AppSizes.padding / 2),
                _InfoRow(
                  label: context.tr('transaction_card_purchase_amount'),
                  value: CurrencyFormatter.format(transaction.totalAmount),
                  bold: true,
                ),
                const SizedBox(height: AppSizes.padding / 2),
                _InfoRow(label: context.tr('receipt_detail_cashier'), value: transaction.createdBy?.name ?? '-'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(fontWeight: bold ? FontWeight.bold : FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
