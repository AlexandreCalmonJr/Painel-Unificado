// File: lib/presentation/shared/widgets/cards/totem_table_columns.dart
// Helper functions to build table columns for totems

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painel_windowns/core/utils/status_formatter.dart';
import 'package:painel_windowns/data/models/totem_model.dart';
import 'package:painel_windowns/presentation/features/totem/pages/totem_detail_screen.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/managed_assets_card.dart';
import 'package:painel_windowns/services/auth_service.dart';

/// Builds standard totem table columns
List<AssetTableColumn<Totem>> buildTotemTableColumns() {
  return [
    AssetTableColumn<Totem>(
      label: 'Hostname',
      builder:
          (totem) => Text(
            totem.hostname,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
      csvBuilder: (totem) => totem.hostname,
    ),
    AssetTableColumn<Totem>(
      label: 'Status',
      builder: (totem) {
        final color = _getStatusColor(totem.status);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            totem.status,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
      csvBuilder: (totem) => totem.status,
    ),
    AssetTableColumn<Totem>(
      label: 'IP',
      builder: (totem) => Text(totem.ip),
      csvBuilder: (totem) => totem.ip,
    ),
    AssetTableColumn<Totem>(
      label: 'Localização',
      builder: (totem) => Text(totem.unit ?? totem.location!),
      csvBuilder: (totem) => totem.location ?? totem.unit ?? 'N/A',
    ),
    AssetTableColumn<Totem>(
      label: 'Serial',
      builder: (totem) => Text(totem.serialNumber),
      csvBuilder: (totem) => totem.serialNumber,
    ),
    AssetTableColumn<Totem>(
      label: 'Status Zebra',
      builder:
          (totem) =>
              Text(StatusFormatter.formatPeripheralStatus(totem.zebraStatus)),
      csvBuilder:
          (totem) => StatusFormatter.formatPeripheralStatus(totem.zebraStatus),
    ),
    AssetTableColumn<Totem>(
      label: 'Status Bematech',
      builder:
          (totem) => Text(
            StatusFormatter.formatPeripheralStatus(totem.bematechStatus),
          ),
      csvBuilder:
          (totem) =>
              StatusFormatter.formatPeripheralStatus(totem.bematechStatus),
    ),
    AssetTableColumn<Totem>(
      label: 'Tipo de Totem',
      builder: (totem) => Text(totem.totemType),
      csvBuilder: (totem) => totem.totemType,
    ),
    AssetTableColumn<Totem>(
      label: 'Mozilla Firefox',
      builder: (totem) => Text(totem.mozillaVersion),
      csvBuilder: (totem) => totem.mozillaVersion,
    ),
    AssetTableColumn<Totem>(
      label: 'Java',
      builder: (totem) => Text(totem.javaVersion),
      csvBuilder: (totem) => totem.javaVersion,
    ),
    AssetTableColumn<Totem>(
      label: 'Última Sincronização',
      builder:
          (totem) =>
              Text(DateFormat('dd/MM/yyyy HH:mm').format(totem.lastSeen)),
      csvBuilder:
          (totem) => DateFormat('dd/MM/yyyy HH:mm:ss').format(totem.lastSeen),
    ),
  ];
}

/// Builds totem card configuration
AssetCardConfig<Totem> buildTotemCardConfig(
  BuildContext context,
  AuthService authService,
) {
  return AssetCardConfig<Totem>(
    csvFileName: 'totens',
    onItemTap: (context, totem) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  TotemDetailScreen(totem: totem, authService: authService),
        ),
      );
    },
    sortComparator:
        (a, b) => a.hostname.toLowerCase().compareTo(b.hostname.toLowerCase()),
  );
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'online':
      return Colors.green;
    case 'offline':
      return Colors.red;
    case 'maintenance':
    case 'com erro':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
