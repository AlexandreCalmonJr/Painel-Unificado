import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/utils/app_constants.dart';

/// Model for sidebar menu items
class SidebarMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final int index;
  final bool isAdminOnly;
  final bool showDividerBefore;

  const SidebarMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.index,
    this.isAdminOnly = false,
    this.showDividerBefore = false,
  });
}

/// Reusable sidebar widget for all dashboard screens
class CustomSidebar extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final List<SidebarMenuItem> menuItems;
  final int selectedIndex;
  final Function(int) onItemTap;
  final String? footerText;
  final bool isAdmin;

  const CustomSidebar({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.menuItems,
    required this.selectedIndex,
    required this.onItemTap,
    this.footerText,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;

      // Professional Minimalist Colors
      final backgroundColor = isDark ? const Color(0xFF1A202C) : Colors.white;
      final textPrimary = isDark ? Colors.white : const Color(0xFF2D3748);
      final textSecondary =
          isDark ? Colors.grey[400]! : const Color(0xFF718096);
      final dividerColor = isDark ? Colors.white10 : Colors.grey[200]!;

      return Container(
        width: 260,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(right: BorderSide(color: dividerColor)),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(textPrimary, dividerColor),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                children: _buildMenuItems(
                  textPrimary,
                  textSecondary,
                  dividerColor,
                ),
              ),
            ),

            // Footer
            if (footerText != null) _buildFooter(textSecondary, dividerColor),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(Color textColor, Color dividerColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(titleIcon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(
    Color textPrimary,
    Color textSecondary,
    Color dividerColor,
  ) {
    final List<Widget> widgets = [];

    for (final item in menuItems) {
      // Skip admin-only items if user is not admin
      if (item.isAdminOnly && !isAdmin) continue;

      // Add divider if requested
      if (item.showDividerBefore) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: dividerColor, indent: 8, endIndent: 8),
          ),
        );
      }

      // Add menu item
      widgets.add(
        _buildMenuItem(
          item: item,
          selected: selectedIndex == item.index,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      );
    }

    return widgets;
  }

  Widget _buildMenuItem({
    required SidebarMenuItem item,
    required bool selected,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final activeColor = AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: selected ? activeColor.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(
          item.icon,
          color: selected ? activeColor : textSecondary,
          size: 20,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: selected ? activeColor : textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () => onItemTap(item.index),
      ),
    );
  }

  Widget _buildFooter(Color textColor, Color dividerColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dividerColor)),
      ),
      child: Text(
        footerText!,
        style: TextStyle(color: textColor, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }
}
