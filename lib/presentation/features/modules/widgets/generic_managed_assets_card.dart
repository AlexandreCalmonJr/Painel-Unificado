// File: lib/modules/widgets/generic_managed_assets_card.dart
// MIGRADO PARA USAR BaseDataTable MANTENDO COLUNAS DINÂMICAS ORIGINAIS

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';
import 'package:painel_windowns/presentation/features/modules/pages/asset_detail_screen.dart';
import 'package:painel_windowns/presentation/features/modules/widgets/asset_command_controls_v2.dart';
import 'package:painel_windowns/presentation/shared/widgets/status/status_chip.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/base_card.dart';
import 'package:painel_windowns/presentation/shared/widgets/data_table/base_data_table.dart';
import 'package:painel_windowns/presentation/shared/widgets/texts/app_text_styles.dart';
import 'package:painel_windowns/presentation/shared/widgets/theme_controller.dart';


class GenericManagedAssetsCard extends StatelessWidget {

  const GenericManagedAssetsCard({
    super.key,
    required this.title,
    required this.assets,
    required this.columns,
    required this.moduleConfig,
    required this.authService,
    required this.onAssetChanged,
    this.showActions = false,
    this.expand = false,
  });
  final String title;
  final List<ManagedAsset> assets;
  final List<TableColumnConfig> columns;
  final AssetModuleConfig moduleConfig;
  final bool showActions;
  final AuthService authService;
  final VoidCallback onAssetChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final textColor = isDark ? Colors.white : Colors.black;

      return BaseCard(
        title: title,
        expandChild: expand,
        actions: [
          if (showActions)
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Baixar CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                textStyle: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
              ),
            ),
        ],
        child:
            assets.isEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum ativo encontrado.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : BaseDataTable<ManagedAsset>(
                  items: assets,
                  columns:
                      columns.map((col) {
                        return DataTableColumn<ManagedAsset>(
                          label: col.label, // MANTÉM O NOME ORIGINAL DA COLUNA
                          builder: (asset) {
                            final assetData = asset.toJson();
                            final dataKey = col.dataKey;

                            // Tratamento especial para sector_floor
                            if (dataKey == 'sector_floor') {
                              return _buildSectorFloorCell(
                                assetData,
                                textColor,
                              );
                            }

                            final value = assetData[dataKey];

                            // Célula clicável para hostname/asset_name
                            if (dataKey == 'hostname' ||
                                dataKey == 'asset_name') {
                              return InkWell(
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AssetDetailScreen(
                                              asset: asset,
                                              authService: authService,
                                              moduleConfig: moduleConfig,
                                            ),
                                      ),
                                    ),
                                child: Text(
                                  value?.toString() ?? 'N/D',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }

                            // Célula de status com chip
                            if (dataKey == 'status') {
                              return StatusChip(
                                status: value?.toString() ?? 'unknown',
                                type: StatusType.asset,
                                isCompact: true,
                              );
                            }

                            // Células padrão
                            return Text(
                              value?.toString() ?? 'N/D',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        );
                      }).toList(),
                  actions:
                      showActions
                          ? [
                            TableAction<ManagedAsset>(
                              icon: Icons.more_vert,
                              label: 'Ações',
                              onTap: (asset) {}, // Placeholder
                            ),
                          ]
                          : null,
                  customRow:
                      showActions
                          ? (asset) => AssetCommandControlsV2(
                            asset: asset,
                            assetType: moduleConfig.id,
                            token: authService.currentToken ?? '',
                            authService: authService,
                            onCommandExecuted: onAssetChanged,
                          )
                          : null,
                  showPagination: false,
                ),
      );
    });
  }

  Widget _buildSectorFloorCell(
    Map<String, dynamic> assetData,
    Color textColor,
  ) {
    String displayValue;

    if (assetData.containsKey('sector_floor') &&
        assetData['sector_floor'] != null &&
        assetData['sector_floor'].toString().isNotEmpty) {
      displayValue = assetData['sector_floor'].toString();
    } else {
      final sector = assetData['sector']?.toString() ?? 'N/D';
      final floor = assetData['floor']?.toString() ?? 'N/D';
      displayValue = '$sector / $floor';
    }

    return Text(
      displayValue,
      style: AppTextStyles.bodySmall.copyWith(color: textColor),
      overflow: TextOverflow.ellipsis,
    );
  }
}
