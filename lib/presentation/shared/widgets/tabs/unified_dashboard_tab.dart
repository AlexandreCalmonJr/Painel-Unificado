// File: lib/presentation/shared/widgets/tabs/unified_dashboard_tab.dart
// Unified dashboard tab for devices and generic assets

import 'package:flutter/material.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/managed_assets_card.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/stat_card.dart';

/// Statistics configuration for dashboard
class DashboardStat {
  const DashboardStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

/// Unified dashboard tab that works for both devices and generic assets
class UnifiedDashboardTab<T> extends StatefulWidget {
  const UnifiedDashboardTab({
    required this.items,
    required this.columns,
    required this.config,
    required this.stats,
    super.key,
    this.title = 'Painel',
    this.subtitle,
    this.showActions = false,
    this.actions,
    this.onItemUpdate,
    this.currentUser,
    this.filterOptions,
    this.onFilterChanged,
  });

  final List<T> items;
  final List<AssetTableColumn<T>> columns;
  final AssetCardConfig<T> config;
  final List<DashboardStat> stats;
  final String title;
  final String? subtitle;
  final bool showActions;
  final Widget Function(T item)? actions;
  final VoidCallback? onItemUpdate;
  final Map<String, dynamic>? currentUser;
  final List<String>? filterOptions;
  // ignore: inference_failure_on_function_return_type
  final Function(String)? onFilterChanged;

  @override
  State<UnifiedDashboardTab<T>> createState() => _UnifiedDashboardTabState<T>();
}

class _UnifiedDashboardTabState<T> extends State<UnifiedDashboardTab<T>> {
  String _currentFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (widget.subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            // Filter dropdown if options provided
            if (widget.filterOptions != null && widget.onFilterChanged != null)
              DropdownButton<String>(
                value: _currentFilter,
                items:
                    widget.filterOptions!
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _currentFilter = value;
                    });
                    widget.onFilterChanged!(value);
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Statistics cards
        Row(
          children:
              widget.stats
                  .map(
                    (stat) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: StatCard(
                          title: stat.title,
                          value: stat.value,
                          icon: stat.icon,
                          color: stat.color,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 30),

        // Assets table
        Expanded(
          child: ManagedAssetsCard<T>(
            title: 'Itens Gerenciados (${widget.items.length})',
            items: widget.items,
            columns: widget.columns,
            config: widget.config,
            showActions: widget.showActions,
            actions: widget.actions,
            onItemUpdate: widget.onItemUpdate,
            currentUser: widget.currentUser,
          ),
        ),
      ],
    );
  }
}
