import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_radius.dart';

enum _ToastType { success, warning, error }

/// App toast (Figma 14 — dark rounded card with status icon + title/subtitle).
///
/// Shown as a top overlay so it floats above whatever screen is active.
/// `show`/`showSuccess` render the success (green) variant; `showWarning`
/// (orange) and `showError` (red) cover the other two states. The optional
/// [message] is the second line — single-argument calls render title-only.
class AppSnackBar {
  AppSnackBar._();

  static OverlayEntry? _current;
  static Timer? _timer;

  static void show(String title, {String? message}) => _show(title, message, _ToastType.success);

  static void showSuccess(String title, {String? message}) => _show(title, message, _ToastType.success);

  static void showWarning(String title, {String? message}) => _show(title, message, _ToastType.warning);

  static void showError(String title, {String? message}) => _show(title, message, _ToastType.error);

  static void _show(String title, String? message, _ToastType type) {
    final overlay = AppRoutes.rootNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _dismiss();

    final entry = OverlayEntry(
      builder: (_) => _Toast(title: title, message: message, type: type, onDismiss: _dismiss),
    );
    _current = entry;
    overlay.insert(entry);

    _timer = Timer(const Duration(milliseconds: 2800), _dismiss);
  }

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }
}

class _Toast extends StatefulWidget {
  final String title;
  final String? message;
  final _ToastType type;
  final VoidCallback onDismiss;

  const _Toast({required this.title, required this.message, required this.type, required this.onDismiss});

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ({IconData icon, Color color}) get _style => switch (widget.type) {
    _ToastType.success => (icon: Icons.check_rounded, color: AppColors.success),
    _ToastType.warning => (icon: Icons.priority_high_rounded, color: AppColors.warning),
    _ToastType.error => (icon: Icons.close_rounded, color: AppColors.error),
  };

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    final style = _style;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -0.35), end: Offset.zero).animate(anim),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: AppRadius.cardAll,
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: style.color, shape: BoxShape.circle),
                      child: Icon(style.icon, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          if (widget.message != null && widget.message!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.message!,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
