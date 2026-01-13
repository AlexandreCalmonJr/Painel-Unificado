// Unified devices_tab.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:painel_windowns/data/models/device_model.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/managed_assets_card.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/device_table_columns.dart';
import 'package:painel_windowns/presentation/shared/widgets/controls/unified_command_controls.dart';
import 'package:painel_windowns/services/auth_service.dart';

class DevicesTab extends StatefulWidget {
  const DevicesTab({
    required this.authService,
    required this.devices,
    required this.token,
    required this.onDeviceUpdate,
    required this.isReadOnly,
    required this.currentUser,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
    required this.onSearch,
    required Future<Null> Function() onRefresh,
    required Null Function(Device device) onDeviceTap,
    super.key,
  });
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
    final columns = buildDeviceTableColumns(widget.authService);
    final config = buildDeviceCardConfig(context, widget.authService);

    String? subtitle;
    if (widget.currentUser != null && widget.currentUser!['role'] == 'user') {
      subtitle =
          'Filtrado por: ${widget.currentUser!['sector']} | Dispositivos visíveis: ${widget.devices.length}';
    }

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
          child: ManagedAssetsCard<Device>(
            title: 'Todos os Dispositivos',
            items: widget.devices,
            columns: columns,
            config: config,
            showActions: !widget.isReadOnly,
            expand: true,
            onItemUpdate: widget.onDeviceUpdate,
            currentUser: widget.currentUser,
            subtitle: subtitle,
            actions:
                !widget.isReadOnly
                    ? (device) => UnifiedCommandControls<Device>(
                      item: device,
                      authService: widget.authService,
                      token: widget.token,
                      onCommandExecuted: widget.onDeviceUpdate,
                      config: CommandConfig<Device>(
                        getSerialNumber: (d) => d.serialNumber,
                      ),
                    )
                    : null,
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
