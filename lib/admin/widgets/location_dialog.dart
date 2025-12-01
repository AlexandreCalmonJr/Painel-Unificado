// File: lib/admin/widgets/location_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/models/location.dart';
import 'package:painel_windowns/utils/app_constants.dart';

class LocationDialog extends StatefulWidget {
  final Location? location; // null = create mode, non-null = edit mode
  final Function(Map<String, dynamic>) onSave;

  const LocationDialog({super.key, this.location, required this.onSave});

  @override
  State<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ipRangeController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location?.name ?? '');
    _ipRangeController = TextEditingController(
      text: widget.location?.ipRange ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.location?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipRangeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final data = {
        'name': _nameController.text.trim(),
        'ip_range': _ipRangeController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      try {
        await widget.onSave(data);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final isEditMode = widget.location != null;

      return AlertDialog(
        backgroundColor:
            isDark ? AppColors.surface : AppColors.surfaceLightMode,
        title: Text(
          isEditMode ? 'Editar Localização' : 'Nova Localização',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  enabled: !isEditMode, // Nome não pode ser editado
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nome da Localização *',
                    labelStyle: TextStyle(
                      color:
                          isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                    ),
                    filled: true,
                    fillColor:
                        isDark
                            ? AppColors.background
                            : AppColors.surfaceLightVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark ? AppColors.border : AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark ? AppColors.border : AppColors.borderLight,
                      ),
                    ),
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
                  controller: _ipRangeController,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Faixa de IP',
                    hintText: 'Ex: 192.168.1.0/24',
                    labelStyle: TextStyle(
                      color:
                          isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                    ),
                    hintStyle: TextStyle(
                      color:
                          isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                    ),
                    filled: true,
                    fillColor:
                        isDark
                            ? AppColors.background
                            : AppColors.surfaceLightVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark ? AppColors.border : AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark ? AppColors.border : AppColors.borderLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    labelStyle: TextStyle(
                      color:
                          isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                    ),
                    filled: true,
                    fillColor:
                        isDark
                            ? AppColors.background
                            : AppColors.surfaceLightVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark ? AppColors.border : AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark ? AppColors.border : AppColors.borderLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(isEditMode ? 'Salvar' : 'Criar'),
          ),
        ],
      );
    });
  }
}
