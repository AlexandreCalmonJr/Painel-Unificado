// File: lib/presentation/shared/widgets/dialogs/location_dialog.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/services/auth_service.dart';

class LocationDialog extends StatefulWidget {
  const LocationDialog({
    required this.authService,
    required this.onSave,
    super.key,
    this.location,
  });

  final LocationDialogData? location;
  final AuthService authService;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  @override
  State<LocationDialog> createState() => _LocationDialogState();
}

class LocationDialogData {
  late final String name;
  late final String description;
}

class _LocationDialogState extends State<LocationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _ipStartController;
  late TextEditingController _ipEndController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.location?.description ?? '',
    );
    _ipStartController = TextEditingController();
    _ipEndController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ipStartController.dispose();
    _ipEndController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'ip_ranges': [
          {
            'start': _ipStartController.text.trim(),
            'end': _ipEndController.text.trim(),
          },
        ],
      };

      await widget.onSave(data);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.location != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Localização' : 'Nova Localização'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Localização',
                    hintText: 'Ex: Matriz São Paulo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Descrição da localização',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ipStartController,
                  decoration: const InputDecoration(
                    labelText: 'IP Inicial',
                    hintText: 'Ex: 192.168.1.1',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.router),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'IP inicial é obrigatório';
                    }
                    // Basic IPv4 validation
                    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
                    if (!ipRegex.hasMatch(value.trim())) {
                      return 'IP inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ipEndController,
                  decoration: const InputDecoration(
                    labelText: 'IP Final',
                    hintText: 'Ex: 192.168.1.254',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.router),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'IP final é obrigatório';
                    }
                    // Basic IPv4 validation
                    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
                    if (!ipRegex.hasMatch(value.trim())) {
                      return 'IP inválido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child:
              _isSaving
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(isEditing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}
