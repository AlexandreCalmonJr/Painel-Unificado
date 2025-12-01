// Unified devices_tab.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:painel_windowns/devices/widgets/managed_devices_card.dart';
import 'package:painel_windowns/models/device.dart';
import 'package:painel_windowns/services/auth_service.dart';

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
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              decoration: InputDecoration(
                labelText: 'Buscar dispositivos',
                labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                hintText: 'Nome, serial, IMEI...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 20,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearch('');
                          },
                          tooltip: 'Limpar busca',
                        )
                        : null,
                border: InputBorder.none,
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
            expand: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed:
                    widget.currentPage > 1
                        ? () => widget.onPageChange(-1)
                        : null,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('Anterior'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Página ${widget.currentPage} de ${widget.totalPages}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed:
                    widget.currentPage < widget.totalPages
                        ? () => widget.onPageChange(1)
                        : null,
                icon: const Icon(Icons.chevron_right, size: 18),
                label: const Text('Próxima'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  // Icon on the right
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
