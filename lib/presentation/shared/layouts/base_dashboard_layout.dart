import 'package:flutter/material.dart';

/// Dados para um card de estatística
class StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });
}

/// Layout base reutilizável para todos os dashboards
///
/// Este widget elimina a duplicação de código entre os diferentes dashboards
/// (devices, totems, modules, admin) fornecendo uma estrutura comum.
class BaseDashboardLayout extends StatelessWidget {
  final String title;
  final List<StatCardData> stats;
  final Widget mainContent;
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;
  final Widget? floatingActionButton;
  final bool showStats;

  const BaseDashboardLayout({
    super.key,
    required this.title,
    required this.stats,
    required this.mainContent,
    this.actions,
    this.onRefresh,
    this.floatingActionButton,
    this.showStats = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showStats && stats.isNotEmpty) ...[
          _buildStatsRow(context),
          const SizedBox(height: 24),
        ],
        Expanded(child: mainContent),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: floatingActionButton,
      body:
          onRefresh != null
              ? RefreshIndicator(
                onRefresh: onRefresh!,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: content,
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: content,
              ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    // Responsivo: ajusta número de colunas baseado na largura
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200 ? 4 : (width > 800 ? 3 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _buildStatCard(stats[index]),
    );
  }

  Widget _buildStatCard(StatCardData data) {
    final color = data.color ?? Colors.blue;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        data.subtitle!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
