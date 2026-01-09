// File: lib/utils/module_column_defaults.dart
import 'package:flutter/material.dart';

/// Definição de uma coluna para tabelas de assets
class AssetColumnDefinition {

  const AssetColumnDefinition({
    required this.key,
    required this.label,
    this.width,
    this.sortable = true,
    this.customBuilder,
  });
  final String key;
  final String label;
  final double? width;
  final bool sortable;
  final Widget Function(Map<String, dynamic> asset)? customBuilder;
}

/// Configurações de colunas padrão para cada tipo de asset
class ModuleColumnDefaults {
  /// Colunas para Notebooks
  static List<AssetColumnDefinition> get notebookColumns => [
    const AssetColumnDefinition(key: 'assetName', label: 'Nome', width: 150),
    const AssetColumnDefinition(key: 'hostname', label: 'Hostname', width: 150),
    const AssetColumnDefinition(
      key: 'serialNumber',
      label: 'Serial',
      width: 140,
    ),
    const AssetColumnDefinition(key: 'model', label: 'Modelo', width: 130),
    const AssetColumnDefinition(
      key: 'manufacturer',
      label: 'Fabricante',
      width: 120,
    ),
    const AssetColumnDefinition(
      key: 'processor',
      label: 'Processador',
      width: 150,
    ),
    const AssetColumnDefinition(key: 'ram', label: 'RAM', width: 80),
    const AssetColumnDefinition(
      key: 'storage',
      label: 'Armazenamento',
      width: 120,
    ),
    const AssetColumnDefinition(
      key: 'operatingSystem',
      label: 'SO',
      width: 100,
    ),
    const AssetColumnDefinition(
      key: 'osVersion',
      label: 'Versão SO',
      width: 100,
    ),
    const AssetColumnDefinition(
      key: 'batteryLevel',
      label: 'Bateria',
      width: 80,
    ),
    const AssetColumnDefinition(
      key: 'batteryHealth',
      label: 'Saúde Bateria',
      width: 110,
    ),
    const AssetColumnDefinition(
      key: 'biometricReaderStatus',
      label: 'Leitor Biométrico',
      width: 130,
    ),
    const AssetColumnDefinition(key: 'ipAddress', label: 'IP', width: 120),
    const AssetColumnDefinition(key: 'macAddress', label: 'MAC', width: 140),
    const AssetColumnDefinition(
      key: 'currentUser',
      label: 'Usuário Atual',
      width: 130,
    ),
    const AssetColumnDefinition(key: 'uptime', label: 'Uptime', width: 100),
    const AssetColumnDefinition(
      key: 'antivirusStatus',
      label: 'Antivírus',
      width: 90,
    ),
    const AssetColumnDefinition(
      key: 'isEncrypted',
      label: 'Criptografado',
      width: 110,
    ),
    const AssetColumnDefinition(key: 'unit', label: 'Unidade', width: 120),
    const AssetColumnDefinition(key: 'sector', label: 'Setor', width: 120),
    const AssetColumnDefinition(key: 'floor', label: 'Andar', width: 100),
    const AssetColumnDefinition(key: 'status', label: 'Status', width: 100),
    const AssetColumnDefinition(
      key: 'lastSeen',
      label: 'Última Conexão',
      width: 150,
    ),
  ];

  /// Colunas para Desktops
  static List<AssetColumnDefinition> get desktopColumns => [
    const AssetColumnDefinition(key: 'assetName', label: 'Nome', width: 150),
    const AssetColumnDefinition(key: 'hostname', label: 'Hostname', width: 150),
    const AssetColumnDefinition(
      key: 'serialNumber',
      label: 'Serial',
      width: 140,
    ),
    const AssetColumnDefinition(key: 'model', label: 'Modelo', width: 130),
    const AssetColumnDefinition(
      key: 'manufacturer',
      label: 'Fabricante',
      width: 120,
    ),
    const AssetColumnDefinition(
      key: 'processor',
      label: 'Processador',
      width: 150,
    ),
    const AssetColumnDefinition(key: 'ram', label: 'RAM', width: 80),
    const AssetColumnDefinition(
      key: 'storage',
      label: 'Armazenamento',
      width: 120,
    ),
    const AssetColumnDefinition(
      key: 'storageType',
      label: 'Tipo HD',
      width: 90,
    ),
    const AssetColumnDefinition(
      key: 'operatingSystem',
      label: 'SO',
      width: 100,
    ),
    const AssetColumnDefinition(
      key: 'osVersion',
      label: 'Versão SO',
      width: 100,
    ),
    const AssetColumnDefinition(
      key: 'biometricReader',
      label: 'Leitor Biométrico',
      width: 130,
    ),
    const AssetColumnDefinition(
      key: 'connectedPrinter',
      label: 'Impressora',
      width: 130,
    ),
    const AssetColumnDefinition(key: 'ipAddress', label: 'IP', width: 120),
    const AssetColumnDefinition(key: 'macAddress', label: 'MAC', width: 140),
    const AssetColumnDefinition(
      key: 'currentUser',
      label: 'Usuário Atual',
      width: 130,
    ),
    const AssetColumnDefinition(key: 'uptime', label: 'Uptime', width: 100),
    const AssetColumnDefinition(key: 'javaVersion', label: 'Java', width: 100),
    const AssetColumnDefinition(
      key: 'browserVersion',
      label: 'Navegador',
      width: 120,
    ),
    const AssetColumnDefinition(
      key: 'antivirusStatus',
      label: 'Antivírus',
      width: 90,
    ),
    const AssetColumnDefinition(key: 'unit', label: 'Unidade', width: 120),
    const AssetColumnDefinition(key: 'sector', label: 'Setor', width: 120),
    const AssetColumnDefinition(key: 'floor', label: 'Andar', width: 100),
    const AssetColumnDefinition(key: 'status', label: 'Status', width: 100),
    const AssetColumnDefinition(
      key: 'lastSeen',
      label: 'Última Conexão',
      width: 150,
    ),
  ];

  /// Colunas para Impressoras
  static List<AssetColumnDefinition> get printerColumns => [
    const AssetColumnDefinition(key: 'assetName', label: 'Nome', width: 150),
    const AssetColumnDefinition(key: 'hostname', label: 'Hostname', width: 150),
    const AssetColumnDefinition(
      key: 'serialNumber',
      label: 'Serial',
      width: 140,
    ),
    const AssetColumnDefinition(key: 'model', label: 'Modelo', width: 130),
    const AssetColumnDefinition(
      key: 'manufacturer',
      label: 'Fabricante',
      width: 120,
    ),
    const AssetColumnDefinition(
      key: 'connectionType',
      label: 'Conexão',
      width: 100,
    ),
    const AssetColumnDefinition(key: 'ipAddress', label: 'IP', width: 120),
    const AssetColumnDefinition(key: 'macAddress', label: 'MAC', width: 140),
    const AssetColumnDefinition(key: 'usbPort', label: 'Porta USB', width: 100),
    const AssetColumnDefinition(
      key: 'hostComputerName',
      label: 'Computador Host',
      width: 140,
    ),
    const AssetColumnDefinition(
      key: 'hostComputerIp',
      label: 'IP Host',
      width: 120,
    ),
    const AssetColumnDefinition(
      key: 'printerStatus',
      label: 'Status Impressora',
      width: 130,
    ),
    const AssetColumnDefinition(key: 'errorMessage', label: 'Erro', width: 150),
    const AssetColumnDefinition(
      key: 'totalPageCount',
      label: 'Total Páginas',
      width: 110,
    ),
    const AssetColumnDefinition(
      key: 'colorPageCount',
      label: 'Páginas Coloridas',
      width: 130,
    ),
    const AssetColumnDefinition(
      key: 'blackWhitePageCount',
      label: 'Páginas P&B',
      width: 110,
    ),
    const AssetColumnDefinition(
      key: 'paperLevel',
      label: 'Nível Papel',
      width: 100,
    ),
    const AssetColumnDefinition(key: 'isDuplex', label: 'Duplex', width: 80),
    const AssetColumnDefinition(key: 'isColor', label: 'Colorida', width: 80),
    const AssetColumnDefinition(
      key: 'firmwareVersion',
      label: 'Firmware',
      width: 100,
    ),
    const AssetColumnDefinition(
      key: 'driverVersion',
      label: 'Driver',
      width: 100,
    ),
    const AssetColumnDefinition(
      key: 'lastMaintenanceDate',
      label: 'Última Manutenção',
      width: 140,
    ),
    const AssetColumnDefinition(key: 'unit', label: 'Unidade', width: 120),
    const AssetColumnDefinition(key: 'sector', label: 'Setor', width: 120),
    const AssetColumnDefinition(key: 'floor', label: 'Andar', width: 100),
    const AssetColumnDefinition(key: 'status', label: 'Status', width: 100),
    const AssetColumnDefinition(
      key: 'lastSeen',
      label: 'Última Conexão',
      width: 150,
    ),
  ];

  /// Retorna as colunas apropriadas baseadas no tipo de asset
  static List<AssetColumnDefinition> getColumnsForAssetType(String assetType) {
    switch (assetType.toLowerCase()) {
      case 'notebook':
        return notebookColumns;
      case 'desktop':
        return desktopColumns;
      case 'printer':
        return printerColumns;
      default:
        // Colunas genéricas para tipos desconhecidos
        return [
          const AssetColumnDefinition(
            key: 'assetName',
            label: 'Nome',
            width: 150,
          ),
          const AssetColumnDefinition(
            key: 'serialNumber',
            label: 'Serial',
            width: 140,
          ),
          const AssetColumnDefinition(
            key: 'status',
            label: 'Status',
            width: 100,
          ),
          const AssetColumnDefinition(
            key: 'lastSeen',
            label: 'Última Conexão',
            width: 150,
          ),
        ];
    }
  }

  /// Colunas padrão visíveis inicialmente (primeiras 8 colunas)
  static List<String> getDefaultVisibleColumns(String assetType) {
    final columns = getColumnsForAssetType(assetType);
    return columns.take(8).map((col) => col.key).toList();
  }

  /// Todas as chaves de colunas disponíveis para um tipo
  static List<String> getAllColumnKeys(String assetType) {
    return getColumnsForAssetType(assetType).map((col) => col.key).toList();
  }

  /// Obtém a definição de uma coluna específica
  static AssetColumnDefinition? getColumnDefinition(
    String assetType,
    String columnKey,
  ) {
    final columns = getColumnsForAssetType(assetType);
    try {
      return columns.firstWhere((col) => col.key == columnKey);
    } catch (e) {
      return null;
    }
  }
}
