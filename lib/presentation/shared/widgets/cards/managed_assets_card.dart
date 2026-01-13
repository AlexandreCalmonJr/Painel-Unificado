// File: lib/presentation/shared/widgets/cards/managed_assets_card.dart
// Unified widget for displaying managed assets (devices, totems, generic assets)

import 'dart:convert';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/app_card.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/base_card.dart';
import 'package:path_provider/path_provider.dart';

/// Configuration for a table column in ManagedAssetsCard
class AssetTableColumn<T> {
  const AssetTableColumn({
    required this.label,
    required this.builder,
    this.csvBuilder,
  });

  final String label;
  final Widget Function(T item) builder;
  final String Function(T item)? csvBuilder;
}

/// Configuration for the ManagedAssetsCard behavior
class AssetCardConfig<T> {
  const AssetCardConfig({
    required this.csvFileName,
    this.onItemTap,
    this.sortComparator,
    this.useBaseCard = false,
  });

  final String csvFileName;
  final void Function(BuildContext context, T item)? onItemTap;
  final int Function(T a, T b)? sortComparator;
  final bool useBaseCard;
}

/// Unified widget for displaying managed assets in a table with CSV export
class ManagedAssetsCard<T> extends StatelessWidget {
  const ManagedAssetsCard({
    required this.title,
    required this.items,
    required this.columns,
    required this.config,
    super.key,
    this.showActions = false,
    this.expand = false,
    this.onItemUpdate,
    this.currentUser,
    this.subtitle,
    this.actions,
  });

  final String title;
  final List<T> items;
  final List<AssetTableColumn<T>> columns;
  final AssetCardConfig<T> config;
  final bool showActions;
  final bool expand;
  final VoidCallback? onItemUpdate;
  final Map<String, dynamic>? currentUser;
  final String? subtitle;
  final Widget Function(T item)? actions;

  Future<void> _downloadCsv(BuildContext context) async {
    final headers = columns.map((col) => col.label).toList();

    final rows =
        items.map((item) {
          return columns
              .map((col) {
                final csvBuilder = col.csvBuilder;
                final value = csvBuilder != null ? csvBuilder(item) : 'N/A';
                return '"${value.replaceAll('"', '""')}"';
              })
              .join(',');
        }).toList();

    final csvContent = [headers.join(','), ...rows].join('\n');
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${config.csvFileName}_$timestamp.csv';

    try {
      if (kIsWeb) {
        final bytes = Uint8List.fromList(utf8.encode(csvContent));
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: 'csv',
          mimeType: MimeType.csv,
        );
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('CSV baixado com sucesso!')),
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}${Platform.pathSeparator}$fileName';
        final file = File(path);
        await file.writeAsString(csvContent);

        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('CSV salvo em: $path')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort items if comparator provided
    final sortedItems = List<T>.from(items);
    if (config.sortComparator != null) {
      sortedItems.sort(config.sortComparator);
    }

    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final titleColor =
          isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
      final subtitleColor =
          isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(color: subtitleColor, fontSize: 12),
                    ),
                  ],
                ],
              ),
              if (showActions)
                ElevatedButton.icon(
                  onPressed: () => _downloadCsv(context),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Baixar CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    textStyle: const TextStyle(fontSize: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Content
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                  columns: [
                    ...columns.map((col) => DataColumn(label: Text(col.label))),
                    if (actions != null) const DataColumn(label: Text('Ações')),
                  ],
                  rows:
                      sortedItems.map((item) {
                        return DataRow(
                          cells: [
                            ...columns.map(
                              (col) => DataCell(col.builder(item)),
                            ),
                            if (actions != null) DataCell(actions!(item)),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ],
      );

      // Use BaseCard or AppCard based on config
      if (config.useBaseCard) {
        return BaseCard(
          title: title,
          expandChild: expand,
          actions:
              showActions
                  ? [
                    ElevatedButton.icon(
                      onPressed: () => _downloadCsv(context),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Baixar CSV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        textStyle: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusS,
                          ),
                        ),
                      ),
                    ),
                  ]
                  : [],
          child:
              sortedItems.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum item encontrado.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? Colors.grey[800] : Colors.grey[100],
                        ),
                        columns: [
                          ...columns.map(
                            (col) => DataColumn(label: Text(col.label)),
                          ),
                          if (actions != null)
                            const DataColumn(label: Text('Ações')),
                        ],
                        rows:
                            sortedItems.map((item) {
                              return DataRow(
                                cells: [
                                  ...columns.map(
                                    (col) => DataCell(col.builder(item)),
                                  ),
                                  if (actions != null) DataCell(actions!(item)),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
        );
      }

      return AppCard(child: content);
    });
  }
}
