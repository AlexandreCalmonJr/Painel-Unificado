// File: lib/widgets/interactive_charts.dart
import 'package:fl_chart/fl_chart.dart'; // Necessário para PieChart, BarChart, etc.
import 'package:flutter/material.dart'; // Necessário para Widgets, Colors, etc.
import 'package:painel_windowns/models/asset_module_base.dart'; // Import presumido

class AssetStatusChart extends StatelessWidget {
  final List<ManagedAsset> assets;

  const AssetStatusChart({Key? key, required this.assets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusData = _calculateStatusData();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Status dos Ativos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: statusData['online']!.toDouble(),
                      title: 'Online\n${statusData['online']}',
                      color: Colors.green,
                      radius: 100,
                    ),
                    PieChartSectionData(
                      value: statusData['offline']!.toDouble(),
                      title: 'Offline\n${statusData['offline']}',
                      color: Colors.red,
                      radius: 100,
                    ),
                    PieChartSectionData(
                      value: statusData['maintenance']!.toDouble(),
                      title: 'Manutenção\n${statusData['maintenance']}',
                      color: Colors.orange,
                      radius: 100,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _calculateStatusData() {
    return {
      'online': assets.where((a) => a.status == 'online').length,
      'offline': assets.where((a) => a.status == 'offline').length,
      'maintenance': assets.where((a) => a.status == 'maintenance').length,
    };
  }
}

class LocationHeatmap extends StatelessWidget {
  final List<ManagedAsset> assets;

  const LocationHeatmap({Key? key, required this.assets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locationData = _groupByLocation();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Distribuição por Localização',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: locationData.entries.map((entry) {
                    final index = locationData.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final location =
                              locationData.keys.elementAt(value.toInt());
                          return Text(location, style: TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    // Oculta os títulos da esquerda, topo e direita
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _groupByLocation() {
    final Map<String, int> grouped = {};

    for (final asset in assets) {
      final key = '${asset.unit ?? 'N/D'}-${asset.sector ?? 'N/D'}';
      grouped[key] = (grouped[key] ?? 0) + 1;
    }

    return grouped;
  }
}