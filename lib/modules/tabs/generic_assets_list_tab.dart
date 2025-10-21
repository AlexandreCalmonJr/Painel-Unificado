// File: lib/tabs/generic_assets_list_tab.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/widgets/generic_managed_assets_card.dart';

class GenericAssetsListTab extends StatelessWidget {
  final List<ManagedAsset> displayedAssets;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChange;
  final Function(String) onSearch;
  final VoidCallback onRefresh;
  final Function(ManagedAsset) onAssetUpdate;
  final Function(ManagedAsset) onAssetDelete;
  final List<TableColumnConfig> columns; // <-- CAMPO ADICIONADO

  const GenericAssetsListTab({
    super.key,
    required this.displayedAssets,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
    required this.onSearch,
    required this.onRefresh,
    required this.onAssetUpdate,
    required this.onAssetDelete,
    required this.columns, // <-- CAMPO ADICIONADO
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    labelText: 'Buscar ativos',
                    hintText: 'Nome, serial, localização, setor, andar...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: (isLoading && displayedAssets.isEmpty)
                  ? const Center(child: CircularProgressIndicator())
                  : (displayedAssets.isEmpty)
                      ? const Center(child: Text('Nenhum ativo encontrado'))
                      : Column(
                          children: [
                            Expanded(
                              child: GenericManagedAssetsCard(
                                title: 'Lista de Ativos ($currentPage/$totalPages)',
                                assets: displayedAssets,
                                columns: columns, // <-- Passa as colunas
                                showActions: true,
                                onAssetUpdate: onAssetUpdate,
                                onAssetDelete: onAssetDelete,
                                onMaintenanceUpdate: (asset, setMaintenance) {
                                  // A lógica de manutenção é tratada na MaintenanceTab
                                  // Mas o botão ainda existe aqui (pode ser usado)
                                  onAssetUpdate(asset); // Re-usa o onAssetUpdate
                                },
                              ),
                            ),
                            if (totalPages > 1)
                              _buildPagination(currentPage, totalPages, onPageChange),
                          ],
                        ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPagination(
      int currentPage, int totalPages, Function(int) onPageChange) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: currentPage > 1 ? () => onPageChange(-1) : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Página $currentPage de $totalPages',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: currentPage < totalPages ? () => onPageChange(1) : null,
          ),
        ],
      ),
    );
  }
}