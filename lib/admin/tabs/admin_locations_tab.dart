// File: lib/admin/tabs/admin_locations_tab.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/utils/helpers.dart';
import 'package:path_provider/path_provider.dart';

class AdminLocationsTab extends StatefulWidget {
  final AuthService authService;
  const AdminLocationsTab({super.key, required this.authService});

  @override
  State<AdminLocationsTab> createState() => _AdminLocationsTabState();
}

class _AdminLocationsTabState extends State<AdminLocationsTab> {
  final DeviceService _deviceService = DeviceService();
  List<Unit> units = [];
  List<BssidMapping> bssidMappings = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final token = widget.authService.currentToken ?? '';
      if (token.isEmpty) {
        _showSnackbar('Token inválido. Faça login novamente.', isError: true);
        return;
      }
      units = await _deviceService.fetchUnits(token);
      bssidMappings = await _deviceService.fetchBssidMappings(token);
    } catch (e) {
      _showSnackbar('Erro ao carregar dados: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _createOrUpdateUnit(Unit? unit) async {
    final isEditing = unit != null;
    final nameController = TextEditingController(text: unit?.name);
    final startIpController = TextEditingController(text: unit?.ipRangeStart);
    final endIpController = TextEditingController(text: unit?.ipRangeEnd);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isEditing ? Icons.edit : Icons.add, color: Colors.blue),
            const SizedBox(width: 8),
            Text(isEditing ? 'Editar Unidade' : 'Adicionar Unidade'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome da Unidade',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: startIpController,
              decoration: InputDecoration(
                labelText: 'IP Inicial (ex: 192.168.1.1)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.start),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: endIpController,
              decoration: InputDecoration(
                labelText: 'IP Final (ex: 192.168.1.254)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.stop),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final startIp = startIpController.text.trim();
              final endIp = endIpController.text.trim();

              if (name.isEmpty || startIp.isEmpty || endIp.isEmpty) {
                _showSnackbar('Todos os campos são obrigatórios.', isError: true);
                return;
              }
              if (!isValidIp(startIp) || !isValidIp(endIp)) {
                _showSnackbar('IPs inválidos.', isError: true);
                return;
              }

              try {
                final newUnit = Unit(name: name, ipRangeStart: startIp, ipRangeEnd: endIp);
                if (isEditing) {
                  await _deviceService.updateUnit(widget.authService.currentToken!, unit!.name, newUnit);
                  _showSnackbar('Unidade atualizada com sucesso!');
                } else {
                  await _deviceService.createUnit(widget.authService.currentToken!, newUnit);
                  _showSnackbar('Unidade criada com sucesso!');
                }
                Navigator.of(context).pop();
                _loadData();
              } catch (e) {
                _showSnackbar('Erro ao salvar: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _createOrUpdateBssidMapping(BssidMapping? mapping) async {
    final isEditing = mapping != null;
    final macController = TextEditingController(text: mapping?.macAddressRadio);
    final sectorController = TextEditingController(text: mapping?.sector);
    final floorController = TextEditingController(text: mapping?.floor);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isEditing ? Icons.edit_location : Icons.add_location_alt, color: Colors.blue),
            const SizedBox(width: 8),
            Text(isEditing ? 'Editar Mapeamento' : 'Adicionar Mapeamento'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: macController,
              decoration: InputDecoration(
                labelText: 'BSSID (MAC)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.wifi),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sectorController,
              decoration: InputDecoration(
                labelText: 'Setor',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: floorController,
              decoration: InputDecoration(
                labelText: 'Andar',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.layers),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final mac = macController.text.trim().toUpperCase().replaceAll('-', ':');
              final sector = sectorController.text.trim();
              final floor = floorController.text.trim();

              if (mac.isEmpty || sector.isEmpty || floor.isEmpty) {
                _showSnackbar('Todos os campos são obrigatórios.', isError: true);
                return;
              }
              if (!RegExp(r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$').hasMatch(mac)) {
                _showSnackbar('MAC inválido.', isError: true);
                return;
              }

              try {
                final newMapping = BssidMapping(macAddressRadio: mac, sector: sector, floor: floor);
                if (isEditing) {
                  await _deviceService.updateBssidMapping(widget.authService.currentToken!, mapping!.macAddressRadio, newMapping);
                  _showSnackbar('Mapeamento atualizado com sucesso!');
                } else {
                  await _deviceService.createBssidMapping(widget.authService.currentToken!, newMapping);
                  _showSnackbar('Mapeamento criado com sucesso!');
                }
                Navigator.of(context).pop();
                _loadData();
              } catch (e) {
                _showSnackbar('Erro ao salvar: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUnit(Unit unit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Confirmar Exclusão'),
          ],
        ),
        content: Text('Excluir unidade "${unit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _deviceService.deleteUnit(widget.authService.currentToken!, unit.name);
      _showSnackbar('Unidade excluída com sucesso!');
      _loadData();
    } catch (e) {
      _showSnackbar('Erro ao excluir: $e', isError: true);
    }
  }

  Future<void> _deleteBssidMapping(BssidMapping mapping) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Confirmar Exclusão'),
          ],
        ),
        content: Text('Excluir mapeamento para "${mapping.macAddressRadio}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _deviceService.deleteBssidMapping(widget.authService.currentToken!, mapping.macAddressRadio);
      _showSnackbar('Mapeamento excluído com sucesso!');
      _loadData();
    } catch (e) {
      _showSnackbar('Erro ao excluir: $e', isError: true);
    }
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null) return;

    setState(() => isLoading = true);
    try {
      final bytes = result.files.single.bytes!;
      final excel = xls.Excel.decodeBytes(bytes);

      int importedUnits = 0;
      int importedBssids = 0;

      // Processa aba "Units"
      var unitsSheet = excel.tables['Units'];
      if (unitsSheet != null) {
        for (int row = 1; row < unitsSheet.maxRows; row++) {
          final name = unitsSheet.cell(xls.CellIndex.indexByString('A$row')).value?.toString().trim();
          final startIp = unitsSheet.cell(xls.CellIndex.indexByString('B$row')).value?.toString().trim();
          final endIp = unitsSheet.cell(xls.CellIndex.indexByString('C$row')).value?.toString().trim();

          if (name == null || startIp == null || endIp == null || name.isEmpty) continue;

          if (!isValidIp(startIp) || !isValidIp(endIp)) {
            _showSnackbar('IP inválido na linha $row (Units). Pulando.', isError: true);
            continue;
          }

          try {
            final newUnit = Unit(name: name, ipRangeStart: startIp, ipRangeEnd: endIp);
            await _deviceService.createUnit(widget.authService.currentToken!, newUnit);
            importedUnits++;
          } catch (e) {
            _showSnackbar('Erro ao importar unidade "$name": $e', isError: true);
          }
        }
      }

      // Processa aba "BSSID_Mappings"
      var bssidSheet = excel.tables['BSSID_Mappings'];
      if (bssidSheet != null) {
        for (int row = 1; row < bssidSheet.maxRows; row++) {
          final mac = bssidSheet.cell(xls.CellIndex.indexByString('A$row')).value?.toString().trim().toUpperCase().replaceAll('-', ':');
          final sector = bssidSheet.cell(xls.CellIndex.indexByString('B$row')).value?.toString().trim();
          final floor = bssidSheet.cell(xls.CellIndex.indexByString('C$row')).value?.toString().trim();

          if (mac == null || sector == null || floor == null || mac.isEmpty || !RegExp(r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$').hasMatch(mac)) continue;

          try {
            final newMapping = BssidMapping(macAddressRadio: mac, sector: sector, floor: floor);
            await _deviceService.createBssidMapping(widget.authService.currentToken!, newMapping);
            importedBssids++;
          } catch (e) {
            _showSnackbar('Erro ao importar BSSID "$mac": $e', isError: true);
          }
        }
      }

      await _loadData();
      _showSnackbar('Importação concluída! $importedUnits unidades e $importedBssids mapeamentos adicionados.');
    } catch (e) {
      _showSnackbar('Erro na importação: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _exportData() async {
    try {
      final excel = xls.Excel.createExcel();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Aba Units
      var unitsSheet = excel['Units'];
      unitsSheet.appendRow(['Nome da Unidade', 'IP Inicial', 'IP Final']);
      for (var unit in units) {
        unitsSheet.appendRow([unit.name, unit.ipRangeStart, unit.ipRangeEnd]);
      }

      // Aba BSSID_Mappings
      var bssidSheet = excel['BSSID_Mappings'];
      bssidSheet.appendRow(['BSSID (MAC)', 'Setor', 'Andar']);
      for (var mapping in bssidMappings) {
        bssidSheet.appendRow([mapping.macAddressRadio, mapping.sector, mapping.floor]);
      }

      final encodedBytes = excel.encode()!;
      final bytes = Uint8List.fromList(encodedBytes);
      final fileName = 'mapeamentos_$timestamp.xlsx';

      if (kIsWeb) {
        final result = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: 'xlsx',
          mimeType: MimeType.microsoftExcel,
        );
        if (result != null) {
          _showSnackbar('Exportação concluída! Baixado: $fileName');
        } else {
          _showSnackbar('Falha no download.', isError: true);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(bytes);
        _showSnackbar('Exportação salva em: $path');
      }
    } catch (e) {
      _showSnackbar('Erro na exportação: $e', isError: true);
    }
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton.icon(
            onPressed: () => _createOrUpdateUnit(null),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Adicionar Unidade'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _createOrUpdateBssidMapping(null),
            icon: const Icon(Icons.add_location_alt, color: Colors.white),
            label: const Text('Adicionar Mapeamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _importData,
            icon: const Icon(Icons.upload_file, color: Colors.white),
            label: const Text('Importar Dados'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _exportData,
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text('Exportar Dados'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsList() {
    if (units.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.grey),
          title: const Text('Nenhuma unidade cadastrada'),
          subtitle: const Text('Adicione uma unidade para começar.'),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('Unidades (Faixas de IP)', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text('${units.length} itens'),
          ),
          ...units.map((unit) => ListTile(
                leading: const Icon(Icons.router, color: Colors.grey),
                title: Text(unit.name),
                subtitle: Text('${unit.ipRangeStart} - ${unit.ipRangeEnd}'),
                trailing: PopupMenuButton<IconData>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == Icons.edit) {
                      _createOrUpdateUnit(unit);
                    } else if (value == Icons.delete) {
                      _deleteUnit(unit);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: Icons.edit, child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Editar')])),
                    const PopupMenuItem(value: Icons.delete, child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Excluir')])),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBssidList() {
    if (bssidMappings.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.location_off, color: Colors.grey),
          title: const Text('Nenhum mapeamento cadastrado'),
          subtitle: const Text('Adicione um mapeamento para começar.'),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.map, color: Colors.blue),
            title: const Text('Mapeamentos de BSSID (Setor/Andar)', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text('${bssidMappings.length} itens'),
          ),
          ...bssidMappings.map((mapping) => ListTile(
                leading: const Icon(Icons.wifi, color: Colors.grey),
                title: Text(mapping.macAddressRadio),
                subtitle: Text('${mapping.sector} - ${mapping.floor}'),
                trailing: PopupMenuButton<IconData>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == Icons.edit) {
                      _createOrUpdateBssidMapping(mapping);
                    } else if (value == Icons.delete) {
                      _deleteBssidMapping(mapping);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: Icons.edit, child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Editar')])),
                    const PopupMenuItem(value: Icons.delete, child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Excluir')])),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.blue.shade50],
        ),
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.blue, size: 28),
                                const SizedBox(width: 8),
                                const Text(
                                  'Gerenciamento de Localizações',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildUnitsList(),
                    const SizedBox(height: 16),
                    _buildBssidList(),
                  ],
                ),
              ),
      ),
    );
  }
}