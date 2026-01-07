import 'package:flutter/material.dart';
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/totem/widgets/managed_devices_card.dart';

/// Widget que exibe a aba de listagem de totens
class TotemsListTab extends StatefulWidget {
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
  State<TotemsListTab> createState() => _TotemsListTabState();
}

class _TotemsListTabState extends State<TotemsListTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearch,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
                labelText: 'Buscar totens',
                labelStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                hintText: 'Hostname, Serial, IP ou Localização...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search,
                    color: Colors.blue[600],
                    size: 22,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearch('');
                        },
                        tooltip: 'Limpar busca',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.blue[400]!,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: widget.isLoading && widget.totems.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ManagedTotemsCard(
                  title: 'Totens Gerenciados (${widget.totems.length})',
                  totems: widget.totems,
                  authService: widget.authService,
                  onTotemUpdate: widget.onRefresh,
                ),
        ),
        if (widget.totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.currentPage > 1
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: widget.currentPage > 1
                            ? Colors.blue[600]
                            : Colors.grey[400],
                        size: 20,
                      ),
                    ),
                    onPressed: widget.currentPage > 1
                        ? () => widget.onPageChange(-1)
                        : null,
                    tooltip: 'Página anterior',
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Página ${widget.currentPage} de ${widget.totalPages}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.currentPage < widget.totalPages
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: widget.currentPage < widget.totalPages
                            ? Colors.blue[600]
                            : Colors.grey[400],
                        size: 20,
                      ),
                    ),
                    onPressed: widget.currentPage < widget.totalPages
                        ? () => widget.onPageChange(1)
                        : null,
                    tooltip: 'Próxima página',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}