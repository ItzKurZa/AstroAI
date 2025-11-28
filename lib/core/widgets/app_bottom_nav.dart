import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/k_sizes.dart';

class AppBottomNavItem {
  AppBottomNavItem({
    required this.label,
    required this.defaultIcon,
    required this.selectedIcon,
  });

  final String label;
  final String defaultIcon;
  final String selectedIcon;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        left: KSizes.margin6x,
        right: KSizes.margin6x,
        bottom: KSizes.margin4x,
        top: KSizes.margin3x,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < items.length; i++)
              _NavItem(
                item: items[i],
                isSelected: i == currentIndex,
                onTap: () => onChanged(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isSelected ? item.selectedIcon : item.defaultIcon,
            height: 28,
            width: 28,
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: theme.textTheme.bodyMedium!.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(item.label),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 4,
            width: isSelected ? 32 : 8,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          )
        ],
      ),
    );
  }
}

