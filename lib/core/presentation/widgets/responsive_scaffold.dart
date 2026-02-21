import 'package:flutter/material.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';

class ResponsiveScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onSearchTapped;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.onSearchTapped,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.cardColor,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                if (index == 1) {
                  widget.onSearchTapped?.call();
                  return;
                }
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  selectedIcon: Icon(Icons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
              unselectedLabelTextStyle: const TextStyle(
                color: AppColors.textSecondary,
              ),
              selectedLabelTextStyle: const TextStyle(color: AppColors.primary),
              unselectedIconTheme: const IconThemeData(
                color: AppColors.textSecondary,
              ),
              selectedIconTheme: const IconThemeData(color: AppColors.primary),
            ),
            const VerticalDivider(
              thickness: 1,
              width: 1,
              color: AppColors.divider,
            ),
            Expanded(
              child: Column(
                children: [
                  AppBar(
                    title: Text(widget.title),
                    actions: widget.actions,
                    backgroundColor: AppColors.background, // Match scaffold
                    elevation: 0,
                  ),
                  Expanded(child: widget.body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Layout
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title), actions: widget.actions),
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.cardColor,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          if (index == 1) {
            widget.onSearchTapped?.call();
            return;
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
