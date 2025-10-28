import 'package:flutter/material.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';

class UnitBssidsPage extends StatefulWidget {
  final Unit unit;
  final AuthService authService;

  const UnitBssidsPage({
    super.key,
    required this.unit,
    required this.authService,
  });

  @override
  State<UnitBssidsPage> createState() => _UnitBssidsPageState();
}

class _UnitBssidsPageState extends State<UnitBssidsPage> {
  final DeviceService _deviceService = DeviceService();
  List<BssidMapping> bssidMappings = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBssids();
  }

  /// Carrega os BSSIDs filtrados para esta unidade específica
  Future<void> _loadBssids() async {
    setState(() => isLoading = true);
    try {
      final token = widget.authService.currentToken ?? '';
      if (token.isEmpty) {
        _showSnackbar('Token inválido. Faça login novamente.', isError: true);
        return;
      }
      // Chama o método correto do service
      bssidMappings =
          await _deviceService.fetchBssidsForUnit(token, widget.unit.name);
    } catch (e) {
      _showSnackbar('Erro ao carregar BSSIDs: $e', isError: true);
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

  /// Mostra o diálogo para criar ou editar um BSSID.
  /// A 'unitName' já vem preenchida e desabilitada.
  Future<void> _createOrUpdateBssidMapping(BssidMapping? mapping) async {
    final isEditing = mapping != null;
    final macController = TextEditingController(text: mapping?.macAddressRadio);
    final sectorController = TextEditingController(text: mapping?.sector);
    final floorController = TextEditingController(text: mapping?.floor);
    // CRÍTICO: Pré-preenche o nome da unidade e desabilita a edição
    final unitNameController = TextEditingController(text: widget.unit.name);

    await showDialog(
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
              readOnly: true, // Desabilita a edição
              decoration: InputDecoration(
                labelText: 'Unidade',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.home_work),
                filled: true,
                fillColor: Colors.grey[200],
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
              // Sempre usa o nome da unidade da página
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
                      widget.authService.currentToken!,
                      mapping.macAddressRadio,
                      newMapping);
                  _showSnackbar('Mapeamento atualizado com sucesso!');
                } else {
                  await _deviceService.createBssidMapping(
                      widget.authService.currentToken!, newMapping);
                  _showSnackbar('Mapeamento criado com sucesso!');
                }
                Navigator.of(context).pop();
                _loadBssids(); // Recarrega a lista
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

  /// Exclui um BSSID
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
      await _deviceService.deleteBssidMapping(
          widget.authService.currentToken!, mapping.macAddressRadio);
      _showSnackbar('Mapeamento excluído com sucesso!');
      _loadBssids(); // Recarrega a lista
    } catch (e) {
      _showSnackbar('Erro ao excluir: $e', isError: true);
    }
  }

  /// Constrói a lista de BSSIDs
  Widget _buildBssidList() {
    if (bssidMappings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.location_off, color: Colors.grey),
              title: const Text('Nenhum BSSID cadastrado'),
              subtitle: const Text(
                  'Adicione um mapeamento no botão (+) para esta unidade.'),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bssidMappings.length,
      itemBuilder: (context, index) {
        final mapping = bssidMappings[index];
        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: const Icon(Icons.wifi, color: Colors.blue),
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
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BSSIDs - ${widget.unit.name}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.blue.shade50],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : _buildBssidList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdateBssidMapping(null),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}