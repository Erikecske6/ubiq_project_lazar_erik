import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  final String currentPath;
  final Widget child;

  static const List<_NavigationItem> _items = [
    _NavigationItem(
      path: '/plants',
      label: 'Plants',
      icon: Icons.local_florist_outlined,
      selectedIcon: Icons.local_florist,
    ),
    _NavigationItem(
      path: '/care',
      label: 'Care',
      icon: Icons.check_circle_outline,
      selectedIcon: Icons.check_circle,
    ),
    _NavigationItem(
      path: '/weather',
      label: 'Weather',
      icon: Icons.wb_sunny_outlined,
      selectedIcon: Icons.wb_sunny,
    ),
    _NavigationItem(
      path: '/profile',
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
    _NavigationItem(
      path: '/settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  int get _selectedIndex {
    final index = _items.indexWhere((item) => currentPath.startsWith(item.path));
    return index == -1 ? 0 : index;
  }

  void _goTo(BuildContext context, int index) {
    final path = _items[index].path;
    if (path != currentPath) {
      context.go(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideLayout = MediaQuery.sizeOf(context).width >= 800;

    if (isWideLayout) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => _goTo(context, index),
              labelType: NavigationRailLabelType.all,
              destinations: _items
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _goTo(context, index),
        items: _items
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}