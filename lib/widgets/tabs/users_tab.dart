// Unified users_tab.dart
// File: lib/widgets/tabs/users_tab.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/admin/tabs/admin_users_tab.dart';
import 'package:painel_windowns/services/auth_service.dart';

class UsersTab extends StatefulWidget {
  final AuthService authService;

  const UsersTab({
    super.key,
    required this.authService,
  });

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.authService.isAdmin) {
      _loadUsers();
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await widget.authService.getUsers();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _users = List<Map<String, dynamic>>.from(result['users']);
        } else {
          _errorMessage = result['message'];
        }
      });
    }
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

  void _showUserDialog({Map<String, dynamic>? user}) {
    final isEditing = user != null;
    final usernameController = TextEditingController(text: user?['username'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final passwordController = TextEditingController();
    // O campo 'sector' agora é usado para os prefixos
    final sectorController = TextEditingController(text: user?['sector'] ?? '');
    String selectedRole = user?['role'] ?? 'user';
    bool isLoadingDialog = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(isEditing ? Icons.edit : Icons.add, color: isEditing ? Colors.blue : Colors.green),
              const SizedBox(width: 8),
              Text(isEditing ? 'Editar Utilizador' : 'Criar Utilizador'),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nome de Utilizador',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isEditing)
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Papel',
                      prefixIcon: const Icon(Icons.security),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('Utilizador')),
                      DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                    ],
                    onChanged: (value) {
                      setDialogState(() => selectedRole = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedRole == 'user')
                    TextFormField(
                      controller: sectorController,
                      decoration: InputDecoration(
                        labelText: 'Prefixos de Dispositivos Visíveis',
                        prefixIcon: const Icon(Icons.visibility),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: 'Separados por vírgula (ex: Enfermagem, UTI)',
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoadingDialog ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoadingDialog ? null : () async {
                if (usernameController.text.trim().isEmpty ||
                    emailController.text.trim().isEmpty ||
                    (!isEditing && passwordController.text.isEmpty) ||
                    (selectedRole == 'user' && sectorController.text.trim().isEmpty)) {
                  _showSnackbar('Preencha todos os campos obrigatórios', isError: true);
                  return;
                }

                setDialogState(() => isLoadingDialog = true);

                final userData = {
                  'username': usernameController.text.trim(),
                  'email': emailController.text.trim(),
                  'role': selectedRole,
                  'sector': selectedRole == 'user' ? sectorController.text.trim() : 'Global',
                  if (!isEditing) 'password': passwordController.text,
                };

                Map<String, dynamic> result;
                if (isEditing) {
                  result = await widget.authService.updateUser(user['_id'], userData);
                } else {
                  result = await widget.authService.createUser(userData);
                }

                if (mounted) {
                  setDialogState(() => isLoadingDialog = false);
                  if (result['success']) {
                    _showSnackbar(isEditing ? 'Utilizador atualizado com sucesso' : 'Utilizador criado com sucesso');
                    Navigator.of(context).pop();
                    _loadUsers();
                  } else {
                    _showSnackbar(result['message'], isError: true);
                  }
                }
              },
              child: isLoadingDialog
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : Text(isEditing ? 'Atualizar' : 'Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmar Exclusão'),
          ],
        ),
        content: Text('Tem a certeza que deseja excluir o utilizador "${user['username']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final result = await widget.authService.deleteUser(user['_id']);
              if (mounted) {
                if (result['success']) {
                  _showSnackbar('Utilizador excluído com sucesso');
                  _loadUsers();
                } else {
                  _showSnackbar(result['message'], isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600], foregroundColor: Colors.white),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.authService.isAdmin) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Acesso Restrito', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text('Apenas administradores podem gerenciar utilizadores.', style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people, color: Colors.blue, size: 28),
                  const SizedBox(width: 8),
                  const Text('Utilizadores', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _loadUsers,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Atualizar',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _showUserDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Novo Utilizador'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_errorMessage != null)
            Card(
              color: Colors.red[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700]))),
                  ],
                ),
              ),
            ),

          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: Colors.blue)))
          else if (_users.isEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.grey),
                title: const Text('Nenhum utilizador encontrado.'),
                subtitle: const Text('Crie um novo utilizador para começar.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final createdAt = DateTime.tryParse(user['created_at'] ?? '') ?? DateTime.now();
                  final formattedDate = '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: user['role'] == 'admin' ? Colors.red[600] : Colors.blue[600],
                        child: Text(
                          user['username'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        user['username'],
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['email'],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            user['role'] == 'admin' ? 'Admin' : 'Utilizador',
                            style: TextStyle(
                              color: user['role'] == 'admin' ? Colors.red[700] : Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Visibilidade: ${user['sector'] ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          Text(
                            'Criado: $formattedDate',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showUserDialog(user: user);
                          } else if (value == 'delete') {
                            _showDeleteUserDialog(user);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Editar')]),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Excluir')]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}