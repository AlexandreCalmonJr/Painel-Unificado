import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/presentation/widgets/common_widgets.dart';

class MonitoringView extends StatelessWidget {
  const MonitoringView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border.all(color: const Color(0xFF1E293B)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(LucideIcons.cpu, color: Color(0xFF818CF8), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'CPU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SimpleBarChart(
                  data: const [20, 40, 60, 30, 50, 45],
                  color: const Color(0xFF6366F1),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border.all(color: const Color(0xFF1E293B)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      LucideIcons.activity,
                      color: Color(0xFFA855F7),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'RAM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SimpleBarChart(
                  data: const [60, 65, 62, 68, 70, 72],
                  color: const Color(0xFFA855F7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
