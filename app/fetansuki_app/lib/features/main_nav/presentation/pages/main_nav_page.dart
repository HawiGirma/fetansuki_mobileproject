import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavPage({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            children: [
              // Navigation Pill
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E4FF), // Light Blue
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BottomNavItem(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        isSelected: navigationShell.currentIndex == 0,
                        onTap: () => _onTap(context, 0),
                      ),
                      _BottomNavItem(
                        icon: Icons.grid_view_outlined,
                        label: 'Stock',
                        isSelected: navigationShell.currentIndex == 1,
                        onTap: () => _onTap(context, 1),
                      ),
                      _BottomNavItem(
                        icon: Icons.receipt_long_outlined,
                        label: 'Credit',
                        isSelected: navigationShell.currentIndex == 2,
                        onTap: () => _onTap(context, 2),
                      ),
                      _BottomNavItem(
                        icon: Icons.settings_outlined,
                        label: 'Setting',
                        isSelected: navigationShell.currentIndex == 3,
                        onTap: () => _onTap(context, 3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Action Button (FAB style)
              GestureDetector(
                onTap: () {
                   // Handle action
                   debugPrint('FAB Clicked');
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F3C7E), // Dark Blue
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long, // Bill/Invoice icon
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        decoration: isSelected
            ? const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(80)),
          color: Color(0xFF0F3C7E), // Dark Blue
        )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF0F3C7E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: (isSelected) ?  Colors.white: Color(0xFF0F3C7E) ,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
