// File: lib/admin/tabs/admin_locations_tab.dart (REDESIGNED)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/config/theme_config.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/utils/app_constants.dart';

class AdminLocationsTab extends StatefulWidget {
  final AuthService authService;
  const AdminLocationsTab({super.key, required this.authService});

  @override
  State<AdminLocationsTab> createState() => _AdminLocationsTabState();
}

class _AdminLocationsTabState extends State<AdminLocationsTab> {
  String _searchQuery = '';

  // Dados de exemplo - substituir por dados reais
  final List<Map<String, dynamic>> _locations = [
    {
      'name': 'Sede Principal',
      'ip': '192.168.1.0/24',
      'devices': 45,
      'status': 'online',
    },
    {
      'name': 'Filial Norte',
      'ip': '192.168.2.0/24',
      'devices': 32,
      'status': 'online',
    },
    {
      'name': 'Filial Sul',
      'ip': '192.168.3.0/24',
      'devices': 28,
      'status': 'offline',
    },
    {
      'name': 'Centro de Distribuição',
      'ip': '192.168.4.0/24',
      'devices': 67,
      'status': 'online',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final palette = themeController.currentPalette;

      final filteredLocations =
          _locations.where((loc) {
            return loc['name'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();

      return Column(
        children: [
          // Header com estatísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total de Localizações',
                  _locations.length.toString(),
                  Icons.location_on,
                  palette['primary']!,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Online',
                  _locations
                      .where((l) => l['status'] == 'online')
                      .length
                      .toString(),
                  Icons.check_circle,
                  AppColors.success,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total de Dispositivos',
                  _locations
                      .fold(0, (sum, l) => sum + (l['devices'] as int))
                      .toString(),
                  Icons.devices,
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
                      hintText: 'Buscar localizações...',
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidade em desenvolvimento'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Nova Localização'),
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
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Lista de localizações
          Expanded(
            child: GridView.builder(
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

  Widget _buildLocationCard(
    Map<String, dynamic> location,
    bool isDark,
    Map<String, Color> palette,
  ) {
    final isOnline = location['status'] == 'online';

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
                      location['name'],
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
              Text(
                location['ip'],
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
                '${location['devices']} dispositivos',
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
                onPressed: () {},
                icon: Icon(Icons.edit, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: palette['primary']!.withOpacity(0.1),
                  foregroundColor: palette['primary'],
                ),
                tooltip: 'Editar',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
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
