import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class AdminUsersTab extends StatefulWidget {
  final AuthService authService;
  const AdminUsersTab({super.key, required this.authService});

  @override
  _AdminUsersTabState createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  late Future<Map<String, dynamic>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = widget.authService.getUsers();
    });
  }

  void _showCreateUserDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    final sectorController = TextEditingController();
    String selectedRole = 'user';
    List<String> selectedPermissions = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Criar Novo Utilizador'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome de utilizador',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Palavra-passe',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Função',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('Utilizador')),
                    DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                  ],
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedRole = value!;
                      if (value == 'admin') {
                        selectedPermissions = ['mobile', 'totem', 'admin'];
                      } else {
                        selectedPermissions = [];
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedRole == 'user') ...[
                  TextField(
                    controller: sectorController,
                    decoration: const InputDecoration(
                      labelText: 'Setor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Permissões (Módulos acessíveis):'),
                  CheckboxListTile(
                    title: const Text('Módulo Mobile'),
                    value: selectedPermissions.contains('mobile'),
                    onChanged: (value) {
                      setStateDialog(() {
                        if (value == true) {
                          selectedPermissions.add('mobile');
                        } else {
                          selectedPermissions.remove('mobile');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Módulo Totem'),
                    value: selectedPermissions.contains('totem'),
                    onChanged: (value) {
                      setStateDialog(() {
                        if (value == true) {
                          selectedPermissions.add('totem');
                        } else {
                          selectedPermissions.remove('totem');
                        }
                      });
                    },
                  ),
                ] else
                  const Text('Administradores têm acesso a todos os módulos.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isEmpty || 
                    passwordController.text.isEmpty || 
                    emailController.text.isEmpty ||
                    (selectedRole == 'user' && sectorController.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
                  );
                  return;
                }

                final result = await widget.authService.createUser({
                  'username': usernameController.text,
                  'email': emailController.text,
                  'password': passwordController.text,
                  'role': selectedRole,
                  'sector': sectorController.text,
                  'permissions': selectedPermissions,
                });

                if (result['success']) {
                  Navigator.pop(context);
                  _loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Utilizador criado com sucesso')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'] ?? 'Erro ao criar utilizador')),
                  );
                }
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final usernameController = TextEditingController(text: user['username']);
    final emailController = TextEditingController(text: user['email']);
    final sectorController = TextEditingController(text: user['sector']);
    String selectedRole = user['role'];
    List<String> selectedPermissions = List<String>.from(user['permissions'] ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar Utilizador'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome de utilizador',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                if (selectedRole == 'user') ...[
                  TextField(
                    controller: sectorController,
                    decoration: const InputDecoration(
                      labelText: 'Setor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Permissões (Módulos acessíveis):'),
                  CheckboxListTile(
                    title: const Text('Módulo Mobile'),
                    value: selectedPermissions.contains('mobile'),
                    onChanged: (value) {
                      setStateDialog(() {
                        if (value == true) {
                          selectedPermissions.add('mobile');
                        } else {
                          selectedPermissions.remove('mobile');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Módulo Totem'),
                    value: selectedPermissions.contains('totem'),
                    onChanged: (value) {
                      setStateDialog(() {
                        if (value == true) {
                          selectedPermissions.add('totem');
                        } else {
                          selectedPermissions.remove('totem');
                        }
                      });
                    },
                  ),
                ] else
                  const Text('Administradores têm acesso a todos os módulos.'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Função',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('Utilizador')),
                    DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                  ],
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedRole = value!;
                      if (value == 'admin') {
                        selectedPermissions = ['mobile', 'totem', 'admin'];
                      } else {
                        selectedPermissions = selectedPermissions.where((p) => p != 'admin').toList();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isEmpty || 
                    emailController.text.isEmpty ||
                    (selectedRole == 'user' && sectorController.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
                  );
                  return;
                }

                final result = await widget.authService.updateUser(
                  user['_id'],
                  {
                    'username': usernameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                    'sector': sectorController.text,
                    'permissions': selectedPermissions,
                  },
                );

                if (result['success']) {
                  Navigator.pop(context);
                  _loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Utilizador atualizado com sucesso')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'] ?? 'Erro ao atualizar utilizador')),
                  );
                }
              },
              child: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminação'),
        content: Text('Tem a certeza que deseja eliminar o utilizador "${user['username']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final result = await widget.authService.deleteUser(user['_id']);
              Navigator.pop(context);
              if (result['success']) {
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Utilizador eliminado com sucesso')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? 'Erro ao eliminar utilizador')),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUsers,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final result = snapshot.data ?? {};
          final users = result['users'] as List<dynamic>? ?? [];
          
          if (users.isEmpty) {
            return const Center(child: Text('Nenhum utilizador encontrado.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index] as Map<String, dynamic>;
              final isCurrentUser = user['_id'] == widget.authService.currentUser?['_id'];
              final permissions = user['role'] == 'admin' 
                  ? 'Todos os módulos (Admin)' 
                  : (user['permissions'] as List<dynamic>?)?.join(', ') ?? 'Nenhum módulo';
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user['role'] == 'admin' ? Colors.purple : Colors.blue,
                    child: Icon(
                      user['role'] == 'admin' ? Icons.admin_panel_settings : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    user['username'],
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['role'] == 'admin' ? 'Administrador' : 'Utilizador',
                      ),
                      Text(
                        'Setor: ${user['sector']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Permissões: $permissions',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCurrentUser)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditUserDialog(user),
                        ),
                      if (!isCurrentUser)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteUser(user),
                        ),
                      if (isCurrentUser)
                        const Chip(
                          label: Text('Você', style: TextStyle(fontSize: 12)),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        tooltip: 'Criar Novo Utilizador',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Adicione este método ao AuthService se não existir (para compatibilidade)
extension AuthServiceExtension on AuthService {
  Future<Map<String, dynamic>> getUsers() async {
    if (!isLoggedIn || !isAdmin) {
      return {'success': false, 'users': []};
    }
    final config = ServerConfigService.instance.loadConfig();
    try {
      final response = await http.get(
        Uri.parse('http://${config['ip']}:${config['port']}/api/auth/users'),
        headers: {'Authorization': 'Bearer $currentToken'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'users': data['users']};
      } else {
        return {'success': false, 'users': []};
      }
    } catch (e) {
      return {'success': false, 'users': [], 'error': e.toString()};
    }
  }
}