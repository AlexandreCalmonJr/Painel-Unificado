// File: lib/devices/widgets/managed_devices_card.dart
// MIGRADO PARA USAR BaseDataTable MANTENDO NOMES ORIGINAIS DAS COLUNAS

import 'dart:convert';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:painel_windowns/devices/device_detail_screen.dart';
import 'package:painel_windowns/devices/utils/helpers.dart';
import 'package:painel_windowns/devices/widgets/command_controls_v2.dart';
import 'package:painel_windowns/models/device.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/widgets/common/index.dart';
import 'package:path_provider/path_provider.dart';

class ManagedDevicesCard extends StatelessWidget {
  final String title;
  final List<Device> devices;
  final bool showActions;
  final String? token;
  final VoidCallback? onDeviceUpdate;
  final Map<String, dynamic>? currentUser;
  final AuthService authService;
  final bool expand;

  const ManagedDevicesCard({
    required this.authService,
    super.key,
    required this.title,
    required this.devices,
    this.showActions = false,
    this.token,
    this.onDeviceUpdate,
    this.currentUser,
    this.expand = false,
  });

  Future<void> _downloadDevicesCsv(
    BuildContext context,
    List<Device> devicesToExport,
  ) async {
    final headers = [
      'Dispositivo',
      'Modelo',
      'IMEI',
      'Serial',
      'Status',
      'Última Sincronização',
      'Bateria',
      'Endereço IP',
      'Rede',
      'Endereço MAC',
      'Em Manutenção',
      'Chamado',
      'Motivo da Manutenção',
      'Unidade',
      'Setor',
      'Andar',
    ];

    final rows =
        devicesToExport.map((device) {
          final lastSeenTime = parseLastSeen(device.lastSeen);
          String status;

          switch (device.displayStatus) {
            case DeviceStatusType.collectedByIT:
              status = 'Recolhido pelo TI';
              break;
            case DeviceStatusType.maintenance:
              status = 'Em Manutenção';
              break;
            case DeviceStatusType.online:
              status = 'Online';
              break;
            case DeviceStatusType.unmonitored:
              status = 'Sem Monitorar';
              break;
            default:
              status = 'Offline';
              break;
          }

          return [
                device.deviceName,
                device.deviceModel ?? 'N/A',
                device.imei ?? 'N/A',
                device.serialNumber ?? 'N/A',
                status,
                formatDateTime(lastSeenTime),
                device.battery != null ? '${device.battery}%' : 'N/A',
                device.ipAddress ?? 'N/A',
                device.network ?? 'N/A',
                device.macAddress ?? 'N/A',
                (device.maintenanceStatus ?? false) ? 'Sim' : 'Não',
                device.maintenanceTicket ?? 'N/A',
                device.maintenanceReason ?? 'N/A',
                device.unit ?? 'N/A',
                device.sector ?? 'N/A',
                device.floor ?? 'N/A',
              ]
              .map((value) => '"${value.toString().replaceAll('"', '""')}"')
              .join(',');
        }).toList();

    final csvContent = [headers.join(','), ...rows].join('\n');
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'dispositivos_$timestamp.csv';

    try {
      if (kIsWeb) {
        final bytes = Uint8List.fromList(utf8.encode(csvContent));
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: 'csv',
          mimeType: MimeType.csv,
        );
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('CSV baixado com sucesso!')),
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}${Platform.pathSeparator}$fileName';
        final file = File(path);
        await file.writeAsString(csvContent);

        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('CSV salvo em: $path')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Device> filteredDevices = List.from(devices);

    filteredDevices.sort((a, b) {
      int getPriority(Device device) {
        if (device.displayStatus == DeviceStatusType.unmonitored) return 0;
        return 1;
      }

      final priorityA = getPriority(a);
      final priorityB = getPriority(b);

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      return (a.deviceName ?? '').toLowerCase().compareTo(
        (b.deviceName ?? '').toLowerCase(),
      );
    });

    return BaseCard(
      title: title,
      expandChild: expand,
      actions: [
        ElevatedButton.icon(
          onPressed: () => _downloadDevicesCsv(context, filteredDevices),
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Baixar CSV'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
      subtitle:
          currentUser != null && currentUser!['role'] == 'user'
              ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Filtrado por: ${currentUser!['sector']} | Dispositivos visíveis: ${filteredDevices.length}',
                  style: TextStyle(color: Colors.blue[700], fontSize: 12),
                ),
              )
              : null,
      child: BaseDataTable<Device>(
        items: filteredDevices,
        columns: [
          DataTableColumn<Device>(
            label: 'Dispositivo', // Nome original mantido
            builder:
                (device) => InkWell(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DeviceDetailScreen(
                                device: device,
                                authService: authService,
                              ),
                        ),
                      ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              device.deviceName ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (device.battery != null)
                              Text(
                                'Bateria: ${device.battery}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      BatteryIcon(batteryLevel: device.battery, size: 18),
                    ],
                  ),
                ),
          ),
          DataTableColumn<Device>(
            label: 'Modelo', // Nome original mantido
            value: (device) => device.deviceModel ?? 'N/A',
          ),
          DataTableColumn<Device>(
            label: 'Serial', // Nome original mantido
            value: (device) => device.serialNumber ?? 'N/A',
          ),
          DataTableColumn<Device>(
            label: 'IMEI', // Nome original mantido
            value: (device) => device.imei ?? 'N/A',
          ),
          DataTableColumn<Device>(
            label: 'Status', // Nome original mantido
            builder: (device) {
              String statusText;
              switch (device.displayStatus) {
                case DeviceStatusType.collectedByIT:
                  statusText = 'collected';
                  break;
                case DeviceStatusType.maintenance:
                  statusText = 'maintenance';
                  break;
                case DeviceStatusType.online:
                  statusText = 'online';
                  break;
                case DeviceStatusType.unmonitored:
                  statusText = 'unmonitored';
                  break;
                default:
                  statusText = 'offline';
                  break;
              }
              return StatusChip(
                status: statusText,
                type: StatusType.device,
                isCompact: true,
              );
            },
          ),
          DataTableColumn<Device>(
            label: 'Última Sincronização', // Nome original mantido
            value: (device) => formatDateTime(parseLastSeen(device.lastSeen)),
          ),
          DataTableColumn<Device>(
            label: 'Unidade', // Nome original mantido
            value: (device) => device.unit ?? 'N/D',
          ),
          DataTableColumn<Device>(
            label: 'Setor/Andar', // Nome original mantido
            value:
                (device) =>
                    '${device.sector ?? "N/D"} / ${device.floor ?? "N/D"}',
          ),
        ],
        actions:
            showActions
                ? [
                  TableAction<Device>(
                    icon: Icons.more_vert,
                    label: 'Ações',
                    onTap:
                        (device) {}, // Placeholder, menu é renderizado abaixo
                  ),
                ]
                : null,
        customRow:
            showActions
                ? (device) => CommandControlsV2(
                  device: device,
                  token: token!,
                  onCommandExecuted: onDeviceUpdate,
                )
                : null,
        showPagination: false,
      ),
    );
  }
}
