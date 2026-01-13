// File: lib/admin/tabs/admin_apk_manager_tab.dart (REDESIGNED)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';
import 'package:painel_windowns/services/auth_service.dart';


class AdminApkManagerTab extends StatefulWidget {
  const AdminApkManagerTab({required this.authService, super.key});
  final AuthService authService;

  @override
  State<AdminApkManagerTab> createState() => _AdminApkManagerTabState();
}

class _AdminApkManagerTabState extends State<AdminApkManagerTab> {
  String _searchQuery = '';

  // Dados de exemplo
  final List<Map<String, dynamic>> _apks = [
    {
      'name': 'MDM Client',
      'package': 'com.company.mdm.client',
      'version': '3.2.1',
      'versionCode': 321,
      'size': '12.5 MB',
      'uploadDate': '2025-01-15',
      'downloads': 145,
      'status': 'active',
    },
    {
      'name': 'Inventory Scanner',
      'package': 'com.company.inventory',
      'version': '2.0.8',
      'versionCode': 208,
      'size': '8.3 MB',
      'uploadDate': '2025-01-10',
      'downloads': 89,
      'status': 'active',
    },
    {
      'name': 'Field Service',
      'package': 'com.company.field',
      'version': '1.9.2',
      'versionCode': 192,
      'size': '15.7 MB',
      'uploadDate': '2024-12-28',
      'downloads': 67,
      'status': 'deprecated',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final palette = themeController.currentPalette;

      final filteredApks =
          _apks.where((apk) {
            return apk['name'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                apk['package'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();

      final totalSize = _apks.fold(0.0, (sum, apk) {
        final sizeStr = apk['size'].toString().replaceAll(' MB', '');
        return sum + double.parse(sizeStr);
      });

      final totalDownloads = _apks.fold(
        0,
        (sum, apk) => sum + (apk['downloads'] as int),
      );

      return Column(
        children: [
          // Header com estatísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total de APKs',
                  _apks.length.toString(),
                  Icons.android,
                  palette['primary']!,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Downloads Totais',
                  totalDownloads.toString(),
                  Icons.download,
                  AppColors.success,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Espaço Total',
                  '${totalSize.toStringAsFixed(1)} MB',
                  Icons.storage,
                  palette['accent']!,
                  isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Barra de busca e upload
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
                      hintText: 'Buscar APKs...',
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
                        content: Text(
                          'Funcionalidade de upload em desenvolvimento',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_file, size: 20),
                  label: const Text('Upload APK'),
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

          // Lista de APKs
          Expanded(
            child: ListView.builder(
              itemCount: filteredApks.length,
              itemBuilder: (context, index) {
                final apk = filteredApks[index];
                return _buildApkCard(apk, isDark, palette);
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

  Widget _buildApkCard(
    Map<String, dynamic> apk,
    bool isDark,
    Map<String, Color> palette,
  ) {
    final isActive = apk['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Ícone do APK
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [palette['primary']!, palette['accent']!],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.android, color: Colors.white, size: 32),
          ),

          const SizedBox(width: 20),

          // Informações do APK
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        apk['name'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Ativo' : 'Descontinuado',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              isActive ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  apk['package'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.tag,
                      'v${apk['version']} (${apk['versionCode']})',
                      isDark,
                    ),
                    _buildInfoChip(Icons.storage, apk['size'] as String, isDark),
                    _buildInfoChip(
                      Icons.download,
                      '${apk['downloads']} downloads',
                      isDark,
                    ),
                    _buildInfoChip(
                      Icons.calendar_today,
                      apk['uploadDate'] as String,
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Ações
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: palette['primary']!.withOpacity(0.1),
                  foregroundColor: palette['primary'],
                ),
                tooltip: 'Download',
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.info_outline, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.info.withOpacity(0.1),
                  foregroundColor: AppColors.info,
                ),
                tooltip: 'Detalhes',
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete, size: 20),
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

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color:
              isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color:
                isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
