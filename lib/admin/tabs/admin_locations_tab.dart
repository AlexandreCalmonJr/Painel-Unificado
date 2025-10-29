// File: lib/admin/tabs/admin_locations_tab.dart (VERSÃO MELHORADA)
import 'package:flutter/material.dart';
import 'package:painel_windowns/devices/utils/helpers.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/screen/unit_bssids_page.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';

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
  String searchQuery = '';
  String selectedTab = 'units'; // 'units' ou 'bssids'

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
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _createOrUpdateUnit(Unit? unit) async {
    final isEditing = unit != null;
    final nameController = TextEditingController(text: unit?.name);
    List<Map<String, TextEditingController>> ipRangeControllers = [];

    if (isEditing && unit.ipRanges.isNotEmpty) {
      for (var range in unit.ipRanges) {
        ipRangeControllers.add({
          'start': TextEditingController(text: range.start),
          'end': TextEditingController(text: range.end),
        });
      }
    } else {
      ipRangeControllers.add({
        'start': TextEditingController(),
        'end': TextEditingController(),
      });
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.add_business,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    isEditing ? 'Editar Unidade' : 'Nova Unidade',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome da Unidade',
                          hintText: 'Ex: Hospital Geral',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.home_work),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Faixas de IP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                          TextButton.icon(
                            icon: Icon(Icons.add_circle, size: 20),
                            label: Text('Adicionar Faixa'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
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
                      SizedBox(height: 12),
                      // Lista de faixas de IP
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: ipRangeControllers.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Faixa ${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                    Spacer(),
                                    if (ipRangeControllers.length > 1)
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                        ),
                                        color: Colors.red,
                                        onPressed: () {
                                          setDialogState(() {
                                            ipRangeControllers.removeAt(index);
                                          });
                                        },
                                        tooltip: 'Remover faixa',
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            ipRangeControllers[index]['start'],
                                        decoration: InputDecoration(
                                          labelText: 'IP Inicial',
                                          hintText: '192.168.0.1',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        size: 20,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            ipRangeControllers[index]['end'],
                                        decoration: InputDecoration(
                                          labelText: 'IP Final',
                                          hintText: '192.168.0.254',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      _showSnackbar(
                        'O nome da unidade é obrigatório.',
                        isError: true,
                      );
                      return;
                    }

                    List<IpRange> ipRangesList = [];
                    for (var controllers in ipRangeControllers) {
                      final startIp = controllers['start']!.text.trim();
                      final endIp = controllers['end']!.text.trim();

                      if (startIp.isEmpty || endIp.isEmpty) {
                        _showSnackbar(
                          'Todas as faixas de IP devem ser preenchidas.',
                          isError: true,
                        );
                        return;
                      }
                      if (!isValidIp(startIp) || !isValidIp(endIp)) {
                        _showSnackbar(
                          'IP inválido: $startIp - $endIp',
                          isError: true,
                        );
                        return;
                      }
                      ipRangesList.add(IpRange(start: startIp, end: endIp));
                    }

                    if (ipRangesList.isEmpty) {
                      _showSnackbar(
                        'Adicione pelo menos uma faixa de IP.',
                        isError: true,
                      );
                      return;
                    }

                    try {
                      final newUnit = Unit(name: name, ipRanges: ipRangesList);
                      if (isEditing) {
                        await _deviceService.updateUnit(
                          widget.authService.currentToken!,
                          unit.name,
                          newUnit,
                        );
                        _showSnackbar('Unidade atualizada com sucesso!');
                      } else {
                        await _deviceService.createUnit(
                          widget.authService.currentToken!,
                          newUnit,
                        );
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
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Salvar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createOrUpdateBssidMapping(BssidMapping? mapping) async {
    final isEditing = mapping != null;
    final macController = TextEditingController(text: mapping?.macAddressRadio);
    final sectorController = TextEditingController(text: mapping?.sector);
    final floorController = TextEditingController(text: mapping?.floor);
    final unitNameController = TextEditingController(text: mapping?.unitName);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isEditing ? Icons.edit_location : Icons.add_location_alt,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  isEditing ? 'Editar BSSID' : 'Novo BSSID',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: macController,
                    decoration: InputDecoration(
                      labelText: 'BSSID (Endereço MAC)',
                      hintText: 'AA:BB:CC:DD:EE:FF',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.wifi),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: sectorController,
                    decoration: InputDecoration(
                      labelText: 'Setor',
                      hintText: 'Ex: TI, Recepção',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.business),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: floorController,
                    decoration: InputDecoration(
                      labelText: 'Andar',
                      hintText: 'Ex: 2º Andar, Térreo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.layers),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: unitNameController,
                    decoration: InputDecoration(
                      labelText: 'Unidade (Opcional)',
                      hintText: 'Ex: Hospital Geral',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.home_work),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final mac = macController.text
                      .trim()
                      .toUpperCase()
                      .replaceAll('-', ':');
                  final sector = sectorController.text.trim();
                  final floor = floorController.text.trim();
                  final unitName = unitNameController.text.trim();

                  if (mac.isEmpty || sector.isEmpty || floor.isEmpty) {
                    _showSnackbar(
                      'BSSID, Setor e Andar são obrigatórios.',
                      isError: true,
                    );
                    return;
                  }
                  // Validação mais rigorosa
                  if (!RegExp(
                    r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$',
                  ).hasMatch(mac)) {
                    _showSnackbar(
                      'BSSID inválido. Formato: AA:BB:CC:DD:EE:FF',
                      isError: true,
                    );
                    return;
                  }

                  // ⚠️ ALERTA: BSSID genérico
                  if (mac == '02:00:00:00:00:00') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('BSSID Genérico Detectado'),
                            content: const Text(
                              'Este BSSID (02:00:00:00:00:00) é genérico e pode não identificar '
                              'corretamente a localização. Deseja continuar mesmo assim?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Continuar'),
                              ),
                            ],
                          ),
                    );
                    if (confirm != true) return;
                  }

                  try {
                    final newMapping = BssidMapping(
                      macAddressRadio: mac,
                      sector: sector,
                      floor: floor,
                      unitName: unitName,
                    );
                    if (isEditing) {
                      await _deviceService.updateBssidMapping(
                        widget.authService.currentToken!,
                        mapping.macAddressRadio,
                        newMapping,
                      );
                      _showSnackbar('BSSID atualizado com sucesso!');
                    } else {
                      await _deviceService.createBssidMapping(
                        widget.authService.currentToken!,
                        newMapping,
                      );
                      _showSnackbar('BSSID criado com sucesso!');
                    }
                    Navigator.of(context).pop();
                    _loadData();
                  } catch (e) {
                    _showSnackbar('Erro ao salvar: $e', isError: true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Salvar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteUnit(Unit unit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text('Confirmar Exclusão'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deseja realmente excluir a unidade:'),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    unit.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Esta ação não pode ser desfeita.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Excluir', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    try {
      await _deviceService.deleteUnit(
        widget.authService.currentToken!,
        unit.name,
      );
      _showSnackbar('Unidade excluída com sucesso!');
      _loadData();
    } catch (e) {
      _showSnackbar('Erro ao excluir: $e', isError: true);
    }
  }

  Future<void> _deleteBssidMapping(BssidMapping mapping) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text('Confirmar Exclusão'),
              ],
            ),
            content: Text('Excluir BSSID "${mapping.macAddressRadio}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Excluir', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    try {
      await _deviceService.deleteBssidMapping(
        widget.authService.currentToken!,
        mapping.macAddressRadio,
      );
      _showSnackbar('BSSID excluído com sucesso!');
      _loadData();
    } catch (e) {
      _showSnackbar('Erro ao excluir: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUnits =
        units
            .where(
              (u) => u.name.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    final filteredBssids =
        bssidMappings
            .where(
              (b) =>
                  b.macAddressRadio.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  b.sector.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  b.floor.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.map, color: Colors.blue, size: 32),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gerenciamento de Localizações',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Gerencie unidades e mapeamentos de rede',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Search and Tabs
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged:
                                (value) => setState(() => searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              prefixIcon: Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                              value: 'units',
                              label: Text('Unidades (${units.length})'),
                              icon: Icon(Icons.business),
                            ),
                            ButtonSegment(
                              value: 'bssids',
                              label: Text('BSSIDs (${bssidMappings.length})'),
                              icon: Icon(Icons.wifi),
                            ),
                          ],
                          selected: {selectedTab},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() => selectedTab = newSelection.first);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              Expanded(
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : selectedTab == 'units'
                        ? _buildUnitsView(filteredUnits)
                        : _buildBssidsView(filteredBssids),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (selectedTab == 'units') {
            _createOrUpdateUnit(null);
          } else {
            _createOrUpdateBssidMapping(null);
          }
        },
        icon: Icon(Icons.add),
        label: Text(selectedTab == 'units' ? 'Nova Unidade' : 'Novo BSSID'),
        backgroundColor: selectedTab == 'units' ? Colors.blue : Colors.purple,
      ),
    );
  }

  Widget _buildUnitsView(List<Unit> filteredUnits) {
    if (filteredUnits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'Nenhuma unidade cadastrada'
                  : 'Nenhum resultado',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: filteredUnits.length,
      itemBuilder: (context, index) {
        final unit = filteredUnits[index];
        return _buildUnitCard(unit);
      },
    );
  }

  Widget _buildUnitCard(Unit unit) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => UnitBssidsPage(
                    unit: unit,
                    authService: widget.authService,
                  ),
            ),
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.business, color: Colors.blue, size: 24),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _createOrUpdateUnit(unit);
                      } else if (value == 'delete') {
                        _deleteUnit(unit);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Excluir'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              Spacer(),
              Text(
                unit.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${unit.ipRanges.length} faixa(s) de IP',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBssidsView(List<BssidMapping> filteredBssids) {
    if (filteredBssids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'Nenhum BSSID cadastrado'
                  : 'Nenhum resultado',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: filteredBssids.length,
      itemBuilder: (context, index) {
        final bssid = filteredBssids[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.wifi, color: Colors.purple),
            ),
            title: Text(
              bssid.macAddressRadio,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('${bssid.sector} • ${bssid.floor}'),
                  ],
                ),
                if (bssid.unitName.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.home_work, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(bssid.unitName),
                    ],
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _createOrUpdateBssidMapping(bssid);
                } else if (value == 'delete') {
                  _deleteBssidMapping(bssid);
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Excluir'),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        );
      },
    );
  }
}
