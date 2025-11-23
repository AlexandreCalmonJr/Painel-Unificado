// File: lib/widgets/common/base_data_table.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/utils/app_constants.dart';
import 'package:painel_windowns/widgets/common/loading_indicator.dart';
import 'package:painel_windowns/widgets/common/table_cell.dart';

/// Configuração de coluna para BaseDataTable
class DataTableColumn<T> {
  final String label;
  final dynamic Function(T item)? value;
  final Widget Function(T item)? builder;
  final TextAlign alignment;
  final bool sortable;
  final int flex;

  DataTableColumn({
    required this.label,
    this.value,
    this.builder,
    this.alignment = TextAlign.left,
    this.sortable = false,
    this.flex = 1,
  }) : assert(
         value != null || builder != null,
         'Either value or builder must be provided',
       );

  Widget buildCell(T item) {
    if (builder != null) {
      return builder!(item);
    }
    return DataTableCellWidget(value: value!(item), alignment: alignment);
  }
}

/// Ação de tabela
class TableAction<T> {
  final IconData icon;
  final String label;
  final void Function(T item) onTap;
  final bool Function(T item)? isVisible;
  final Color? color;

  TableAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isVisible,
    this.color,
  });
}

/// Widget de tabela de dados genérica e reutilizável
class BaseDataTable<T> extends StatefulWidget {
  final List<T> items;
  final List<DataTableColumn<T>> columns;
  final void Function(T item)? onTap;
  final List<TableAction<T>>? actions;
  final bool showPagination;
  final bool showSearch;
  final bool showExport;
  final String? exportFileName;
  final int pageSize;
  final bool isLoading;
  final String? emptyMessage;
  final Widget Function(T item)? customRow;

  const BaseDataTable({
    super.key,
    required this.items,
    required this.columns,
    this.onTap,
    this.actions,
    this.showPagination = true,
    this.showSearch = false,
    this.showExport = false,
    this.exportFileName,
    this.pageSize = 10,
    this.isLoading = false,
    this.emptyMessage,
    this.customRow,
  });

  @override
  State<BaseDataTable<T>> createState() => _BaseDataTableState<T>();
}

class _BaseDataTableState<T> extends State<BaseDataTable<T>> {
  String _sortColumn = '';
  bool _sortAscending = true;
  final String _searchQuery = '';

  List<T> get _filteredItems {
    if (widget.showSearch) {
      return widget.items.where((item) {
        return widget.columns.any((col) {
          final value = col.value?.call(item);
          return value?.toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false;
        });
      }).toList();
    }
    return widget.items;
  }

  List<T> get _displayedItems => _filteredItems;

  void _handleSort(String columnLabel) {
    setState(() {
      if (_sortColumn == columnLabel) {
        // Se já está ordenando por esta coluna, inverte a direção
        _sortAscending = !_sortAscending;
      } else {
        // Nova coluna, começa em ordem ascendente
        _sortColumn = columnLabel;
        _sortAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'BaseDataTable: Building with ${widget.items.length} items and ${widget.columns.length} columns',
    );

    if (widget.isLoading) {
      return const LoadingIndicator(message: 'Carregando dados...');
    }

    if (widget.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          child: Text(
            widget.emptyMessage ?? 'Nenhum item encontrado',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.surfaceLight,
                      ),
                      dataRowColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primary.withOpacity(0.1);
                        }
                        return AppColors.surface;
                      }),
                      headingTextStyle: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.0,
                      ),
                      dataTextStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      dividerThickness: 1,
                      horizontalMargin: AppConstants.spacingL,
                      columnSpacing: AppConstants.spacingXL,
                      columns: [
                        ...widget.columns.map((col) {
                          return DataColumn(
                            label: TableHeader(
                              text: col.label.toUpperCase(),
                              alignment: col.alignment,
                              sortable: col.sortable,
                              isSorted: _sortColumn == col.label,
                              isAscending: _sortAscending,
                              onSort:
                                  col.sortable
                                      ? () => _handleSort(col.label)
                                      : null,
                            ),
                          );
                        }),
                        if (widget.actions != null &&
                                widget.actions!.isNotEmpty ||
                            widget.customRow != null)
                          DataColumn(label: TableHeader(text: 'AÇÕES')),
                      ],
                      rows:
                          _displayedItems.map((item) {
                            return DataRow(
                              onSelectChanged:
                                  widget.onTap != null
                                      ? (_) => widget.onTap!(item)
                                      : null,
                              cells: [
                                ...widget.columns.map((col) {
                                  final cell = col.buildCell(item);
                                  return DataCell(cell);
                                }),
                                if (widget.actions != null &&
                                        widget.actions!.isNotEmpty ||
                                    widget.customRow != null)
                                  DataCell(_buildActionsCell(item)),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCell(T item) {
    // Se customRow for fornecido, usa-o para renderizar a célula de ações
    if (widget.customRow != null) {
      return widget.customRow!(item);
    }

    if (widget.actions == null || widget.actions!.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleActions =
        widget.actions!
            .where((action) => action.isVisible?.call(item) ?? true)
            .toList();

    if (visibleActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<TableAction<T>>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) => action.onTap(item),
      itemBuilder: (context) {
        return visibleActions.map((action) {
          return PopupMenuItem<TableAction<T>>(
            value: action,
            child: Row(
              children: [
                Icon(
                  action.icon,
                  size: AppConstants.iconS,
                  color: action.color,
                ),
                const SizedBox(width: AppConstants.spacingS),
                Text(action.label),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
