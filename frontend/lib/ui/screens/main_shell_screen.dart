import 'package:flutter/material.dart';
import '../core/cyber_colors.dart';

class MainShellScreen extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Widget currentScreen;

  const MainShellScreen({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      body: currentScreen,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: CyberColors.surfaceDark,
          border: Border(
            top: BorderSide(color: CyberColors.borderSubtle, width: 0.8),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: currentIndex == 0 ? Icons.home_filled : Icons.home_outlined,
                  isSelected: currentIndex == 0,
                ),
                _buildNavItem(
                  index: 1,
                  icon: currentIndex == 1 ? Icons.explore : Icons.explore_outlined,
                  isSelected: currentIndex == 1,
                ),
                // Center Neon Camera / Create Button
                GestureDetector(
                  onTap: () => onTabSelected(2),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: CyberColors.pinkGlow,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: CyberColors.pinkGlowShadow(blur: 10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.2),
                    ),
                    child: const Icon(
                      Icons.add_a_photo_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                _buildNavItem(
                  index: 3,
                  icon: currentIndex == 3 ? Icons.movie_filter : Icons.movie_filter_outlined,
                  isSelected: currentIndex == 3,
                ),
                _buildNavItem(
                  index: 4,
                  icon: currentIndex == 4 ? Icons.person : Icons.person_outline,
                  isSelected: currentIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTabSelected(index),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected ? CyberColors.primaryHotPink : CyberColors.textMuted,
              ),
              if (isSelected) ...[
                const SizedBox(height: 3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CyberColors.secondaryCyan,
                    shape: BoxShape.circle,
                    boxShadow: CyberColors.cyanGlowShadow(blur: 4),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
