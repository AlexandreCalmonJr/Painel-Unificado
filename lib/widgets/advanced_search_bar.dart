// File: lib/widgets/advanced_search_bar.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/widgets/asset_search_filter.dart';


class AdvancedSearchBar extends StatefulWidget {
  final Function(AssetSearchFilter) onSearch;

  const AdvancedSearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  final _searchController = TextEditingController();
  String? _selectedStatus = 'Todos';
  String? _selectedUnit = 'Todas';
  String? _selectedSector = 'Todos';
  DateTimeRange? _dateRange;

  // ✅ MÉTODO ADICIONADO (PLACEHOLDER)
  List<String> _getAvailableUnits() {
    // Você deve buscar isso do seu provider/service
    return ['Todas', 'Unidade A', 'Unidade B', 'Unidade C'];
  }

  // ✅ MÉTODO ADICIONADO (PLACEHOLDER)
  List<String> _getAvailableSectors() {
    // Você deve buscar isso do seu provider/service
    return ['Todos', 'Setor 1', 'Setor 2', 'TI'];
  }

  // ✅ MÉTODO ADICIONADO
  void _applyFilters() {
    final filter = AssetSearchFilter(
      query: _searchController.text,
      status: _selectedStatus == 'Todos' ? null : _selectedStatus,
      unit: _selectedUnit == 'Todas' ? null : _selectedUnit,
      sector: _selectedSector == 'Todos' ? null : _selectedSector,
      dateRange: _dateRange,
    );
    widget.onSearch(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nome, serial, IP...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Todos', 'Online', 'Offline', 'Manutenção']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedStatus = value);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unidade',
                      border: OutlineInputBorder(),
                    ),
                    // ✅ CÓDIGO COMPLETADO
                    items: _getAvailableUnits()
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedUnit = value);
                      _applyFilters();
                    },
                  ),
                ),
                // ✅ ADICIONEI O FILTRO DE SETOR QUE FALTAVA
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSector,
                    decoration: const InputDecoration(
                      labelText: 'Setor',
                      border: OutlineInputBorder(),
                    ),
                    items: _getAvailableSectors()
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedSector = value);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}