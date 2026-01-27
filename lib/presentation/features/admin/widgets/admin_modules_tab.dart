// File: lib/admin/tabs/admin_modules_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/config/theme_models.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/di/injection.dart';
import 'package:painel_windowns/core/utils/theme_utils.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/data/models/module.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';
import 'package:painel_windowns/presentation/features/admin/pages/module_details_page.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/stat_card.dart';
import 'package:painel_windowns/presentation/shared/widgets/dialogs/module_dialog.dart';
// import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_permissions_tab.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

class AdminModulesTab extends StatefulWidget {
  const AdminModulesTab({required this.authService, super.key});
  final AuthService authService;

  @override
  State<AdminModulesTab> createState() => _AdminModulesTabState();
}

class _AdminModulesTabState extends State<AdminModulesTab> {
  String _searchQuery = '';
  List<Module> _modules = [];
  bool _isLoading = true;
  String? _error;
  late ModuleManagementService _moduleService;

  @override
  void initState() {
    super.initState();
    _moduleService = getIt<ModuleManagementService>();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final configs = await _moduleService.listModules();
      setState(() {
        _modules =
            (configs as List<dynamic>)
                .map(
                  (c) => Module.fromAssetModuleConfig(c as AssetModuleConfig),
                )
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showModuleDialog({Module? module}) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ModuleDialog(
            module: module,
            onSave: (Map<String, dynamic> data) async {
              if (module == null) {
                // Create - usa as colunas que vêm do dialog
                final typeIdentifier = data['type'] as String;
                final moduleType = AssetModuleType.values.firstWhere(
                  (t) => t.identifier == typeIdentifier,
                  orElse: () => AssetModuleType.custom,
                );
                await _moduleService.createModule(
                  name: data['name'] as String,
                  description: data['description'] as String,
                  type: moduleType,
                  tableColumns: List<Map<String, dynamic>>.from(
                    data['table_columns'] as List? ?? [],
                  ),
                );
              } else {
                // Update
                await _moduleService.updateModule(
                  moduleId: module.id,
                  name: data['name'] as String?,
                  description: data['description'] as String?,
                  isActive: data['is_active'] as bool?,
                  type: module.type,
                  tableColumns: List<Map<String, dynamic>>.from(
                    data['table_columns'] as List? ?? [],
                  ),
                );
              }
            },
          ),
    );

    if (result == true) {
      await _loadModules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              module == null
                  ? 'Módulo criado com sucesso!'
                  : 'Módulo atualizado com sucesso!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _deleteModule(Module module) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text(
              'Tem certeza que deseja excluir o módulo "${module.name}"?\n\nEsta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _moduleService.deleteModule(module.id);
        await _loadModules();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Módulo excluído com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // Check for specific error content if possible, or just show dialog
          if (e.toString().contains('400')) {
            await showDialog<void>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Não é possível excluir'),
                    content: const Text(
                      'Este módulo possui ativos vinculados.\nRemova todos os ativos antes de excluir o módulo.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao excluir: $e'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        }
      }
    }
  }

  void _navigateToModuleDetails(Module module) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (context) => ModuleDetailsPage(
              module: module,
              authService: widget.authService,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.effectiveDarkMode;
        final palette = ColorPalettes.getPalette(themeState.config.colorScheme);

        final filteredModules =
            _modules
                .where(
                  (mod) => mod.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar módulos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadModules,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        final activeModules = _modules.where((m) => m.isActive).length;

        return Column(
          children: [
            // Header com estatísticas
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total de Módulos',
                    value: _modules.length.toString(),
                    icon: Icons.apps,
                    color: palette['primary']!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Módulos Ativos',
                    value: activeModules.toString(),
                    icon: Icons.check_circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Módulos Inativos',
                    value: (_modules.length - activeModules).toString(),
                    icon: Icons.pause_circle,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Barra de busca
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged:
                          (value) => setState(() => _searchQuery = value),
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar módulos...',
                        hintStyle: TextStyle(
                          color:
                              isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
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
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showModuleDialog(),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Novo Módulo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette['primary'],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _loadModules,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Atualizar',
                    style: IconButton.styleFrom(
                      backgroundColor: palette['primary']!.withOpacity(0.1),
                      foregroundColor: palette['primary'],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Lista de módulos
            Expanded(
              child:
                  filteredModules.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.apps_outlined,
                              size: 64,
                              color:
                                  isDark
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Nenhum módulo encontrado'
                                  : 'Nenhum resultado para "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDark
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      )
                      : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 1400 ? 3 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: filteredModules.length,
                        itemBuilder: (context, index) {
                          final module = filteredModules[index];
                          return _buildModuleCard(module, isDark, palette);
                        },
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModuleCard(
    Module module,
    bool isDark,
    Map<String, Color> palette,
  ) {
    final isActive = module.isActive;

    return Material(
      color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToModuleDetails(module),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [palette['primary']!, palette['accent']!],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(module.icon, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isActive
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          module.statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color:
                                isActive
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                module.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                module.description,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              Divider(color: isDark ? AppColors.border : AppColors.borderLight),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 16,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      module.type.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => _showModuleDialog(module: module),
                    icon: const Icon(Icons.edit, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: palette['primary']!.withOpacity(0.1),
                      foregroundColor: palette['primary'],
                    ),
                    tooltip: 'Editar',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _deleteModule(module),
                    icon: const Icon(Icons.delete, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.danger.withOpacity(0.1),
                      foregroundColor: AppColors.danger,
                    ),
                    tooltip: 'Excluir',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
