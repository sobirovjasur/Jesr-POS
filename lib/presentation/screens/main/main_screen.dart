import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../providers/main/main_notifier.dart';
import '../welcome/welcome_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(mainNotifierProvider.notifier).initMainProvider();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoaded = ref.watch(mainNotifierProvider.select((p) => p.isLoaded));
    final isHasInternet = ref.watch(mainNotifierProvider.select((p) => p.isHasInternet));
    final user = ref.watch(mainNotifierProvider.select((p) => p.user));

    // Display RootScreen when data is being load
    if (!isLoaded) {
      return const WelcomeScreen();
    }

    // User data might still null for the first time app open or login without internet connection
    // So, throw error with a first time internet error message then the [ErrorScreen] will be shown
    if (isLoaded && user == null && !isHasInternet) {
      throw Exception(
        'No Internet connection! Internet connection is required for the first time app open or user login',
      );
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _BottomNav(
        currentIndex: _calculateSelectedIndex(),
        onTap: _onItemTapped,
      ),
    );
  }

  int _calculateSelectedIndex() {
    final String location = ref.read(appRoutesProvider).router.state.uri.path;

    if (location.startsWith('/home')) {
      return 0;
    }

    if (location.startsWith('/products')) {
      return 1;
    }

    if (location.startsWith('/transactions')) {
      return 2;
    }

    if (location.startsWith('/account')) {
      return 3;
    }

    return 0;
  }

  void _onItemTapped(int index) {
    final router = ref.read(appRoutesProvider).router;

    switch (index) {
      case 0:
        router.go('/home');
      case 1:
        router.go('/products');
      case 2:
        router.go('/transactions');
      case 3:
        router.go('/account');
    }
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const List<({IconData icon, String label})> _items = [
    (icon: Icons.point_of_sale_rounded, label: 'Главная'),
    (icon: Icons.grid_view_rounded, label: 'Товары'),
    (icon: Icons.receipt_long_rounded, label: 'Чеки'),
    (icon: Icons.person_rounded, label: 'Профиль'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: colorScheme.surfaceContainerHighest, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _items[i].icon,
                          size: 26,
                          color: i == currentIndex ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _items[i].label,
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: i == currentIndex ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
