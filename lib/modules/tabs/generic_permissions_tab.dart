// File: lib/tabs/generic_permissions_tab.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

class GenericPermissionsTab extends StatefulWidget {
  final String moduleId;
  final String moduleName;
  final AuthService authService;
  final ModuleManagementService moduleService;

  const GenericPermissionsTab({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.authService,
    required this.moduleService,
  });

  @override
  State<GenericPermissionsTab> createState() => _GenericPermissionsTabState();
}

class _GenericPermissionsTabState extends State<GenericPermissionsTab> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _allUsers = [];
  Set<String> _permittedUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Buscar todos os usuários
      final usersResponse = await widget.authService.getUsers();
      if (!usersResponse['success']) {
        throw Exception(usersResponse['message']);
      }
      final allUsers = usersResponse['users'] as List<dynamic>;
      
      // 2. Buscar permissões atuais do módulo
      final permittedIds = await widget.moduleService.getModulePermissions(widget.moduleId);

      // Filtra usuários "admin" (eles sempre têm acesso)
      final nonAdminUsers = allUsers
          .where((user) => user['role'] != 'admin')
          .toList();

      if (mounted) {
        setState(() {
          _allUsers = nonAdminUsers;
          _permittedUserIds = Set.from(permittedIds);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _savePermissions() async {
    setState(() => _isLoading = true);
    try {
      await widget.moduleService.updateModulePermissions(
        widget.moduleId,
        _permittedUserIds.toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissões salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Recarrega para confirmar
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permissões - ${widget.moduleName}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecione quais usuários (não-administradores) podem visualizar este módulo.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Administradores sempre têm acesso total a todos os módulos.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: _buildBody(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _savePermissions,
              icon: _isLoading 
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save, color: Colors.white),
              label: const Text('Salvar Permissões'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading && _allUsers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Erro: $_errorMessage', style: TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_allUsers.isEmpty) {
      return const Center(
        child: Text('Nenhum usuário (não-administrador) encontrado.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _allUsers.length,
      itemBuilder: (context, index) {
        final user = _allUsers[index];
        final userId = user['_id'] as String;
        final bool hasPermission = _permittedUserIds.contains(userId);

        return CheckboxListTile(
          title: Text(user['username'] ?? 'Usuário Inválido'),
          subtitle: Text('Setor: ${user['sector'] ?? 'N/D'}'),
          value: hasPermission,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _permittedUserIds.add(userId);
              } else {
                _permittedUserIds.remove(userId);
              }
            });
          },
        );
      },
    );
  }
}