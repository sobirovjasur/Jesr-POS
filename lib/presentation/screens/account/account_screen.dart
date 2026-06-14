import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/app_locale.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/auth/auth_notifier.dart';
import '../../providers/main/main_notifier.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_snack_bar.dart';

/// Profile tab (Figma 19 — "Profile").
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    AppDialog.show(
      title: 'Внимание',
      text: 'Хотите выйти из аккаунта?',
      leftButtonText: 'Нет',
      rightButtonText: 'Выйти',
      onTapRightButton: (context) async {
        context.pop();

        final isSyncronizing = ref.read(mainNotifierProvider).isSyncronizing;
        if (isSyncronizing) {
          AppSnackBar.showError('Идёт синхронизация', message: 'Дождитесь завершения синхронизации');
          return;
        }

        final res = await AppDialog.showProgress(() async {
          return ref.read(authNotifierProvider.notifier).signOut();
        });

        if (res.isSuccess) {
          if (!context.mounted) return;
          context.go('/sign-in');
        } else {
          AppSnackBar.showError(res.error.toString());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Future features (greyed) — open the "Soon" placeholder when tapped.
    final futureItems = <_MenuItem>[
      _MenuItem(icon: Icons.assessment_outlined, label: 'X Отчет', enabled: false),
      _MenuItem(icon: Icons.swap_horiz_rounded, label: 'Взаиморасчет', enabled: false),
      _MenuItem(icon: Icons.currency_exchange_rounded, label: 'Обмен валюты', enabled: false),
      _MenuItem(icon: Icons.payments_outlined, label: 'Затраты', enabled: false),
      _MenuItem(icon: Icons.sell_outlined, label: 'Цены', enabled: false),
      _MenuItem(icon: Icons.notifications_none_rounded, label: 'Уведомления', enabled: false),
    ];

    final mainItems = <_MenuItem>[
      _MenuItem(
        icon: Icons.print_outlined,
        label: 'Настройки принтера',
        onTap: () => context.push('/account/printer-settings'),
      ),
      _MenuItem(icon: Icons.palette_outlined, label: 'Оформления', onTap: () => context.push('/account/appearance')),
      _MenuItem(icon: Icons.info_outline_rounded, label: 'О приложении', onTap: () => context.push('/account/about')),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProfileHeader(),
              const SizedBox(height: AppSizes.padding),
              _MenuCard(
                items: [
                  ...futureItems.map((e) => e.copyWith(onTap: () => context.push('/soon'))),
                  ...mainItems,
                ],
              ),
              const SizedBox(height: AppSizes.padding),
              _MenuCard(
                items: [
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Выйти',
                    color: colorScheme.error,
                    onTap: () => _confirmSignOut(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.padding),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(mainNotifierProvider.select((p) => p.user));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final phone = user?.phone != null && user!.phone!.isNotEmpty
        ? '${AppLocale.defaultPhoneCode} ${user.phone}'
        : (user?.email ?? '');

    return Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: AppImage(
                image: user?.imageUrl ?? '',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                backgroundColor: AppColors.imageBackground,
                errorWidget: Icon(Icons.person_rounded, color: colorScheme.outline, size: 28),
              ),
            ),
            const SizedBox(width: AppSizes.padding / 1.5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name?.isNotEmpty == true ? user!.name! : 'Без имени',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(phone, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: colorScheme.primary, size: 22),
              onPressed: () => context.push('/account/profile'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.padding),
        Row(
          children: [
            Expanded(child: _InfoChip(label: 'Филиал', value: user?.branch?.isNotEmpty == true ? user!.branch! : '—')),
            const SizedBox(width: AppSizes.padding / 2),
            Expanded(child: _InfoChip(label: 'Касса', value: user?.cashbox?.isNotEmpty == true ? user!.cashbox! : '—')),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: AppRadius.cardAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(width: 1, color: colorScheme.surfaceContainerHighest),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i != 0) Divider(height: 1, indent: 52, color: colorScheme.surfaceContainerHighest),
            _MenuRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final _MenuItem item;

  const _MenuRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = item.color ?? colorScheme.onSurface;

    return Opacity(
      opacity: item.enabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: AppRadius.cardAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding, vertical: AppSizes.padding / 1.2),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: color),
              const SizedBox(width: AppSizes.padding / 1.5),
              Expanded(
                child: Text(
                  item.label,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color),
                ),
              ),
              if (item.badge)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool badge;
  final Color? color;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.enabled = true,
    this.badge = false,
    this.color,
    this.onTap,
  });

  _MenuItem copyWith({VoidCallback? onTap}) => _MenuItem(
    icon: icon,
    label: label,
    enabled: enabled,
    badge: badge,
    color: color,
    onTap: onTap ?? this.onTap,
  );
}
