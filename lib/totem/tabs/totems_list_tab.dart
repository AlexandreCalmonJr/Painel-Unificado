import 'package:flutter/material.dart';
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/totem/widgets/managed_devices_card.dart';


/// Widget que exibe a aba de listagem de totens
class TotemsListTab extends StatelessWidget {
  final List<Totem> totems;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChange;
  final Function(String) onSearch;
  final VoidCallback onRefresh;
  final AuthService authService;

  const TotemsListTab({
    super.key,
    required this.totems,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
    required this.onSearch,
    required this.onRefresh,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: onSearch,
          decoration: InputDecoration(
            labelText: 'Pesquisar por Hostname, Serial, IP ou Localização',
            suffixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: isLoading && totems.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ManagedTotemsCard(
                  title: 'Totens Gerenciados (${totems.length})',
                  totems: totems,
                  authService: authService,
                  onTotemUpdate: onRefresh,
                ),
        ),
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: currentPage > 1 ? () => onPageChange(-1) : null,
                ),
                Text('Página $currentPage de $totalPages'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed:
                      currentPage < totalPages ? () => onPageChange(1) : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}