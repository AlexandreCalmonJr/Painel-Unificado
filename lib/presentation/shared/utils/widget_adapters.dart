// File: lib/presentation/shared/utils/widget_adapters.dart
// Helper functions to adapt old API to new unified widgets API

import 'package:flutter/material.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/managed_assets_card.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_dashboard_tab.dart';

/// Converts TableColumnConfig to AssetTableColumn
List<AssetTableColumn<ManagedAsset>> convertTableColumns(
  List<TableColumnConfig> configs,
) {
  return configs.map((config) {
    int flex = 1;
    if (config.width != null) {
      if (config.width! >= 200)
        flex = 3;
      else if (config.width! >= 100)
        flex = 2;
    } else {
      // Default flex based on content type heuristic
      if (config.dataKey == 'assetName' || config.dataKey == 'hostname')
        flex = 2;
      if (config.dataKey == 'serialNumber') flex = 2;
      if (config.dataKey == 'status') flex = 1;
    }

    return AssetTableColumn<ManagedAsset>(
      label: config.label,
      flex: flex,
      builder: (asset) {
        // Extract value from asset using dataKey
        final value = _getValueFromAsset(asset, config.dataKey);
        return Text(
          value,
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        );
      },
      csvBuilder: (asset) => _getValueFromAsset(asset, config.dataKey),
    );
  }).toList();
}

/// Helper to extract value from ManagedAsset using dataKey
String _getValueFromAsset(ManagedAsset asset, String dataKey) {
  switch (dataKey) {
    case 'assetName':
      return asset.assetName;
    case 'serialNumber':
      return asset.serialNumber;
    case 'status':
      return asset.status;
    case 'location':
      return asset.location ?? 'N/D';
    case 'assignedTo':
      return asset.assignedTo ?? 'Não atribuído';
    case 'unit':
      return asset.unit ?? 'N/D';
    case 'sector':
      return asset.sector ?? 'N/D';
    case 'floor':
      return asset.floor ?? 'N/D';
    case 'lastSeen':
      return asset.lastSeenText;
    case 'currentUser':
      return asset.currentUser ?? 'N/D';
    case 'uptime':
      return asset.uptime ?? 'N/D';
    default:
      // Try to get from customData
      if (asset.customData.containsKey(dataKey)) {
        return asset.customData[dataKey]?.toString() ?? 'N/D';
      }
      return 'N/D';
  }
}

/// Generates dashboard stats from assets list
List<DashboardStat> generateDashboardStats(
  List<ManagedAsset> assets,
  String moduleType,
) {
  final total = assets.length;
  final online = assets.where((a) => a.status.toLowerCase() == 'online').length;
  final offline =
      assets.where((a) => a.status.toLowerCase() == 'offline').length;
  final maintenance =
      assets.where((a) => a.status.toLowerCase() == 'maintenance').length;

  return [
    DashboardStat(
      title: 'Total',
      value: total.toString(),
      icon: Icons.devices,
      color: Colors.blue,
    ),
    DashboardStat(
      title: 'Online',
      value: online.toString(),
      icon: Icons.check_circle,
      color: Colors.green,
    ),
    DashboardStat(
      title: 'Offline',
      value: offline.toString(),
      icon: Icons.cancel,
      color: Colors.red,
    ),
    DashboardStat(
      title: 'Manutenção',
      value: maintenance.toString(),
      icon: Icons.build,
      color: Colors.orange,
    ),
  ];
}

/// Creates AssetCardConfig for managed assets
AssetCardConfig<ManagedAsset> createAssetCardConfig(String csvFileName) {
  return AssetCardConfig<ManagedAsset>(
    csvFileName: csvFileName,
    sortComparator: (a, b) => a.assetName.compareTo(b.assetName),
    useBaseCard: false,
  );
}
