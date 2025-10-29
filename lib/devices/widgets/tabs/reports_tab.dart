import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:painel_windowns/devices/utils/helpers.dart';
import 'package:painel_windowns/devices/widgets/managed_devices_card.dart';
import 'package:painel_windowns/models/device.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:synchronized/synchronized.dart';

class ReportsTab extends StatefulWidget {
  final List<Device> devices;
  final AuthService authService;
  final Map<String, dynamic>? currentUser;

  const ReportsTab({
    super.key,
    required this.devices,
    required this.authService,
    required this.currentUser,
  });

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> with TickerProviderStateMixin {
  int? _touchedPieIndex;
  String? _selectedStatusFilter;
  List<Device> _filteredDevices = [];
  final bool _showFilteredDevices = true; // Tabela sempre visível agora
  List<Device> _devicesForReport = [];
  String _selectedTimeRange = '24h';
  bool _isLoading = false;

  // Cache para estatísticas
  final Map<String, Map<String, int>> _statsCache = {};
  final _lock = Lock();
  DateTime? _lastCacheUpdate;

  late AnimationController _chartAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _chartAnimation;
  late Animation<double> _cardsAnimation;

  static const List<String> _statusOrder = ['Online', 'Offline', 'Manutenção', 'Sem Monitorar'];
  static const Map<String, Color> _statusColors = {
    'Online': Color(0xFF4CAF50),
    'Offline': Color(0xFFF44336),
    'Manutenção': Color(0xFF607D8B),
    'Sem Monitorar': Color(0xFF9E9E9E),
  };

  static const Map<String, Color> _statusGradientColors = {
    'Online': Color(0xFF66BB6A),
    'Offline': Color(0xFFEF5350),
    'Manutenção': Color(0xFF78909C),
    'Sem Monitorar': Color(0xFFB0BEC5),
  };

  static const List<String> _timeRanges = ['1h', '6h', '24h', '7d', '30d'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _filterDevicesForCurrentUser();
    _startAnimations();
    _updateCache();
  }

  void _initializeAnimations() {
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeInOutCubic,
    );
    
    _cardsAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeInOutQuart,
    );
  }

  void _startAnimations() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cardsAnimationController.forward();
        _chartAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReportsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.devices != oldWidget.devices || widget.currentUser != oldWidget.currentUser) {
      _filterDevicesForCurrentUser();
      _updateCache();
    }
  }

  Future<void> _updateCache() async {
    await _lock.synchronized(() {
      final now = DateTime.now();
      if (_lastCacheUpdate == null || now.difference(_lastCacheUpdate!) > const Duration(minutes: 1)) {
        _statsCache[_selectedTimeRange] = _calculateDeviceStats();
        _lastCacheUpdate = now;
      }
    });
  }

void _filterDevicesForCurrentUser() {
  final userRole = widget.currentUser?['role'];
  final userSectorPrefixes = widget.currentUser?['sector'];

  debugPrint('=== DEBUG FILTRO - Role: $userRole, Sector: $userSectorPrefixes ===');

  if (userRole == 'user' && userSectorPrefixes != null && userSectorPrefixes.isNotEmpty) {
    final prefixes = userSectorPrefixes.split(',')
        .map((p) => p.trim().toLowerCase())
        .where((p) => p.isNotEmpty)
        .toList();
    
    debugPrint('Prefixos: $prefixes');
    debugPrint('Total dispositivos recebidos: ${widget.devices.length}');

    _devicesForReport = widget.devices.where((device) {
      final deviceName = device.deviceName?.toLowerCase() ?? '';
      final match = prefixes.any((prefix) => deviceName.contains(prefix)); // Mudança: contains em vez de startsWith
      if (match) debugPrint('Match: ${device.deviceName} -> $prefixes');
      return match;
    }).toList();
    
    debugPrint('Após filtro: ${_devicesForReport.length} dispositivos');
  } else {
    _devicesForReport = widget.devices;
    debugPrint('Admin: Todos os dispositivos (${_devicesForReport.length})');
  }

  _clearFilter();
  if (mounted) setState(() {});
}

  void _onPieSectionTouched(FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
    final isValidTouch = event.isInterestedForInteractions && pieTouchResponse?.touchedSection != null;
    if (!isValidTouch) {
      _clearFilter();
      return;
    }
    final touchedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
    if (touchedIndex == -1 || touchedIndex >= _statusOrder.length) {
      _clearFilter();
      return;
    }
    setState(() {
      _touchedPieIndex = touchedIndex;
      _selectedStatusFilter = _statusOrder[touchedIndex];
      _updateFilteredDeviceList();
    });
  }

  void _clearFilter() {
    if (_touchedPieIndex != null) {
      setState(() {
        _touchedPieIndex = null;
        _selectedStatusFilter = null;
        _filteredDevices = _devicesForReport; // Mostra todos os dispositivos
      });
    }
  }

  void _updateFilteredDeviceList() {
    _filteredDevices = _selectedStatusFilter == null
        ? _devicesForReport
        : _devicesForReport.where((device) => _getDeviceStatus(device) == _selectedStatusFilter).toList();
  }

  String _getDeviceStatus(Device device) {
    if (device.maintenanceStatus ?? false) return 'Manutenção';
    if (!isDeviceOnline(parseLastSeen(device.lastSeen), parseLastSync(device.lastSync))) return 'Offline';
    return 'Online';
  }

  bool isDeviceOnline(DateTime? lastSeen, DateTime? lastSync) {
    final now = DateTime.now();
    final latest = lastSync != null && lastSync.isAfter(lastSeen ?? DateTime(0)) ? lastSync : lastSeen;
    return latest != null && now.difference(latest).inMinutes < 45;
  }

  DateTime? parseLastSync(String? lastSync) {
    return lastSync != null ? DateTime.tryParse(lastSync) : null;
  }

  Map<String, int> _calculateDeviceStats() {
    return _statsCache[_selectedTimeRange] ??= {
      for (var status in _statusOrder) status: _devicesForReport.where((d) => _getDeviceStatus(d) == status).length,
    };
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500)); // Simula carregamento
    setState(() {
      _clearFilter();
      _isLoading = false;
      _updateCache();
    });
    _cardsAnimationController.reset();
    _chartAnimationController.reset();
    _startAnimations();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _calculateDeviceStats();
    final total = _devicesForReport.length;

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: theme.primaryColor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 16),
                  _buildTimeRangeSelector(theme),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Total de Dispositivos: $total', style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildStatsOverview(stats, total, theme),
                  const SizedBox(height: 24),
                  _buildOverallStatusPieChart(stats, total, theme),
                  const SizedBox(height: 24),
                  _buildInsightsCard(stats, total, theme),
                  const SizedBox(height: 24),
                  _buildPerformanceMetrics(stats, total, theme),
                  const SizedBox(height: 24),
                  _buildFilteredDevicesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) => AnimatedBuilder(
        animation: _cardsAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 50 * (1 - _cardsAnimation.value)),
          child: Opacity(
            opacity: _cardsAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor.withOpacity(0.1), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.analytics_outlined, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Relatórios e Análises',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          'Monitoramento em tempo real da sua frota',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildTimeRangeSelector(ThemeData theme) => AnimatedBuilder(
        animation: _cardsAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 30 * (1 - _cardsAnimation.value)),
          child: Opacity(
            opacity: _cardsAnimation.value,
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _timeRanges.length,
                itemBuilder: (context, index) {
                  final range = _timeRanges[index];
                  final isSelected = range == _selectedTimeRange;
                  return GestureDetector(
                    onTap: () {
                      if (!isSelected) {
                        setState(() {
                          _selectedTimeRange = range;
                          _updateCache();
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: index < _timeRanges.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[300]!),
                      ),
                      child: Text(
                        range,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

  Widget _buildStatsOverview(Map<String, int> stats, int total, ThemeData theme) => AnimatedBuilder(
        animation: _cardsAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 40 * (1 - _cardsAnimation.value)),
          child: Opacity(
            opacity: _cardsAnimation.value,
            child: Row(
              children: [
                Expanded(child: _buildStatCard('Total', total.toString(), Icons.devices, Colors.blue, theme)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Online', (stats['Online'] ?? 0).toString(), Icons.check_circle, _statusColors['Online']!, theme)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Offline', (stats['Offline'] ?? 0).toString(), Icons.error, _statusColors['Offline']!, theme)),
              ],
            ),
          ),
        ),
      );

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
          ],
        ),
      );

  Widget _buildReportCard({
    required String title,
    required Widget child,
    IconData? icon,
    List<Widget>? actions,
    required ThemeData theme,
  }) =>
      Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: theme.primaryColor, size: 20),
                      ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
                    if (actions != null) ...actions,
                  ],
                ),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      );

  Widget _buildOverallStatusPieChart(Map<String, int> stats, int total, ThemeData theme) => AnimatedBuilder(
        animation: _chartAnimation,
        builder: (context, child) => Transform.scale(
          scale: _chartAnimation.value,
          child: _buildReportCard(
            title: 'Status dos Dispositivos',
            icon: Icons.pie_chart_outline,
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('Toque para filtrar', style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
            child: Column(
              children: [
                SizedBox(
                  height: 240,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(touchCallback: _onPieSectionTouched),
                      sectionsSpace: 3,
                      centerSpaceRadius: 60,
                      sections: _buildPieChartSections(stats),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLegend(stats, total, theme),
              ],
            ),
            theme: theme,
          ),
        ),
      );

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> statusCounts) => _statusOrder.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final count = statusCounts[status] ?? 0;
        final isTouched = index == _touchedPieIndex;
        return PieChartSectionData(
          color: _statusColors[status]!,
          value: count.toDouble(),
          title: count > 0 ? count.toString() : '',
          radius: isTouched ? 80.0 : 70.0,
          titleStyle: TextStyle(fontSize: isTouched ? 18 : 16, fontWeight: FontWeight.bold, color: Colors.white, shadows: const [Shadow(color: Colors.black26, blurRadius: 2)]),
          badgeWidget: isTouched ? _buildBadge(status, count) : null,
          badgePositionPercentageOffset: 1.3,
          gradient: LinearGradient(colors: [_statusColors[status]!, _statusGradientColors[status]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
        );
      }).toList();

  Widget _buildBadge(String status, int count) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
            Text(count.toString(), style: TextStyle(color: _statusColors[status], fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _buildLegend(Map<String, int> statusCounts, int total, ThemeData theme) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
        child: Wrap(
          spacing: 20,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _statusOrder.map((status) {
            final count = statusCounts[status] ?? 0;
            final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _statusColors[status]!.withOpacity(0.3))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: _statusColors[status], shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('$status: $count ($percentage%)', style: TextStyle(fontWeight: FontWeight.w500, color: theme.textTheme.bodyMedium?.color)),
                ],
              ),
            );
          }).toList(),
        ),
      );

  Widget _buildInsightsCard(Map<String, int> stats, int total, ThemeData theme) {
    if (_devicesForReport.isEmpty) return const SizedBox.shrink();
    final onlineCount = stats['Online'] ?? 0;
    final offlineCount = stats['Offline'] ?? 0;
    final maintenanceCount = stats['Manutenção'] ?? 0;
    final onlinePercent = total > 0 ? (onlineCount / total * 100).toStringAsFixed(0) : '0';

    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 50 * (1 - _cardsAnimation.value)),
        child: Opacity(
          opacity: _cardsAnimation.value,
          child: _buildReportCard(
            title: 'Insights Inteligentes',
            icon: Icons.psychology,
            child: Column(
              children: [
                _buildInsightTile(
                  icon: Icons.trending_up,
                  color: _getHealthColor(int.parse(onlinePercent)),
                  title: 'Status da Frota: ${_getHealthStatus(int.parse(onlinePercent))}',
                  subtitle: '$onlinePercent% online - ${_getOnlineInsight(int.parse(onlinePercent))}',
                  progress: int.parse(onlinePercent) / 100,
                  theme: theme,
                ),
                const SizedBox(height: 16),
                _buildInsightTile(
                  icon: _getOfflineIcon(offlineCount),
                  color: _getOfflineWarningColor(offlineCount),
                  title: _getOfflineTitle(offlineCount),
                  subtitle: _getOfflineInsight(offlineCount),
                  showAlert: offlineCount > 5,
                  theme: theme,
                ),
                if (maintenanceCount > 0) ...[
                  const SizedBox(height: 16),
                  _buildInsightTile(
                    icon: Icons.build_circle,
                    color: Colors.orange,
                    title: '$maintenanceCount em manutenção',
                    subtitle: 'Indisponíveis para uso temporário.',
                    theme: theme,
                  ),
                ],
              ],
            ),
            theme: theme,
          ),
        ),
      ),
    );
  }

  Widget _buildInsightTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    double? progress,
    bool showAlert = false,
    required ThemeData theme,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textTheme.bodyLarge?.color))),
                      if (showAlert)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                          child: const Text('ATENÇÃO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color)),
                  ],
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildPerformanceMetrics(Map<String, int> stats, int total, ThemeData theme) {
    final onlineCount = stats['Online'] ?? 0;
    final uptime = total > 0 ? (onlineCount / total * 100) : 0.0;

    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 60 * (1 - _cardsAnimation.value)),
        child: Opacity(
          opacity: _cardsAnimation.value,
          child: _buildReportCard(
            title: 'Métricas de Performance',
            icon: Icons.speed,
            child: Column(
              children: [
                _buildMetricRow('Uptime da Frota', '${uptime.toStringAsFixed(1)}%', uptime / 100, Colors.green, theme),
                const SizedBox(height: 16),
                _buildMetricRow('Dispositivos Ativos', '$onlineCount de $total', total > 0 ? onlineCount / total : 0, Colors.blue, theme),
                const SizedBox(height: 16),
                _buildMetricRow('Taxa de Falha', '${(100 - uptime).toStringAsFixed(1)}%', total > 0 ? (total - onlineCount) / total : 0, Colors.red, theme),
              ],
            ),
            theme: theme,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, double progress, Color color, ThemeData theme) => Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color)), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color)),
        ],
      );

  String _getHealthStatus(int percentage) {
    if (percentage >= 95) return 'Excelente';
    if (percentage >= 85) return 'Muito Bom';
    if (percentage >= 70) return 'Bom';
    if (percentage >= 50) return 'Regular';
    return 'Crítico';
  }

  Color _getHealthColor(int percentage) {
    if (percentage >= 85) return Colors.green;
    if (percentage >= 70) return Colors.lightGreen;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getOnlineInsight(int percentage) {
    if (percentage >= 95) return 'Sistema em excelência!';
    if (percentage >= 85) return 'Performance satisfatória.';
    if (percentage >= 70) return 'Maioria online.';
    if (percentage >= 50) return 'Atenção necessária.';
    return 'Intervenção urgente!';
  }

  String _getOfflineTitle(int offlineCount) {
    if (offlineCount == 0) return 'Todos conectados';
    if (offlineCount == 1) return '1 desconectado';
    return '$offlineCount desconectados';
  }

  String _getOfflineInsight(int offlineCount) {
    if (offlineCount == 0) return 'Comunicação total!';
    if (offlineCount <= 3) return 'Poucos precisam de atenção.';
    if (offlineCount <= 10) return 'Verificação recomendada.';
    return 'Alto número offline!';
  }

  IconData _getOfflineIcon(int offlineCount) {
    if (offlineCount == 0) return Icons.check_circle;
    if (offlineCount <= 5) return Icons.info_outline;
    return Icons.warning_amber_rounded;
  }

  Color _getOfflineWarningColor(int offlineCount) {
    if (offlineCount == 0) return Colors.green;
    if (offlineCount <= 5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildFilteredDevicesSection() => AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: SizedBox(
          height: 400,
          child: ManagedDevicesCard(
            title: 'Dispositivos: ${_selectedStatusFilter ?? 'Todos'} (${_filteredDevices.length})',
            devices: _filteredDevices,
            authService: widget.authService,
            showActions: true,
            token: widget.authService.currentToken,
            currentUser: widget.authService.currentUser,
            onDeviceUpdate: () => setState(() => _updateFilteredDeviceList()),
          ),
        ),
      );
}