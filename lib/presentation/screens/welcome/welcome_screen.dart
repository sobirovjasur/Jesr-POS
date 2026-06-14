import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/assets/assets.dart';
import '../../../core/themes/app_radius.dart';

/// Splash / loading screen (Figma — soft gradient + animated Jesr logo).
///
/// Shown while the app boots and preloads data (auth check + the first sync /
/// product load happen behind this screen), so the main UI is ready by the time
/// the splash hands off.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Soft gradient base.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEDE3FB), Color(0xFFF6EEF6), Color(0xFFFBEFE6)],
                ),
              ),
            ),
          ),
          // Blurred colour blobs for the mesh-gradient look.
          const _Blob(color: Color(0xFFB9A3F0), size: 240, top: -60, left: -50),
          const _Blob(color: Color(0xFFF2C9A8), size: 200, bottom: 140, left: -40),
          const _Blob(color: Color(0xFFC9BCF2), size: 220, top: 220, right: -60),
          // Animated logo.
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sheetLarge),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Image.asset(Assets.logo, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _Blob({required this.color, required this.size, this.top, this.bottom, this.left, this.right});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.55), shape: BoxShape.circle),
        ),
      ),
    );
  }
}
