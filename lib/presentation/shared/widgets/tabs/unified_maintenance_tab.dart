// File: lib/presentation/shared/widgets/tabs/unified_maintenance_tab.dart
// Unified maintenance tab for devices and generic assets

import 'package:flutter/material.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/managed_assets_card.dart';

/// Unified maintenance tab that displays items in maintenance mode
class UnifiedMaintenanceTab<T> extends StatelessWidget {
  const UnifiedMaintenanceTab({
    required this.items,
    required this.columns,
    required this.config,
    required this.moduleTypeName,
    super.key,
    this.showActions = true,
    this.actions,
    this.onItemUpdate,
    this.currentUser,
  });

  final List<T> items;
  final List<AssetTableColumn<T>> columns;
  final AssetCardConfig<T> config;
  final String moduleTypeName;
  final bool showActions;
  final Widget Function(T item)? actions;
  final VoidCallback? onItemUpdate;
  final Map<String, dynamic>? currentUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manutenção - $moduleTypeName',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Itens que estão atualmente marcados para manutenção.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ManagedAssetsCard<T>(
            title: 'Itens em Manutenção (${items.length})',
            items: items,
            columns: columns,
            config: config,
            showActions: showActions,
            actions: actions,
            onItemUpdate: onItemUpdate,
            currentUser: currentUser,
          ),
        ),
      ],
    );
  }
}
