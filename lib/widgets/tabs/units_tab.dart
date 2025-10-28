// File: lib/widgets/units_tab.dart
import 'dart:io';

import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/screen/unit_bssids_page.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/utils/helpers.dart';
import 'package:path_provider/path_provider.dart';


class UnitsTab extends StatefulWidget {
  final List<Unit> units;
  final List<BssidMapping> bssidMappings;
  final String token;
  final AuthService authService;
  final VoidCallback onDataUpdate;

  const UnitsTab({
    super.key,
    required this.units,
    required this.bssidMappings,
    required this.token,
    required this.authService,
    required this.onDataUpdate,
  });

  @override
  State<UnitsTab> createState() => _UnitsTabState();
}

class _UnitsTabState extends State<UnitsTab> {
  final DeviceService _deviceService = DeviceService();

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

  bool get _isAdmin => widget.authService.isAdmin;

  // --- FUNÇÃO _showUnitDialog TOTALMENTE REFEITA ---
  /// Mostra um diálogo para criar ou atualizar uma Unidade,
  /// agora com gerenciamento dinâmico de múltiplas faixas de IP.
  void _showUnitDialog({Unit? unit}) {
    if (!_isAdmin) {
      _showSnackbar('Acesso negado. Contate o administrador.', isError: true);
      return;
    }

    final isEditing = unit != null;
    final nameController = TextEditingController(text: unit?.name);

    // Lista para gerenciar os controllers das faixas de IP
    List<Map<String, TextEditingController>> ipRangeControllers = [];

    // Se estiver editando, popula a lista com as faixas existentes
    if (isEditing && unit.ipRanges.isNotEmpty) {
      for (var range in unit.ipRanges) {
        ipRangeControllers.add({
          'start': TextEditingController(text: range.start),
          'end': TextEditingController(text: range.end),
        });
      }
    } else {
      // Se for novo ou não tiver faixas, começa com uma em branco
      ipRangeControllers.add({
        'start': TextEditingController(),
        'end': TextEditingController(),
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        // Usa StatefulBuilder para permitir que o diálogo se atualize
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit : Icons.add, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(isEditing ? 'Editar Unidade' : 'Adicionar Unidade'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome da Unidade',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.home),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Faixas de IP',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    // Lista dinâmica de faixas de IP
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ipRangeControllers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: ipRangeControllers[index]['start'],
                                  decoration: InputDecoration(
                                    labelText: 'IP Inicial',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: ipRangeControllers[index]['end'],
                                  decoration: InputDecoration(
                                    labelText: 'IP Final',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              // Botão de remover (só aparece se houver > 1 faixa)
                              if (ipRangeControllers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () {
                                    setDialogState(() {
                                      ipRangeControllers.removeAt(index);
                                    });
                                  },
                                )
                              else
                                // Espaçador para alinhar
                                const SizedBox(width: 48),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Botão para adicionar nova faixa
                    TextButton.icon(
                      icon: const Icon(Icons.add, color: Colors.green),
                      label: const Text('Adicionar Faixa de IP'),
                      onPressed: () {
                        setDialogState(() {
                          ipRangeControllers.add({
                            'start': TextEditingController(),
                            'end': TextEditingController(),
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      _showSnackbar('O nome da unidade é obrigatório.',
                          isError: true);
                      return;
                    }

                    List<IpRange> ipRangesList = [];
                    // Validação das faixas de IP
                    for (var controllers in ipRangeControllers) {
                      final startIp = controllers['start']!.text.trim();
                      final endIp = controllers['end']!.text.trim();

                      if (startIp.isEmpty || endIp.isEmpty) {
                        _showSnackbar(
                            'Todas as faixas de IP devem ser preenchidas.',
                            isError: true);
                        return;
                      }
                      if (!isValidIp(startIp) || !isValidIp(endIp)) {
                        _showSnackbar(
                            'IP inválido na faixa: $startIp - $endIp.',
                            isError: true);
                        return;
                      }
                      // (Validação de start < end pode ser adicionada aqui)
                      ipRangesList.add(IpRange(start: startIp, end: endIp));
                    }

                     if (ipRangesList.isEmpty) {
                       _showSnackbar('Adicione pelo menos uma faixa de IP.',
                          isError: true);
                       return;
                    }

                    try {
                      final newUnit =
                          Unit(name: name, ipRanges: ipRangesList);
                      if (isEditing) {
                        await _deviceService.updateUnit(
                            widget.token, unit.name, newUnit);
                        _showSnackbar('Unidade atualizada!');
                      } else {
                        await _deviceService.createUnit(widget.token, newUnit);
                        _showSnackbar('Unidade criada!');
                      }
                      Navigator.of(context).pop();
                      widget.onDataUpdate();
                    } catch (e) {
                      _showSnackbar('Erro ao salvar: $e', isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child:
                      const Text('Salvar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // A função _showBssidMappingDialog permanece a mesma
  // (Ela já foi atualizada para incluir 'unitName' na sua cópia anterior)
  void _showBssidMappingDialog({BssidMapping? mapping}) {
    if (!_isAdmin) {
      _showSnackbar('Acesso negado. Contate o administrador.', isError: true);
      return;
    }

    final isEditing = mapping != null;
    final macController = TextEditingController(text: mapping?.macAddressRadio);
    final sectorController = TextEditingController(text: mapping?.sector);
    final floorController = TextEditingController(text: mapping?.floor);
    final unitNameController = TextEditingController(text: mapping?.unitName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isEditing ? Icons.edit_location : Icons.add_location_alt,
                color: Colors.blue),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.wifi),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sectorController,
              decoration: InputDecoration(
                labelText: 'Setor',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: floorController,
              decoration: InputDecoration(
                labelText: 'Andar',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.layers),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: unitNameController,
              decoration: InputDecoration(
                labelText: 'Nome da Unidade (Opcional)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.home_work),
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
              final mac =
                  macController.text.trim().toUpperCase().replaceAll('-', ':');
              final sector = sectorController.text.trim();
              final floor = floorController.text.trim();
              final unitName = unitNameController.text.trim();

              if (mac.isEmpty || sector.isEmpty || floor.isEmpty) {
                _showSnackbar('Campos MAC, Setor e Andar são obrigatórios.',
                    isError: true);
                return;
              }
              if (!RegExp(r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$').hasMatch(mac)) {
                _showSnackbar('MAC inválido.', isError: true);
                return;
              }

              try {
                final newMapping = BssidMapping(
                    macAddressRadio: mac,
                    sector: sector,
                    floor: floor,
                    unitName: unitName);
                if (isEditing) {
                  await _deviceService.updateBssidMapping(
                      widget.token, mapping.macAddressRadio, newMapping);
                  _showSnackbar('Mapeamento atualizado!');
                } else {
                  await _deviceService.createBssidMapping(
                      widget.token, newMapping);
                  _showSnackbar('Mapeamento criado!');
                }
                Navigator.of(context).pop();
                widget.onDataUpdate();
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

  // _deleteUnit e _deleteBssidMapping permanecem os mesmos
  void _deleteUnit(Unit unit) {
    if (!_isAdmin) {
      _showSnackbar('Acesso negado. Contate o administrador.', isError: true);
      return;
    }

    showDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _deviceService.deleteUnit(widget.token, unit.name);
                _showSnackbar('Unidade excluída!');
                Navigator.of(context).pop();
                widget.onDataUpdate();
              } catch (e) {
                _showSnackbar('Erro ao excluir: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteBssidMapping(BssidMapping mapping) {
    if (!_isAdmin) {
      _showSnackbar('Acesso negado. Contate o administrador.', isError: true);
      return;
    }

    showDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _deviceService.deleteBssidMapping(
                    widget.token, mapping.macAddressRadio);
                _showSnackbar('Mapeamento excluído!');
                Navigator.of(context).pop();
                widget.onDataUpdate();
              } catch (e) {
                _showSnackbar('Erro ao excluir: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- AJUSTE NA IMPORTAÇÃO/EXPORTAÇÃO ---
  Future<void> _importData() async {
    if (!_isAdmin) {
      _showSnackbar('Acesso negado. Contate o administrador.', isError: true);
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null) return;

    try {
      final bytes = result.files.single.bytes!;
      final excel = xls.Excel.decodeBytes(bytes);

      int importedUnits = 0;
      int importedBssids = 0;

      // Processa aba "Units"
      var unitsSheet = excel.tables['Units'];
      if (unitsSheet != null) {
        for (int row = 1; row < unitsSheet.maxRows; row++) {
          final name = unitsSheet
              .cell(xls.CellIndex.indexByString('A$row'))
              .value
              ?.toString()
              .trim();
          final startIp = unitsSheet
              .cell(xls.CellIndex.indexByString('B$row'))
              .value
              ?.toString()
              .trim();
          final endIp = unitsSheet
              .cell(xls.CellIndex.indexByString('C$row'))
              .value
              ?.toString()
              .trim();

          if (name == null ||
              startIp == null ||
              endIp == null ||
              name.isEmpty) {
            continue;
          }

          if (!isValidIp(startIp) || !isValidIp(endIp)) {
            _showSnackbar('IP inválido na linha $row (Units). Pulando.',
                isError: true);
            continue;
          }

          try {
            // AJUSTE: Cria a lista de IpRange
            final ipRange = IpRange(start: startIp, end: endIp);
            final newUnit = Unit(name: name, ipRanges: [ipRange]);

            await _deviceService.createUnit(widget.token, newUnit);
            importedUnits++;
          } catch (e) {
            _showSnackbar('Erro ao importar unidade "$name": $e',
                isError: true);
          }
        }
      }

      // Processa aba "BSSID_Mappings"
      var bssidSheet = excel.tables['BSSID_Mappings'];
      if (bssidSheet != null) {
        for (int row = 1; row < bssidSheet.maxRows; row++) {
          final mac = bssidSheet
              .cell(xls.CellIndex.indexByString('A$row'))
              .value
              ?.toString()
              .trim()
              .toUpperCase()
              .replaceAll('-', ':');
          final sector = bssidSheet
              .cell(xls.CellIndex.indexByString('B$row'))
              .value
              ?.toString()
              .trim();
          final floor = bssidSheet
              .cell(xls.CellIndex.indexByString('C$row'))
              .value
              ?.toString()
              .trim();
          // AJUSTE: Importa o unitName se ele existir na coluna D
          final unitName = bssidSheet
              .cell(xls.CellIndex.indexByString('D$row'))
              .value
              ?.toString()
              .trim() ?? '';

          if (mac == null ||
              sector == null ||
              floor == null ||
              mac.isEmpty ||
              !RegExp(r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$').hasMatch(mac)) {
            continue;
          }

          try {
            final newMapping = BssidMapping(
                macAddressRadio: mac,
                sector: sector,
                floor: floor,
                unitName: unitName);
            await _deviceService.createBssidMapping(widget.token, newMapping);
            importedBssids++;
          } catch (e) {
            _showSnackbar('Erro ao importar BSSID "$mac": $e', isError: true);
          }
        }
      }

      widget.onDataUpdate();
      _showSnackbar(
          'Importação concluída! $importedUnits unidades e $importedBssids mapeamentos adicionados.');
    } catch (e) {
      _showSnackbar('Erro na importação: $e', isError: true);
    }
  }

  Future<void> _showExportDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.download, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Exportar Dados'),
          ],
        ),
        content: const Text('Exportar unidades e mapeamentos para Excel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Exportar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final excel = xls.Excel.createExcel();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Aba Units
      var unitsSheet = excel['Units'];
      unitsSheet.appendRow(['Nome da Unidade', 'IP Inicial', 'IP Final']);
      for (var unit in widget.units) {
        // AJUSTE: Exporta apenas a primeira faixa de IP
        unitsSheet.appendRow([
          unit.name,
          unit.ipRanges.isNotEmpty ? unit.ipRanges.first.start : '',
          unit.ipRanges.isNotEmpty ? unit.ipRanges.first.end : ''
        ]);
      }

      // Aba BSSID_Mappings
      var bssidSheet = excel['BSSID_Mappings'];
      // AJUSTE: Adiciona a coluna UnitName
      bssidSheet
          .appendRow(['BSSID (MAC)', 'Setor', 'Andar', 'Nome da Unidade']);
      for (var mapping in widget.bssidMappings) {
        bssidSheet.appendRow([
          mapping.macAddressRadio,
          mapping.sector,
          mapping.floor,
          mapping.unitName
        ]);
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
        // ignore: unnecessary_null_comparison
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

  // _buildActionButtons permanece o mesmo
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton.icon(
            onPressed: _isAdmin ? () => _showUnitDialog() : null,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Adicionar Unidade'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAdmin ? Colors.blue : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isAdmin ? () => _showBssidMappingDialog() : null,
            icon: const Icon(Icons.add_location_alt, color: Colors.white),
            label: const Text('Adicionar Mapeamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAdmin ? Colors.blue : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isAdmin ? _importData : null,
            icon: const Icon(Icons.upload_file, color: Colors.white),
            label: const Text('Importar Dados'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAdmin ? Colors.orange : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showExportDialog,
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text('Exportar Dados'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- AJUSTE NA LISTA DE UNIDADES (PARA NAVEGAÇÃO) ---
  Widget _buildUnitsList() {
    if (widget.units.isEmpty) {
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
            title: const Text('Unidades (Faixas de IP)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text('${widget.units.length} itens'),
          ),
          ...widget.units.map((unit) => ListTile(
                leading: const Icon(Icons.router, color: Colors.grey),
                title: Text(unit.name),
                // AJUSTE: Mostra a primeira faixa de IP ou um contador
                subtitle: Text(
                  unit.ipRanges.isEmpty
                      ? 'Nenhuma faixa de IP'
                      : (unit.ipRanges.length == 1
                          ? '${unit.ipRanges.first.start} - ${unit.ipRanges.first.end}'
                          : '${unit.ipRanges.length} faixas de IP cadastradas'),
                ),
                // AJUSTE: Adiciona onTap para navegar
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UnitBssidsPage(
                        unit: unit,
                        authService: widget.authService,
                      ),
                    ),
                  // Recarrega os dados quando voltar da página de BSSIDs
                  ).then((_) => widget.onDataUpdate());
                },
                trailing: _isAdmin
                    ? PopupMenuButton<IconData>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == Icons.edit) {
                            _showUnitDialog(unit: unit);
                          } else if (value == Icons.delete) {
                            _deleteUnit(unit);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: Icons.edit,
                              child: Row(children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Editar')
                              ])),
                          const PopupMenuItem(
                              value: Icons.delete,
                              child: Row(children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir')
                              ])),
                        ],
                      )
                    : null,
              )),
        ],
      ),
    );
  }

  // _buildBssidList (agora é a lista "geral")
  Widget _buildBssidList() {
    if (widget.bssidMappings.isEmpty) {
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
            title: const Text('Todos Mapeamentos de BSSID (Setor/Andar)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text('${widget.bssidMappings.length} itens'),
          ),
          ...widget.bssidMappings.map((mapping) => ListTile(
                leading: const Icon(Icons.wifi, color: Colors.grey),
                title: Text(mapping.macAddressRadio),
                 // AJUSTE: Mostra o unitName se ele existir
                subtitle:
                    Text('${mapping.unitName.isNotEmpty ? "${mapping.unitName} - " : ""}${mapping.sector} - ${mapping.floor}'),
                trailing: _isAdmin
                    ? PopupMenuButton<IconData>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == Icons.edit) {
                            _showBssidMappingDialog(mapping: mapping);
                          } else if (value == Icons.delete) {
                            _deleteBssidMapping(mapping);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: Icons.edit,
                              child: Row(children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Editar')
                              ])),
                          const PopupMenuItem(
                              value: Icons.delete,
                              child: Row(children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir')
                              ])),
                        ],
                      )
                    : null,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings, color: Colors.blue, size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            'Gerenciamento de Unidades e Localização',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
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
