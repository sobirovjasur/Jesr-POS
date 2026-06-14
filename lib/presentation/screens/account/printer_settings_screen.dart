import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/account/printer_settings_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_drop_down.dart';

/// Printer settings (Figma 21 — "Настройки принтера").
class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(printerSettingsNotifierProvider.notifier).getAndSelectPrinter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Настройки принтера', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsRow(),
            SizedBox(height: AppSizes.padding * 1.5),
            _DevicesHeader(),
            SizedBox(height: AppSizes.padding),
            _PrinterList(),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ConnectionTypeDropDown()),
        SizedBox(width: AppSizes.padding),
        Expanded(child: _PaperSizeSelector()),
      ],
    );
  }
}

class _PaperSizeSelector extends ConsumerWidget {
  const _PaperSizeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paperSize = ref.watch(printerSettingsNotifierProvider.select((p) => p.paperSize));
    final isBusy = _isBusy(ref);

    return AppDropDown<PaperSize>(
      labelText: 'Размер бумаги',
      selectedValue: paperSize,
      enabled: !isBusy,
      dropdownItems: PaperSize.values
          .map((size) => DropdownMenuItem<PaperSize>(value: size, child: Text(_label(size))))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        ref.read(printerSettingsNotifierProvider.notifier).setPaperSize(value);
      },
    );
  }

  String _label(PaperSize size) => switch (size) {
    PaperSize.mm58 => '58 мм',
    PaperSize.mm72 => '72 мм',
    PaperSize.mm80 => '80 мм',
  };
}

class _ConnectionTypeDropDown extends ConsumerWidget {
  const _ConnectionTypeDropDown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTypes = ref.watch(printerSettingsNotifierProvider.select((p) => p.selectedTypes));
    final isBusy = _isBusy(ref);

    return AppDropDown<PrinterConnectionType>.multi(
      labelText: 'Типы подключения',
      hintText: 'Выберите типы',
      enabled: !isBusy,
      selectedValues: selectedTypes,
      dropdownItems: PrinterConnectionType.values.map((type) {
        return DropdownMenuItem<PrinterConnectionType>(
          value: type,
          child: Row(
            children: [
              Icon(_icon(type), size: 18),
              const SizedBox(width: 8),
              Text(_label(type)),
            ],
          ),
        );
      }).toList(),
      selectedValuesTextBuilder: _selectedLabel,
      onChanged: (type) {
        if (type == null) return;
        ref.read(printerSettingsNotifierProvider.notifier).toggleConnectionType(type);
      },
    );
  }

  String _label(PrinterConnectionType type) => switch (type) {
    PrinterConnectionType.usb => 'USB',
    PrinterConnectionType.bluetooth => 'Bluetooth',
    PrinterConnectionType.ble => 'BLE',
    PrinterConnectionType.network => 'Network',
  };

  IconData _icon(PrinterConnectionType type) => switch (type) {
    PrinterConnectionType.usb => Icons.usb,
    PrinterConnectionType.bluetooth => Icons.bluetooth,
    PrinterConnectionType.ble => Icons.bluetooth_searching,
    PrinterConnectionType.network => Icons.wifi,
  };

  String _selectedLabel(Set<PrinterConnectionType> selectedTypes) {
    if (selectedTypes.length == PrinterConnectionType.values.length) return 'Все типы';
    return selectedTypes.map(_label).join(', ');
  }
}

class _DevicesHeader extends ConsumerWidget {
  const _DevicesHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScanning = ref.watch(printerSettingsNotifierProvider.select((p) => p.isScanning));
    final isBusy = _isBusy(ref);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('Доступные устройства', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (isScanning) ...[
              const SizedBox(width: AppSizes.padding / 1.5),
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ],
        ),
        AppButton(
          text: 'Сканировать',
          height: 38,
          fontSize: 14,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
          enabled: !isBusy,
          disabledButtonColor: colorScheme.surfaceContainerLow,
          onTap: () => ref.read(printerSettingsNotifierProvider.notifier).getAndSelectPrinter(),
        ),
      ],
    );
  }
}

class _PrinterList extends ConsumerWidget {
  const _PrinterList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(printerSettingsNotifierProvider.notifier);

    final printers = ref.watch(printerSettingsNotifierProvider.select((s) => s.printers));
    final isScanning = ref.watch(printerSettingsNotifierProvider.select((s) => s.isScanning));
    final isConnecting = ref.watch(printerSettingsNotifierProvider.select((s) => s.connectingDeviceId != null));
    final selectedPrinterIndex = notifier.selectedPrinterIndex;

    if (printers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.padding * 2),
        child: Center(
          child: Text(
            isScanning ? 'Поиск принтеров...' : 'Принтеры не найдены',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return Column(
      spacing: AppSizes.padding,
      children: List.generate(printers.length, (i) {
        final printer = printers[i];
        final isLoading = notifier.isConnectingPrinter(printer);
        final isSelected = selectedPrinterIndex == i || isLoading;

        return _DeviceTile(
          printer: printer,
          isSelected: isSelected,
          isLoading: isLoading,
          enabled: !isConnecting || isLoading,
          subtitle: notifier.getDeviceSubtitle(printer),
          onConnect: () => notifier.onSelectPrinter(printer),
          onDisconnect: () => notifier.disconnectPrinter(),
        );
      }),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final PrinterDevice printer;
  final bool isSelected;
  final bool isLoading;
  final bool enabled;
  final String subtitle;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _DeviceTile({
    required this.printer,
    required this.isSelected,
    required this.isLoading,
    required this.enabled,
    required this.subtitle,
    required this.onConnect,
    required this.onDisconnect,
  });

  IconData _connectionIcon(PrinterConnectionType type) => switch (type) {
    PrinterConnectionType.usb => Icons.usb,
    PrinterConnectionType.bluetooth => Icons.bluetooth,
    PrinterConnectionType.ble => Icons.bluetooth_searching,
    PrinterConnectionType.network => Icons.wifi,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding / 1.5),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(width: 1, color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: AppRadius.smallAll),
                child: Icon(_connectionIcon(printer.connectionType), size: 22, color: colorScheme.onSurfaceVariant),
              ),
              if (isSelected)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.padding / 1.5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  printer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.padding / 2),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (isSelected)
            AppButton(
              text: 'Отключить',
              height: 38,
              fontSize: 13,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 1.2),
              buttonColor: colorScheme.surfaceContainerLow,
              borderColor: colorScheme.surfaceContainerLow,
              textColor: colorScheme.onSurface,
              onTap: onDisconnect,
            )
          else
            AppButton(
              text: 'Подключить',
              height: 38,
              fontSize: 13,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 1.2),
              enabled: enabled,
              onTap: onConnect,
            ),
        ],
      ),
    );
  }
}

bool _isBusy(WidgetRef ref) {
  final isScanning = ref.watch(printerSettingsNotifierProvider.select((p) => p.isScanning));
  final isConnecting = ref.watch(printerSettingsNotifierProvider.select((s) => s.connectingDeviceId != null));
  final isDisconnecting = ref.watch(printerSettingsNotifierProvider.select((p) => p.isDisconnecting));
  return isScanning || isConnecting || isDisconnecting;
}
