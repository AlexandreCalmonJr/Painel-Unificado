// File: lib/presentation/shared/widgets/cards/managed_assets_card.dart
// Unified widget for displaying managed assets (devices, totems, generic assets)

import 'dart:convert';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/app_card.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/base_card.dart';
import 'package:path_provider/path_provider.dart';

/// Configuration for a table column in ManagedAssetsCard
class AssetTableColumn<T> {
  const AssetTableColumn({
    required this.label,
    required this.builder,
    this.csvBuilder,
    this.flex = 1,
  });

  final String label;
  final Widget Function(T item) builder;
  final String Function(T item)? csvBuilder;
  final int flex;
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
  final void Function(BuildContext context, T item)? onItemTap;

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
    this.onItemTap,
  });

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

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.effectiveDarkMode;
        final titleColor =
            isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
        final subtitleColor =
            isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
        final borderColor = isDark ? Colors.white10 : Colors.black12;

        final content = LayoutBuilder(
          builder: (context, constraints) {
            // Se tiver altura definida (finitas constraints), usa Expanded/scroll interno
            // Se for infinito (ex: dentro de SingleChildScrollView), usa shrinkWrap
            final useExpanded = constraints.maxHeight.isFinite;

            // Lista de itens construção
            Widget buildList({required bool shrinkWrap}) {
              if (sortedItems.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: subtitleColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum item encontrado.',
                          style: TextStyle(color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: shrinkWrap,
                physics:
                    shrinkWrap
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                itemCount: sortedItems.length,
                separatorBuilder:
                    (context, index) => Divider(height: 1, color: borderColor),
                itemBuilder: (context, index) {
                  final item = sortedItems[index];
                  return InkWell(
                    onTap:
                        (onItemTap ?? config.onItemTap) != null
                            ? () =>
                                (onItemTap ?? config.onItemTap)!(context, item)
                            : null,
                    hoverColor:
                        isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          ...columns.map(
                            (col) => Expanded(
                              flex: col.flex,
                              child: col.builder(item),
                            ),
                          ),
                          if (showActions && actions != null)
                            SizedBox(width: 48, child: actions!(item)),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Important if not expanding
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
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
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
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      ...columns.map(
                        (col) => Expanded(
                          flex: col.flex,
                          child: Text(
                            col.label,
                            style: TextStyle(
                              color: subtitleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      if (showActions && actions != null)
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
                // Table Content w/ adaptive scroll
                if (useExpanded)
                  Expanded(child: buildList(shrinkWrap: false))
                else
                  buildList(shrinkWrap: true),
              ],
            );
          },
        );

        if (config.useBaseCard) {
          return BaseCard(title: title, expandChild: expand, child: content);
        }

        return AppCard(child: content);
      },
    );
  }
}
