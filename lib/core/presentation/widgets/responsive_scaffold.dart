import 'package:flutter/material.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final int currentIndex;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback? onSearchTapped;
  final Widget? banner;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    required this.currentIndex,
    this.onIndexChanged,
    this.onSearchTapped,
    this.banner,
  });

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
              selectedIndex: currentIndex,
              onDestinationSelected: (int index) {
                onIndexChanged?.call(index);
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
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history),
                  label: Text('History'),
                ),
              ],
              unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
              selectedLabelTextStyle: const TextStyle(color: Colors.white),
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              selectedIconTheme: const IconThemeData(color: Colors.white),
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
                    title: Text(title),
                    actions: actions,
                    backgroundColor: AppColors.background,
                    elevation: 0,
                  ),
                  ?banner,
                  Expanded(child: body),
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
      appBar: AppBar(title: Text(title), actions: actions),
      body: Column(
        children: [
          ?banner,
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.cardColor,
        currentIndex: currentIndex,
        onTap: (int index) {
          onIndexChanged?.call(index);
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
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
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
