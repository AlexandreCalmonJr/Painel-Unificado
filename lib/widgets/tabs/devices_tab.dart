import 'dart:async';

import 'package:flutter/material.dart';
import 'package:painel_windowns/models/device.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/widgets/managed_devices_card.dart';

class DevicesTab extends StatefulWidget {
  final List<Device> devices;
  final String token;
  final VoidCallback onDeviceUpdate;
  final bool isReadOnly;
  final Map<String, dynamic>? currentUser;
  final AuthService authService;

  final int currentPage;
  final int totalPages;
  final Function(int) onPageChange;
  final Function(String) onSearch;

  const DevicesTab({
    required this.authService,
    super.key,
    required this.devices,
    required this.token,
    required this.onDeviceUpdate,
    required this.isReadOnly,
    required this.currentUser,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
    required this.onSearch,
  });

  @override
  State<DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
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
              style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              decoration: InputDecoration(
                labelText: 'Buscar dispositivos',
                labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                hintText: 'Nome, serial, IMEI...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.search, color: Colors.blue[600], size: 22),
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
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
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
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
          child: ManagedDevicesCard(
            title: 'Todos os Dispositivos',
            devices: widget.devices,
            authService: widget.authService,
            showActions: !widget.isReadOnly,
            token: widget.token,
            onDeviceUpdate: widget.onDeviceUpdate,
            currentUser: widget.currentUser,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed:
                    widget.currentPage > 1
                        ? () => widget.onPageChange(-1)
                        : null,
                child: const Text('Anterior'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Página ${widget.currentPage} de ${widget.totalPages}',
                ),
              ),
              ElevatedButton(
                onPressed:
                    widget.currentPage < widget.totalPages
                        ? () => widget.onPageChange(1)
                        : null,
                child: const Text('Próxima'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
