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

      // Use theme-aware colors
      final textPrimary =
          isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
      final textSecondary =
          isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

      return Container(
        width: 250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                    : [
                      AppColors.surfaceLightMode,
                      AppColors.surfaceLightVariant,
                    ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(textPrimary),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: _buildMenuItems(textPrimary, textSecondary),
              ),
            ),

            // Footer
            if (footerText != null) _buildFooter(textSecondary),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.24)),
        ),
      ),
      child: Row(
        children: [
          Icon(titleIcon, color: textColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(Color textPrimary, Color textSecondary) {
    final List<Widget> widgets = [];

    for (final item in menuItems) {
      // Skip admin-only items if user is not admin
      if (item.isAdminOnly && !isAdmin) continue;

      // Add divider if requested
      if (item.showDividerBefore) {
        widgets.add(
          const Divider(color: Colors.white24, indent: 16, endIndent: 16),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: selected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: selected ? AppColors.primary : textSecondary,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: selected ? AppColors.primary : textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: TextStyle(
            color: selected ? AppColors.primary : textSecondary,
            fontSize: 12,
          ),
        ),
        trailing:
            selected
                ? const Icon(Icons.chevron_right, color: AppColors.primary)
                : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => onItemTap(item.index),
      ),
    );
  }

  Widget _buildFooter(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        footerText!,
        style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
