import 'package:flutter/material.dart';
import 'package:painel_windowns/services/auth_service.dart';

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
    String selectedRole = 'user';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Criar Novo Utilizador'),
          content: Column(
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
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha todos os campos')),
                  );
                  return;
                }

                final result = await widget.authService.createUser({
                  'username': usernameController.text,
                  'password': passwordController.text,
                  'role': selectedRole,
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Operação concluída'),
                      backgroundColor: result['success'] ? Colors.green : Colors.red,
                    ),
                  );
                  if (result['success']) {
                    _loadUsers();
                  }
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
    String selectedRole = user['role'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar Utilizador'),
          content: Column(
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
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await widget.authService.updateUser(
                  user['_id'],
                  {
                    'username': usernameController.text,
                    'role': selectedRole,
                  },
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Operação concluída'),
                      backgroundColor: result['success'] ? Colors.green : Colors.red,
                    ),
                  );
                  if (result['success']) {
                    _loadUsers();
                  }
                }
              },
              child: const Text('Guardar'),
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
        content: Text('Tem certeza que deseja eliminar o utilizador "${user['username']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final result = await widget.authService.deleteUser(user['_id']);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Operação concluída'),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );
                if (result['success']) {
                  _loadUsers();
                }
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
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData) {
            return const Center(child: Text('Sem dados'));
          }

          final result = snapshot.data!;
          
          if (!result['success']) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(result['message'] ?? 'Erro ao carregar utilizadores'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUsers,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final users = result['users'] as List<dynamic>;
          
          if (users.isEmpty) {
            return const Center(child: Text('Nenhum utilizador encontrado.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index] as Map<String, dynamic>;
              final isCurrentUser = user['_id'] == widget.authService.currentUser?['_id'];
              
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
                  subtitle: Text(
                    user['role'] == 'admin' ? 'Administrador' : 'Utilizador',
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