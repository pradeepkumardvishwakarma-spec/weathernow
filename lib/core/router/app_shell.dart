import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// System back (button/gesture) on any of the three bottom-nav tabs is
/// intercepted here: on Favorites/Settings it just returns you to Home,
/// on Home it asks for exit confirmation instead of silently closing the
/// app. Pushed screens (forecast detail, city detail) live outside this
/// shell, so their own default back behavior is untouched.
class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  const AppShell({super.key, required this.child, required this.currentIndex});

  Future<void> _handleBack(BuildContext context) async {
    if (currentIndex != 0) {
      context.go('/');
      return;
    }
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit WeatherNow?'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Yes')),
        ],
      ),
    );
    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/favorites');
                break;
              case 2:
                context.go('/settings');
                break;
            }
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.star), label: 'Favorites'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
