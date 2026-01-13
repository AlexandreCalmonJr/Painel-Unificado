import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/data/models/user_model.dart';

class UserFormDialog extends StatefulWidget {
  final User? user;

  const UserFormDialog({Key? key, this.user}) : super(key: key);

  @override
  _UserFormDialogState createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _sectorController;
  String _role = 'user';
  bool _isActive = true;
  final List<String> _selectedPermissions = [];

  final List<String> _availablePermissions = [
    'manage_users',
    'manage_devices',
    'view_reports',
    'manage_settings',
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _sectorController = TextEditingController(text: widget.user?.sector ?? '');
    _role = widget.user?.role ?? 'user';
    _isActive = widget.user?.isActive ?? true;
    if (widget.user?.permissions != null) {
      _selectedPermissions.addAll(widget.user!.permissions!);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _sectorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Novo Usuário' : 'Editar Usuário'),
      content: SingleChildScrollView(
        child: Container(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome de Usuário',
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Campo obrigatório'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator:
                      (value) =>
                          value == null || !value.contains('@')
                              ? 'Email inválido'
                              : null,
                ),
                const SizedBox(height: 16),
                if (widget.user == null) ...[
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    validator:
                        (value) =>
                            value == null || value.length < 6
                                ? 'Mínimo 6 caracteres'
                                : null,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _sectorController,
                  decoration: const InputDecoration(labelText: 'Setor'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(labelText: 'Função'),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('Usuário')),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrador'),
                    ),
                    DropdownMenuItem(value: 'support', child: Text('Suporte')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _role = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Ativo'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Permissões',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._availablePermissions.map((perm) {
                  return CheckboxListTile(
                    title: Text(perm),
                    value: _selectedPermissions.contains(perm),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedPermissions.add(perm);
                        } else {
                          _selectedPermissions.remove(perm);
                        }
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final userData = {
                if (widget.user != null) '_id': widget.user!.id,
                'username': _usernameController.text,
                'email': _emailController.text,
                if (_passwordController.text.isNotEmpty)
                  'password': _passwordController.text,
                'role': _role,
                'isActive': _isActive,
                'sector': _sectorController.text,
                'permissions': _selectedPermissions,
              };
              Get.back(result: userData);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
