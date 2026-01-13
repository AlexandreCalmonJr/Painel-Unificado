import 'package:flutter/material.dart';
import 'package:painel_windowns/data/models/device_model.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/managed_assets_card.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/device_table_columns.dart';
import 'package:painel_windowns/presentation/shared/widgets/controls/unified_command_controls.dart';
import 'package:painel_windowns/services/auth_service.dart';

class MaintenanceTab extends StatelessWidget {
  const MaintenanceTab({
    required this.devices,
    required this.token,
    required this.onDeviceUpdate,
    required this.currentUser,
    required this.authService,
    super.key,
  });
  final List<Device> devices;
  final String token;
  final VoidCallback onDeviceUpdate;
  final Map<String, dynamic>? currentUser;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    // A filtragem principal (por status de manutenção) acontece aqui.
    // A filtragem secundária (por setor do usuário) acontecerá dentro do ManagedAssetsCard.
    final maintenanceDevices =
        devices.where((d) => d.maintenanceStatus ?? false).toList();
    final columns = buildDeviceTableColumns(authService);
    final config = buildDeviceCardConfig(context, authService);

    return ManagedAssetsCard<Device>(
      title: 'Dispositivos em Manutenção',
      items: maintenanceDevices,
      columns: columns,
      config: config,
      showActions: true,
      onItemUpdate: onDeviceUpdate,
      currentUser: currentUser,
      actions:
          (device) => UnifiedCommandControls<Device>(
            item: device,
            authService: authService,
            token: token,
            onCommandExecuted: onDeviceUpdate,
            config: CommandConfig<Device>(
              getSerialNumber: (d) => d.serialNumber,
            ),
          ),
    );
  }
}
