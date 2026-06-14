import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../core/utilities/date_time_formatter.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../providers/transactions/transaction_detail_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';
import 'components/transaction_card.dart';

/// Transaction detail (Figma 17/18 — "Чеки").
///
/// Two visual states driven by [TransactionEntity.status]:
///  * `sold`     → success (green check, "Оплата прошла успешно")
///  * `returned` → error   (red warning, "Оплата не выполнена")
/// `postponed` transactions never reach this screen (tapping one resumes it
/// back into the cart), so they fall through to the success styling defensively.
class TransactionDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const TransactionDetailScreen({super.key, required this.id});

  @override
  ConsumerState<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends ConsumerState<TransactionDetailScreen> {
  late final Future<TransactionEntity?> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(transactionDetailNotifierProvider.notifier).getTransactionDetail(widget.id);
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/transactions');
    }
  }

  Future<void> _onShare(BuildContext buttonContext, TransactionEntity transaction) async {
    // sharePositionOrigin anchors the share popover on iPad/macOS (ignored on
    // phones). Resolve it from the button's own RenderBox.
    final box = buttonContext.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: _buildReceipt(transaction),
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      ),
    );
  }

  String _buildReceipt(TransactionEntity t) {
    final lines = <String>[
      'Чек № ${t.id ?? '-'}',
      'Статус: ${transactionStatusInfo(t.status).label}',
      'Дата: ${DateTimeFormatter.dotDateWithClock(t.createdAt ?? '')}',
      'Кассир: ${t.createdBy?.name ?? '-'}',
      'Способ оплаты: ${_paymentLabel(t.paymentMethod)}',
      if (t.description?.isNotEmpty == true) 'Описание: ${t.description}',
      '',
    ];

    for (final p in t.orderedProducts ?? const []) {
      lines.add('${p.name} ×${p.quantity} — ${CurrencyFormatter.format(p.price * p.quantity)}');
    }

    lines.addAll([
      '',
      'Итого: ${CurrencyFormatter.format(t.totalAmount)}',
      'Получено: ${t.receivedAmount > 0 ? CurrencyFormatter.format(t.receivedAmount) : '-'}',
      'Сдача: ${t.returnAmount > 0 ? CurrencyFormatter.format(t.returnAmount) : '-'}',
    ]);

    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Чеки', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _onBack,
        ),
      ),
      body: FutureBuilder<TransactionEntity?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppProgressIndicator();
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const AppEmptyState(title: 'Чек не найден');
          }

          final transaction = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: _DetailCard(transaction: transaction),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: Builder(
                    builder: (btnContext) => AppButton(
                      text: 'Поделиться',
                      width: double.infinity,
                      height: 52,
                      fontSize: 18,
                      onTap: () => _onShare(btnContext, transaction),
                    ),
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

String _paymentLabel(String method) => method == 'cash' ? 'Наличные' : method;

/// Icon + title for the success / error header.
({Widget icon, String title}) _statusHeader(String status) {
  if (status == 'returned') {
    return (
      icon: const Icon(Icons.warning_rounded, color: AppColors.error, size: 64),
      title: 'Оплата не выполнена',
    );
  }
  return (
    icon: Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
      child: const Icon(Icons.check_rounded, color: AppColors.onPrimary, size: 38),
    ),
    title: 'Оплата прошла успешно',
  );
}

class _DetailCard extends StatelessWidget {
  final TransactionEntity transaction;

  const _DetailCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final header = _statusHeader(transaction.status);

    final t = transaction;

    final rows = <({String label, String value, bool bold})>[
      (label: 'Номер чека', value: '${t.id ?? '-'}', bold: false),
      (label: 'Способ оплаты', value: _paymentLabel(t.paymentMethod), bold: false),
      (label: 'Кассир', value: t.createdBy?.name ?? '-', bold: false),
      (label: 'Дата и время', value: DateTimeFormatter.dotDateWithClock(t.createdAt ?? ''), bold: false),
      (label: 'Описание', value: t.description?.isNotEmpty == true ? t.description! : '-', bold: false),
      (label: 'Количество товаров', value: '${t.totalOrderedProduct}', bold: false),
      (label: 'Итоговая сумма', value: CurrencyFormatter.format(t.totalAmount), bold: true),
      (label: 'Сдача', value: t.returnAmount > 0 ? CurrencyFormatter.format(t.returnAmount) : '-', bold: false),
      (
        label: 'Полученная сумма',
        value: t.receivedAmount > 0 ? CurrencyFormatter.format(t.receivedAmount) : '-',
        bold: true,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(width: 1, color: colorScheme.surfaceContainerHighest),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.padding, AppSizes.padding * 1.5, AppSizes.padding, AppSizes.padding * 1.5),
            child: Column(
              children: [
                header.icon,
                const SizedBox(height: AppSizes.padding),
                Text(
                  header.title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          for (final r in rows) ...[
            Divider(height: 1, color: colorScheme.surfaceContainerHighest),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding, vertical: AppSizes.padding / 1.5),
              child: _DetailRow(label: r.label, value: r.value, bold: r.bold),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _DetailRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: AppSizes.padding),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: textTheme.bodyMedium?.copyWith(fontWeight: bold ? FontWeight.bold : FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
