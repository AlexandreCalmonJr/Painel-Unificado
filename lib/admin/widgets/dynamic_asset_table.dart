// File: lib/admin/widgets/dynamic_asset_table.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/utils/app_constants.dart';
import 'package:painel_windowns/utils/module_column_defaults.dart';
import 'package:intl/intl.dart';

/// Widget de tabela dinâmica que adapta suas colunas baseado no tipo de asset
class DynamicAssetTable extends StatefulWidget {
  final String assetType;
  final List<Map<String, dynamic>> assets;
  final Function(Map<String, dynamic>)? onEdit;
  final Function(Map<String, dynamic>)? onDelete;
  final Function(Map<String, dynamic>)? onView;
  final List<String>? initialVisibleColumns;

  const DynamicAssetTable({
    super.key,
    required this.assetType,
    required this.assets,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.initialVisibleColumns,
  });

  @override
  State<DynamicAssetTable> createState() => _DynamicAssetTableState();
}

class _DynamicAssetTableState extends State<DynamicAssetTable> {
  late List<String> visibleColumns;
  String? sortColumn;
  bool sortAscending = true;
  late List<Map<String, dynamic>> sortedAssets;

  @override
  void initState() {
    super.initState();
    visibleColumns =
        widget.initialVisibleColumns ??
        ModuleColumnDefaults.getDefaultVisibleColumns(widget.assetType);
    sortedAssets = List.from(widget.assets);
  }

  @override
  void didUpdateWidget(DynamicAssetTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assets != oldWidget.assets) {
      sortedAssets = List.from(widget.assets);
      _applySorting();
    }
  }

  void _sortBy(String columnKey) {
    setState(() {
      if (sortColumn == columnKey) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = columnKey;
        sortAscending = true;
      }
      _applySorting();
    });
  }

  void _applySorting() {
    if (sortColumn == null) return;

    sortedAssets.sort((a, b) {
      final aValue = a[sortColumn];
      final bValue = b[sortColumn];

      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return sortAscending ? 1 : -1;
      if (bValue == null) return sortAscending ? -1 : 1;

      int comparison;
      if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is bool && bValue is bool) {
        comparison = aValue == bValue ? 0 : (aValue ? 1 : -1);
      } else {
        comparison = aValue.toString().compareTo(bValue.toString());
      }

      return sortAscending ? comparison : -comparison;
    });
  }

  void _showColumnSelector() {
    final allColumns = ModuleColumnDefaults.getColumnsForAssetType(
      widget.assetType,
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final themeController = ThemeController.to;
            final isDark = themeController.isDarkMode;

            return AlertDialog(
              backgroundColor:
                  isDark ? AppColors.surface : AppColors.surfaceLightMode,
              title: Text(
                'Selecionar Colunas',
                style: TextStyle(
                  color:
                      isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                ),
              ),
              content: SizedBox(
                width: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allColumns.length,
                  itemBuilder: (context, index) {
                    final column = allColumns[index];
                    final isVisible = visibleColumns.contains(column.key);

                    return CheckboxListTile(
                      title: Text(
                        column.label,
                        style: TextStyle(
                          color:
                              isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimaryLight,
                        ),
                      ),
                      value: isVisible,
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            if (!visibleColumns.contains(column.key)) {
                              visibleColumns.add(column.key);
                            }
                          } else {
                            visibleColumns.remove(column.key);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCellContent(String columnKey, dynamic value) {
    if (value == null) {
      return const Text('N/D', style: TextStyle(fontStyle: FontStyle.italic));
    }

    // Formatação especial para diferentes tipos
    if (value is DateTime) {
      return Text(DateFormat('dd/MM/yyyy HH:mm').format(value));
    }

    if (value is bool) {
      return Icon(
        value ? Icons.check_circle : Icons.cancel,
        color: value ? AppColors.success : AppColors.danger,
        size: 18,
      );
    }

    if (value is num) {
      return Text(value.toString());
    }

    // Formatação especial para campos específicos
    if (columnKey == 'status') {
      return _buildStatusBadge(value.toString());
    }

    if (columnKey == 'batteryLevel' && value is int) {
      return _buildBatteryIndicator(value);
    }

    return Text(value.toString(), maxLines: 2, overflow: TextOverflow.ellipsis);
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'online':
        color = AppColors.success;
        label = 'Online';
        break;
      case 'offline':
        color = AppColors.danger;
        label = 'Offline';
        break;
      case 'maintenance':
        color = AppColors.warning;
        label = 'Manutenção';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryIndicator(int level) {
    Color color;
    if (level > 60) {
      color = AppColors.success;
    } else if (level > 30) {
      color = AppColors.warning;
    } else {
      color = AppColors.danger;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.battery_std, color: color, size: 16),
        const SizedBox(width: 4),
        Text('$level%', style: TextStyle(color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;

      return Column(
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  '${sortedAssets.length} ${widget.assetType}(s)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _showColumnSelector,
                  icon: const Icon(Icons.view_column, size: 16),
                  label: const Text('Colunas'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeController.currentPalette['primary'],
                    side: BorderSide(
                      color: themeController.currentPalette['primary']!,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabela
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.borderLight,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      isDark ? AppColors.background : AppColors.backgroundLight,
                    ),
                    columns: [
                      ...visibleColumns.map((columnKey) {
                        final columnDef =
                            ModuleColumnDefaults.getColumnDefinition(
                              widget.assetType,
                              columnKey,
                            );

                        return DataColumn(
                          label: SizedBox(
                            width: columnDef?.width ?? 120,
                            child: Text(
                              columnDef?.label ?? columnKey,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark
                                        ? AppColors.textPrimary
                                        : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          onSort:
                              columnDef?.sortable == true
                                  ? (_, __) => _sortBy(columnKey)
                                  : null,
                        );
                      }),
                      // Coluna de ações
                      DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Text(
                            'Ações',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows:
                        sortedAssets.map((asset) {
                          return DataRow(
                            cells: [
                              ...visibleColumns.map((columnKey) {
                                final value = asset[columnKey];
                                return DataCell(
                                  DefaultTextStyle(
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? AppColors.textPrimary
                                              : AppColors.textPrimaryLight,
                                    ),
                                    child: _buildCellContent(columnKey, value),
                                  ),
                                );
                              }),
                              // Célula de ações
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.onView != null)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility,
                                          size: 18,
                                        ),
                                        onPressed: () => widget.onView!(asset),
                                        tooltip: 'Visualizar',
                                      ),
                                    if (widget.onEdit != null)
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        onPressed: () => widget.onEdit!(asset),
                                        tooltip: 'Editar',
                                      ),
                                    if (widget.onDelete != null)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 18,
                                        ),
                                        color: AppColors.danger,
                                        onPressed:
                                            () => widget.onDelete!(asset),
                                        tooltip: 'Excluir',
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
