// File: lib/admin/tabs/admin_units_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/screen/unit_bssids_page.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/utils/app_constants.dart';

class AdminUnitsTab extends StatefulWidget {
  final AuthService authService;
  const AdminUnitsTab({super.key, required this.authService});

  @override
  State<AdminUnitsTab> createState() => _AdminUnitsTabState();
}

class _AdminUnitsTabState extends State<AdminUnitsTab> {
  String _searchQuery = '';
  List<Unit> _units = [];
  Map<String, int> _bssidCounts = {};
  bool _isLoading = true;
  String? _error;

  final DeviceService _deviceService = DeviceService();

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = widget.authService.currentToken;
      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final units = await _deviceService.fetchUnits(token);
      final bssids = await _deviceService.fetchBssidMappings(token);

      // Conta BSSIDs por unidade
      final counts = <String, int>{};
      for (var bssid in bssids) {
        counts[bssid.unitName] = (counts[bssid.unitName] ?? 0) + 1;
      }

      setState(() {
        _units = units;
        _bssidCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openBssidManagement(Unit unit) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) =>
                    UnitBssidsPage(unit: unit, authService: widget.authService),
          ),
        )
        .then((_) => _loadUnits()); // Recarrega ao voltar
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final palette = themeController.currentPalette;

      final filteredUnits =
          _units.where((unit) {
            return unit.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

      if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_error != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar unidades',
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
                onPressed: _loadUnits,
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
          // Header com estatísticas
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
                  onPressed: _loadUnits,
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

          // Lista de unidades
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
    });
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
}
