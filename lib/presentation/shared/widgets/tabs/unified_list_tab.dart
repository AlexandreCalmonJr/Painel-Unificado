// File: lib/presentation/shared/widgets/tabs/unified_list_tab.dart
// Unified list tab with search and pagination

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/managed_assets_card.dart';

/// Unified list tab for displaying items with search and pagination
class UnifiedListTab<T> extends StatefulWidget {
  const UnifiedListTab({
    required this.items,
    required this.columns,
    required this.config,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
    required this.onSearch,
    super.key,
    this.title = 'Lista de Itens',
    this.searchHint = 'Buscar...',
    this.searchLabel = 'Buscar itens',
    this.showActions = false,
    this.actions,
    this.onItemUpdate,
    this.currentUser,
    this.subtitle,
    this.isLoading = false,
  });

  final List<T> items;
  final List<AssetTableColumn<T>> columns;
  final AssetCardConfig<T> config;
  final int currentPage;
  final int totalPages;
  // ignore: inference_failure_on_function_return_type
  final Function(int) onPageChange;
  // ignore: inference_failure_on_function_return_type
  final Function(String) onSearch;
  final String title;
  final String searchHint;
  final String searchLabel;
  final bool showActions;
  final Widget Function(T item)? actions;
  final VoidCallback? onItemUpdate;
  final Map<String, dynamic>? currentUser;
  final String? subtitle;
  final bool isLoading;

  @override
  State<UnifiedListTab<T>> createState() => _UnifiedListTabState<T>();
}

class _UnifiedListTabState<T> extends State<UnifiedListTab<T>> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onSearch(_searchController.text);
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              decoration: InputDecoration(
                labelText: widget.searchLabel,
                labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                hintText: widget.searchHint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 20,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearch('');
                          },
                          tooltip: 'Limpar busca',
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),

        // Items table
        Expanded(
          child:
              widget.isLoading && widget.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ManagedAssetsCard<T>(
                    title: widget.title,
                    items: widget.items,
                    columns: widget.columns,
                    config: widget.config,
                    showActions: widget.showActions,
                    actions: widget.actions,
                    expand: true,
                    onItemUpdate: widget.onItemUpdate,
                    currentUser: widget.currentUser,
                    subtitle: widget.subtitle,
                  ),
        ),

        // Pagination
        if (widget.totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      widget.currentPage > 1
                          ? () => widget.onPageChange(-1)
                          : null,
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: const Text('Anterior'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Página ${widget.currentPage} de ${widget.totalPages}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed:
                      widget.currentPage < widget.totalPages
                          ? () => widget.onPageChange(1)
                          : null,
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: const Text('Próxima'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
