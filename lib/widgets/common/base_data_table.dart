// File: lib/widgets/common/base_data_table.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/utils/app_constants.dart';
import 'package:painel_windowns/widgets/common/table_cell.dart';
import 'package:painel_windowns/widgets/common/loading_indicator.dart';

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
  }) : assert(value != null || builder != null,
            'Either value or builder must be provided');

  Widget buildCell(T item) {
    if (builder != null) {
      return builder!(item);
    }
    return TableCell(
      value: value!(item),
      alignment: alignment,
    );
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
  int _currentPage = 0;
  String _sortColumn = '';
  bool _sortAscending = true;
  String _searchQuery = '';

  List<T> get _filteredItems {
    // TODO: Implementar busca se showSearch = true
    return widget.items;
  }

  List<T> get _paginatedItems {
    if (!widget.showPagination) return _filteredItems;

    final start = _currentPage * widget.pageSize;
    final end = (start + widget.pageSize).clamp(0, _filteredItems.length);

    return _filteredItems.sublist(start, end);
  }

  int get _totalPages =>
      (_filteredItems.length / widget.pageSize).ceil();

  @override
  Widget build(BuildContext context) {
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
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  AppColors.grey100,
                ),
                columns: widget.columns.map((col) {
                  return DataColumn(
                    label: TableHeader(
                      text: col.label,
                      alignment: col.alignment,
                      sortable: col.sortable,
                      isSorted: _sortColumn == col.label,
                      isAscending: _sortAscending,
                      onSort: col.sortable
                          ? () => _handleSort(col.label)
                          : null,
                    ),
                  );
                }).toList()
                  ..add(
                    DataColumn(
                      label: TableHeader(text: 'Ações'),
                    ),
                  ),
                rows: _paginatedItems.map((item) {
                  return DataRow(
                    onSelectChanged: widget.onTap != null
                        ? (_) => widget.onTap!(item)
                        : null,
                    cells: [
                      ...widget.columns.map((col) {
                        return DataCell(col.buildCell(item));
                      }),
                      DataCell(_buildActionsCell(item)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        if (widget.showPagination) _buildPagination(),
      ],
    );
  }

  Widget _buildActionsCell(T item) {
    if (widget.actions == null || widget.actions!.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleActions = widget.actions!
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

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mostrando ${_currentPage * widget.pageSize + 1}-${((_currentPage + 1) * widget.pageSize).clamp(0, _filteredItems.length)} de ${_filteredItems.length}',
            style: AppTextStyles.bodySmall,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              Text(
                'Página ${_currentPage + 1} de $_totalPages',
                style: AppTextStyles.bodySmall,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
      // TODO: Implementar lógica de ordenação
    });
  }
}
