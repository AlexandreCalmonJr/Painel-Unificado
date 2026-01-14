# Script PowerShell para migrar widgets GetX para BLoC

$widgets = @(
    "lib\presentation\shared\widgets\cards\managed_assets_card.dart",
    "lib\presentation\shared\widgets\cards\unified_managed_assets_card.dart",
    "lib\presentation\shared\widgets\tables\base_data_table.dart",
    "lib\presentation\shared\widgets\navigation\unified_menu_item.dart",
    "lib\presentation\shared\widgets\dialogs\user_dialog.dart",
    "lib\presentation\features\admin\widgets\admin_locations_tab.dart",
    "lib\presentation\features\admin\widgets\admin_modules_tab.dart",
    "lib\presentation\features\admin\widgets\admin_users_tab.dart"
)

foreach ($widget in $widgets) {
    $fullPath = "c:\Users\Administrator\Painel-Unificado\$widget"
    Write-Host "Migrando: $widget"
    
    # Ler conteúdo
    $content = Get-Content $fullPath -Raw
    
    # Substituir imports
    $content = $content -replace "import 'package:get/get\.dart';", "import 'package:flutter_bloc/flutter_bloc.dart';"
    $content = $content -replace "import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller\.dart';", "import 'package:painel_windowns/core/utils/theme_utils.dart';`nimport 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';`nimport 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';"
    
    # Substituir Obx por BlocBuilder
    $content = $content -replace "return Obx\(\(\) \{", "return BlocBuilder<ThemeCubit, ThemeState>(builder: (context, themeState) {"
    $content = $content -replace "Obx\(\(\) \{", "BlocBuilder<ThemeCubit, ThemeState>(builder: (context, themeState) {"
    
    # Substituir ThemeController.to
    $content = $content -replace "final themeController = ThemeController\.to;[\r\n\s]+final isDark = themeController\.isDarkMode;[\r\n\s]+final palette = themeController\.currentPalette;", "final isDark = themeState.effectiveDarkMode;`n      final palette = ColorPalettes.getPalette(themeState.config.colorScheme);"
    $content = $content -replace "final themeController = ThemeController\.to;[\r\n\s]+final isDark = themeController\.isDarkMode;", "final isDark = themeState.effectiveDarkMode;"
    $content = $content -replace "ThemeController\.to\.currentPalette", "ColorPalettes.getPalette(context.read<ThemeCubit>().state.config.colorScheme)"
    $content = $content -replace "ThemeController\.to\.isDarkMode", "context.read<ThemeCubit>().state.effectiveDarkMode"
    
    # Salvar
    Set-Content $fullPath -Value $content -NoNewline
    Write-Host "✓ Migrado: $widget"
}

Write-Host "`n✅ Migração concluída!"
