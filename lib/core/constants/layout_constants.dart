// File: lib/core/constants/layout_constants.dart
/// Constantes de layout para garantir consistência visual em toda a aplicação
class LayoutConstants {
  // Prevent instantiation
  LayoutConstants._();

  // ============================================================================
  // SPACING SYSTEM
  // ============================================================================

  /// Extra small spacing (4px) - Para espaçamentos mínimos
  static const double spaceXS = 4.0;

  /// Small spacing (8px) - Para espaçamentos pequenos entre elementos relacionados
  static const double spaceS = 8.0;

  /// Medium spacing (16px) - Espaçamento padrão entre elementos
  static const double spaceM = 16.0;

  /// Large spacing (24px) - Para separação de seções
  static const double spaceL = 24.0;

  /// Extra large spacing (32px) - Para grandes separações
  static const double spaceXL = 32.0;

  /// Extra extra large spacing (48px) - Para separações principais
  static const double spaceXXL = 48.0;

  // ============================================================================
  // CARD SYSTEM
  // ============================================================================

  /// Padding interno padrão dos cards
  static const double cardPadding = 20.0;

  /// Margem externa padrão dos cards
  static const double cardMargin = 16.0;

  /// Border radius padrão dos cards
  static const double cardRadius = 16.0;

  /// Border radius pequeno para elementos menores
  static const double cardRadiusSmall = 12.0;

  /// Border radius grande para elementos destacados
  static const double cardRadiusLarge = 20.0;

  /// Elevação padrão dos cards
  static const double cardElevation = 2.0;

  /// Elevação para cards em hover
  static const double cardElevationHover = 8.0;

  // ============================================================================
  // GRID SYSTEM
  // ============================================================================

  /// Largura máxima do conteúdo principal
  static const double maxContentWidth = 1400.0;

  /// Número de colunas no grid para desktop
  static const int gridColumnsDesktop = 12;

  /// Número de colunas no grid para tablet
  static const int gridColumnsTablet = 8;

  /// Número de colunas no grid para mobile
  static const int gridColumnsMobile = 4;

  /// Espaçamento entre colunas do grid
  static const double gridGutter = 16.0;

  // ============================================================================
  // BREAKPOINTS
  // ============================================================================

  /// Breakpoint para mobile (até 600px)
  static const double breakpointMobile = 600.0;

  /// Breakpoint para tablet (601px - 900px)
  static const double breakpointTablet = 900.0;

  /// Breakpoint para desktop (901px - 1200px)
  static const double breakpointDesktop = 1200.0;

  /// Breakpoint para desktop large (acima de 1200px)
  static const double breakpointDesktopLarge = 1200.0;

  // ============================================================================
  // COMPONENT SIZES
  // ============================================================================

  /// Altura padrão de botões
  static const double buttonHeight = 48.0;

  /// Altura de botões pequenos
  static const double buttonHeightSmall = 36.0;

  /// Altura de botões grandes
  static const double buttonHeightLarge = 56.0;

  /// Altura padrão de inputs
  static const double inputHeight = 48.0;

  /// Altura do AppBar
  static const double appBarHeight = 70.0;

  /// Largura da sidebar
  static const double sidebarWidth = 280.0;

  /// Largura da sidebar colapsada
  static const double sidebarWidthCollapsed = 80.0;

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  /// Tamanho de ícone extra small
  static const double iconSizeXS = 16.0;

  /// Tamanho de ícone small
  static const double iconSizeS = 20.0;

  /// Tamanho de ícone medium (padrão)
  static const double iconSizeM = 24.0;

  /// Tamanho de ícone large
  static const double iconSizeL = 32.0;

  /// Tamanho de ícone extra large
  static const double iconSizeXL = 48.0;

  /// Tamanho de ícone extra extra large
  static const double iconSizeXXL = 64.0;

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  /// Duração curta para animações rápidas (150ms)
  static const Duration animationDurationShort = Duration(milliseconds: 150);

  /// Duração média para animações padrão (250ms)
  static const Duration animationDurationMedium = Duration(milliseconds: 250);

  /// Duração longa para animações complexas (400ms)
  static const Duration animationDurationLong = Duration(milliseconds: 400);

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Retorna o número de colunas baseado na largura da tela
  static int getGridColumns(double width) {
    if (width >= breakpointDesktop) return gridColumnsDesktop;
    if (width >= breakpointTablet) return gridColumnsTablet;
    return gridColumnsMobile;
  }

  /// Verifica se é mobile
  static bool isMobile(double width) => width < breakpointMobile;

  /// Verifica se é tablet
  static bool isTablet(double width) =>
      width >= breakpointMobile && width < breakpointDesktop;

  /// Verifica se é desktop
  static bool isDesktop(double width) => width >= breakpointDesktop;

  /// Retorna padding responsivo baseado na largura
  static double getResponsivePadding(double width) {
    if (isMobile(width)) return spaceM;
    if (isTablet(width)) return spaceL;
    return spaceXL;
  }

  /// Retorna espaçamento entre cards baseado na largura
  static double getCardSpacing(double width) {
    if (isMobile(width)) return spaceM;
    return spaceL;
  }
}
