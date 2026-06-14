import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_radius.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../../core/utilities/date_time_formatter.dart';
import '../../../../domain/entities/transaction_entity.dart';

/// Status label + color for a transaction (Продан / Возвращен / Отложенный).
({String label, Color color}) transactionStatusInfo(String status) {
  switch (status) {
    case 'returned':
      return (label: 'Возвращен', color: AppColors.error);
    case 'postponed':
      return (label: 'Отложенный', color: AppColors.warning);
    case 'sold':
    default:
      return (label: 'Продан', color: AppColors.success);
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = transactionStatusInfo(transaction.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.padding),
      child: Material(
        color: colorScheme.surface,
        borderRadius: AppRadius.cardAll,
        child: InkWell(
          onTap: () => context.push('/transactions/transaction-detail/${transaction.id}'),
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
                            DateTimeFormatter.normalWithClock(transaction.createdAt ?? ''),
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      status.label,
                      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: status.color),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.padding / 1.5),
                Divider(height: 1, color: colorScheme.surfaceContainerHighest),
                const SizedBox(height: AppSizes.padding / 1.5),
                _InfoRow(
                  label: 'Контакт',
                  value: transaction.customerName?.isNotEmpty == true ? transaction.customerName! : '-',
                ),
                const SizedBox(height: AppSizes.padding / 2),
                _InfoRow(label: 'Сумма покупки', value: CurrencyFormatter.format(transaction.totalAmount), bold: true),
                const SizedBox(height: AppSizes.padding / 2),
                _InfoRow(label: 'Кассир', value: transaction.createdBy?.name ?? '-'),
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
