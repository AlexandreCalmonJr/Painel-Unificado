import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';

class DataTableColumn<T> {
  final String label;
  final Widget Function(T item) builder;
  final bool sortable;
  final int flex;

  DataTableColumn({
    required this.label,
    required this.builder,
    this.sortable = false,
    this.flex = 1,
  });
}

class TableAction<T> {
  final String label;
  final IconData icon;
  final void Function(T item) onTap;

  TableAction({required this.label, required this.icon, required this.onTap});
}

class BaseDataTable<T> extends StatelessWidget {
  const BaseDataTable({
    super.key,
    required this.items,
    required this.columns,
    this.actions,
    this.customRow,
    this.showPagination = true,
    this.onPageChanged,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  final List<T> items;
  final List<DataTableColumn<T>> columns;
  final List<TableAction<T>>? actions;
  final Widget Function(T item)? customRow;
  final bool showPagination;
  final void Function(int page)? onPageChanged;
  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;

      return Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
            ),
            child: Row(
              children: [
                ...columns.map(
                  (col) => Expanded(
                    flex: col.flex,
                    child: Text(
                      col.label.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color:
                            isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (actions != null || customRow != null)
                  const SizedBox(width: 48), // Space for actions
              ],
            ),
          ),

          // Data Rows
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 1,
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: () {}, // Optional row tap
                  hoverColor:
                      isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        ...columns.map(
                          (col) => Expanded(
                            flex: col.flex,
                            child: col.builder(item),
                          ),
                        ),
                        if (customRow != null)
                          SizedBox(width: 48, child: customRow!(item))
                        else if (actions != null)
                          SizedBox(
                            width: 48,
                            child: PopupMenuButton<TableAction<T>>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (action) => action.onTap(item),
                              itemBuilder:
                                  (context) =>
                                      actions!
                                          .map(
                                            (action) => PopupMenuItem(
                                              value: action,
                                              child: Row(
                                                children: [
                                                  Icon(action.icon, size: 20),
                                                  const SizedBox(width: 12),
                                                  Text(action.label),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Pagination
          if (showPagination)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Página $currentPage de $totalPages',
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:
                        currentPage > 1
                            ? () => onPageChanged?.call(currentPage - 1)
                            : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        currentPage < totalPages
                            ? () => onPageChanged?.call(currentPage + 1)
                            : null,
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}
