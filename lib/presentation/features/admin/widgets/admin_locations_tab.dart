// File: lib/admin/tabs/admin_locations_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/config/theme_models.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/utils/theme_utils.dart';
// ignore: library_prefixes
import 'package:painel_windowns/data/models/location.dart' as LocationModel;
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';
import 'package:painel_windowns/presentation/features/admin/pages/unit_bssids_page.dart';
import 'package:painel_windowns/presentation/shared/widgets/dialogs/location_dialog.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/services/location_service.dart';

class AdminLocationsTab extends StatefulWidget {
  const AdminLocationsTab({required this.authService, super.key});
  final AuthService authService;

  @override
  State<AdminLocationsTab> createState() => _AdminLocationsTabState();
}

class _AdminLocationsTabState extends State<AdminLocationsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _searchQuery = '';
  List<LocationModel.Location> _locations = [];
  List<Unit> _units = [];
  Map<String, int> _bssidCounts = {};
  bool _isLoading = true;
  String? _error;

  final DeviceService _deviceService = DeviceService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = widget.authService.currentToken;
      if (token == null) {
        throw Exception('Token de autentica��o n�o encontrado');
      }

      // Carrega localiza��es e unidades em paralelo
      final results = await Future.wait([
        LocationService.fetchLocationsWithDeviceData(token),
        _deviceService.fetchUnits(token),
        _deviceService.fetchBssidMappings(token),
      ]);

      final locations = results[0] as List<LocationModel.Location>;
      final units = results[1] as List<Unit>;
      final bssids = results[2] as List;

      // Conta BSSIDs por unidade
      final counts = <String, int>{};
      for (final bssid in bssids) {
        final unitName = bssid.unitName as String;
        counts[unitName] = (counts[unitName] ?? 0) + 1;
      }

      if (mounted) {
        setState(() {
          _locations = locations;
          _units = units;
          _bssidCounts = counts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openBssidManagement(Unit unit) {
    Navigator.of(context)
        .push(
          // ignore: inference_failure_on_instance_creation
          MaterialPageRoute(
            builder:
                (context) =>
                    UnitBssidsPage(unit: unit, authService: widget.authService),
          ),
        )
        .then((_) => _loadData()); // Recarrega ao voltar
  }

  Future<void> _showLocationDialog({LocationModel.Location? location}) async {
    // Convert to LocationDialogData for the dialog
    final dialogData =
        location != null
            ? (LocationDialogData()
              ..name = location.name
              ..description = location.description ?? '')
            : null;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => LocationDialog(
            location: dialogData,
            authService: widget.authService,
            onSave: (data) async {
              final token = widget.authService.currentToken;
              if (token == null) {
                throw Exception('Token de autentica��o n�o encontrado');
              }

              if (location == null) {
                // Create
                await LocationService.createLocation(token, data);
              } else {
                // Update
                await LocationService.updateLocation(
                  token,
                  location.name,
                  data,
                );
              }
            },
          ),
    );

    if (result == true) {
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              location == null
                  ? 'Localiza��o criada com sucesso!'
                  : 'Localiza��o atualizada com sucesso!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _deleteLocation(LocationModel.Location location) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclus�o'),
            content: Text(
              'Tem certeza que deseja excluir a localiza��o "${location.name}"?\n\nEsta a��o n�o pode ser desfeita.',
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
        final token = widget.authService.currentToken;
        if (token == null) {
          throw Exception('Token de autentica��o n�o encontrado');
        }

        await LocationService.deleteLocation(token, location.name);
        _loadData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Localiza��o exclu�da com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
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

  Future<void> _showImportDialog() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Funcionalidade de importa��o em desenvolvimento. '
            'Use a interface de Unidades para cadastrar BSSIDs.',
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _exportData() async {
    try {
      final token = widget.authService.currentToken;
      if (token == null) {
        throw Exception('Token de autentica��o n�o encontrado');
      }

      // Busca todos os dados
      final locations = _locations;

      // Cria JSON para export
      final exportData = {
        'export_date': DateTime.now().toIso8601String(),
        'locations': locations.map((l) => l.toJson()).toList(),
      };

      // Por enquanto, mostra mensagem
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Exportando ${locations.length} localiza��es...\n'
              'Funcionalidade completa em desenvolvimento.',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      print('?? Dados para exportar: ${exportData.toString()}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.effectiveDarkMode;
        final palette = ColorPalettes.getPalette(themeState.config.colorScheme);

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
                  'Erro ao carregar dados',
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
                  onPressed: _loadData,
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

        return Column(
          children: [
            // TabBar
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.borderLight,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: palette['primary'],
                labelColor: palette['primary'],
                unselectedLabelColor:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                tabs: const [
                  Tab(text: 'Localiza��es', icon: Icon(Icons.location_on)),
                  Tab(text: 'Unidades', icon: Icon(Icons.business)),
                ],
              ),
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLocationsTab(isDark, palette),
                  _buildUnitsTab(isDark, palette),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationsTab(bool isDark, Map<String, Color> palette) {
    final filteredLocations =
        _locations.where((loc) {
          return loc.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

    return Column(
      children: [
        // Barra de busca e a��es (Locations)
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
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar localiza��es...',
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
                onPressed: () => _showLocationDialog(),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Nova Localiza��o'),
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
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Atualizar',
                style: IconButton.styleFrom(
                  backgroundColor: palette['primary']!.withOpacity(0.1),
                  foregroundColor: palette['primary'],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Mais op��es',
                onSelected: (value) {
                  if (value == 'import') {
                    _showImportDialog();
                  } else if (value == 'export') {
                    _exportData();
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'import',
                        child: Row(
                          children: [
                            Icon(Icons.upload_file, size: 20),
                            SizedBox(width: 12),
                            Text('Importar Dados'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.download, size: 20),
                            SizedBox(width: 12),
                            Text('Exportar Dados'),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Lista de Localiza��es
        Expanded(
          child:
              filteredLocations.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          size: 64,
                          color:
                              isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Nenhuma localiza��o encontrada'
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
                      childAspectRatio: 1.5,
                    ),
                    itemCount: filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = filteredLocations[index];
                      return _buildLocationCard(location, isDark, palette);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildUnitsTab(bool isDark, Map<String, Color> palette) {
    final filteredUnits =
        _units.where((unit) {
          return unit.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

    return Column(
      children: [
        // Header com estat�sticas (Units)
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total de Unidades',
                _units.length.toString(),
                Icons.business,
                palette['primary']!,
                isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total de BSSIDs',
                _bssidCounts.values
                    .fold(0, (sum, count) => sum + count)
                    .toString(),
                Icons.wifi,
                palette['accent']!,
                isDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Barra de busca (Units)
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
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar unidades...',
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
              IconButton(
                onPressed: _loadData,
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

        // Lista de Unidades
        Expanded(
          child:
              filteredUnits.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 64,
                          color:
                              isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Nenhuma unidade encontrada'
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
                      childAspectRatio: 1.5,
                    ),
                    itemCount: filteredUnits.length,
                    itemBuilder: (context, index) {
                      final unit = filteredUnits[index];
                      return _buildUnitCard(unit, isDark, palette);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildUnitCard(Unit unit, bool isDark, Map<String, Color> palette) {
    final bssidCount = _bssidCounts[unit.name] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette['primary']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business,
                  color: palette['primary'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  unit.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                Icons.wifi,
                size: 14,
                color:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                '$bssidCount BSSIDs cadastrados',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openBssidManagement(unit),
              icon: const Icon(Icons.wifi, size: 18),
              label: const Text('Gerenciar BSSIDs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette['primary'],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(
    LocationModel.Location location,
    bool isDark,
    Map<String, Color> palette,
  ) {
    final isOnline = location.isOnline;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette['primary']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on,
                  color: palette['primary'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                isOnline ? AppColors.success : AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isOnline ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                Icons.router,
                size: 14,
                color:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.ipRangesDisplay,
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

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.wifi,
                size: 14,
                color:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.bssidsDisplay,
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

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.devices,
                size: 14,
                color:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                '${location.deviceCount} dispositivos',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _showLocationDialog(location: location),
                icon: const Icon(Icons.wifi, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: palette['accent']!.withOpacity(0.1),
                  foregroundColor: palette['accent'],
                ),
                tooltip: 'Gerenciar BSSIDs',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showLocationDialog(location: location),
                icon: const Icon(Icons.edit, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: palette['primary']!.withOpacity(0.1),
                  foregroundColor: palette['primary'],
                ),
                tooltip: 'Editar',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _deleteLocation(location),
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
    );
  }
}
