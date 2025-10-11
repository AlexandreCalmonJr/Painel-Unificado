import 'package:flutter/material.dart';
import 'package:painel_windowns/models/ip_mapping.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/monitoring_service.dart';


class AdminLocationsTab extends StatefulWidget {
  final AuthService authService;
  const AdminLocationsTab({super.key, required this.authService});

  @override
  _AdminLocationsTabState createState() => _AdminLocationsTabState();
}

class _AdminLocationsTabState extends State<AdminLocationsTab> {
  late final MonitoringService _monitoringService;
  late Future<List<IpMapping>> _mappingsFuture;

  @override
  void initState() {
    super.initState();
    _monitoringService = MonitoringService(authService: widget.authService);
    _loadMappings();
  }

  void _loadMappings() {
    setState(() {
      _mappingsFuture = _monitoringService.getMappings();
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _showAddMappingDialog() async {
    final formKey = GlobalKey<FormState>();
    final locationController = TextEditingController();
    final ipStartController = TextEditingController();
    final ipEndController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Nova Localização'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Nome da Localização'),
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: ipStartController,
                    decoration: const InputDecoration(labelText: 'IP Inicial da Faixa'),
                     validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: ipEndController,
                    decoration: const InputDecoration(labelText: 'IP Final da Faixa'),
                     validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _monitoringService.createIpMapping(
                      locationController.text,
                      ipStartController.text,
                      ipEndController.text,
                    );
                    Navigator.of(context).pop();
                    _showSnackbar('Localização adicionada com sucesso!');
                    _loadMappings();
                  } catch (e) {
                     Navigator.of(context).pop();
                    _showSnackbar('Erro ao salvar: ${e.toString()}', isError: true);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

   Future<void> _showDeleteConfirmationDialog(IpMapping mapping) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminação'),
          content: Text('Tem a certeza que deseja eliminar a localização "${mapping.location}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () async {
                 try {
                    await _monitoringService.deleteIpMapping(mapping.id);
                    Navigator.of(context).pop();
                    _showSnackbar('Localização eliminada com sucesso!');
                    _loadMappings();
                  } catch (e) {
                     Navigator.of(context).pop();
                    _showSnackbar('Erro ao eliminar: ${e.toString()}', isError: true);
                  }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<IpMapping>>(
        future: _mappingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma localização configurada.'));
          }
          final mappings = snapshot.data!;
          return ListView.builder(
            itemCount: mappings.length,
            itemBuilder: (context, index) {
              final mapping = mappings[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.map),
                  title: Text(mapping.location, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Faixa de IP: ${mapping.ipStart} - ${mapping.ipEnd}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(mapping),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMappingDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nova Localização'),
      ),
    );
  }
}
