import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/products/products_notifier.dart';
import '../../widgets/app_button.dart';

/// Scan / Add entry screen (Figma 11 — "Товары").
///
/// "Сканер" opens the camera; "Вручную" opens the manual create form. Either
/// way the product ends up in Товары.
class ScanAddScreen extends StatelessWidget {
  const ScanAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr('products_title'), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, size: 64, color: colorScheme.outlineVariant),
                  const SizedBox(height: AppSizes.padding),
                  Text(
                    context.tr('scan_instruction'),
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: context.tr('scan_button'),
                      height: 52,
                      fontSize: 16,
                      onTap: () => context.push('/products/scan-camera'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.padding / 2),
                  Expanded(
                    child: AppButton(
                      text: context.tr('scan_manual_button'),
                      height: 52,
                      fontSize: 16,
                      buttonColor: colorScheme.surfaceContainerLow,
                      borderColor: colorScheme.surfaceContainerLow,
                      textColor: colorScheme.onSurface,
                      onTap: () => context.push('/products/product-create'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Camera barcode scanner (Figma 12 — "Сканировать").
///
/// On the first detected code, looks it up among loaded products: an existing
/// product opens its detail; an unknown code opens the create form pre-seeded
/// with the barcode so the new product is added to Товары.
class ScanCameraScreen extends ConsumerStatefulWidget {
  const ScanCameraScreen({super.key});

  @override
  ConsumerState<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends ConsumerState<ScanCameraScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    final raw = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    _handled = true;

    final products = ref.read(productsNotifierProvider).allProducts ?? const <ProductEntity>[];
    final matches = products.where((p) => (p.barcode ?? '').isNotEmpty && p.barcode == raw);
    final match = matches.isEmpty ? null : matches.first;

    if (!mounted) return;

    if (match != null) {
      context.go('/products/product-detail/${match.id}');
    } else {
      context.go('/products/product-create?barcode=${Uri.encodeComponent(raw)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(context.tr('scan_title'), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => _CameraError(message: error.errorDetails?.message),
            ),
          ),
          // Dark scrim with a centered, rounded clear window.
          Positioned.fill(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(
                windowSize: 240,
                radius: AppRadius.sheetLarge,
                scrimColor: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            child: Text(context.tr('scan_camera_instruction'), style: textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  final String? message;

  const _CameraError({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white70, size: 56),
            const SizedBox(height: AppSizes.padding),
            Text(
              context.tr('scan_camera_unavailable'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.padding / 2),
            Text(
              message ?? context.tr('scan_camera_permission_message'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double windowSize;
  final double radius;
  final Color scrimColor;

  _ScannerOverlayPainter({required this.windowSize, required this.radius, required this.scrimColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final window = Rect.fromCenter(center: rect.center, width: windowSize, height: windowSize);
    final windowRRect = RRect.fromRectAndRadius(window, Radius.circular(radius));

    final overlay = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      Path()..addRRect(windowRRect),
    );

    canvas.drawPath(overlay, Paint()..color = scrimColor);
    canvas.drawRRect(
      windowRRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) =>
      oldDelegate.windowSize != windowSize || oldDelegate.scrimColor != scrimColor || oldDelegate.radius != radius;
}
