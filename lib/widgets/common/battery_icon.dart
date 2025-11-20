// File: lib/widgets/common/battery_icon.dart
import 'package:flutter/material.dart';

/// Widget reutilizável para ícone de bateria com nível
class BatteryIcon extends StatelessWidget {
  final num? batteryLevel;
  final bool showPercentage;
  final double size;

  const BatteryIcon({
    super.key,
    required this.batteryLevel,
    this.showPercentage = false,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (batteryLevel == null) {
      return Icon(
        Icons.battery_unknown,
        size: size,
        color: Colors.grey,
      );
    }

    final level = batteryLevel!.toDouble();
    final config = _getBatteryConfig(level);

    if (showPercentage) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: size,
            color: config.color,
          ),
          const SizedBox(width: 4),
          Text(
            '${level.toInt()}%',
            style: TextStyle(
              fontSize: size * 0.7,
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Icon(
      config.icon,
      size: size,
      color: config.color,
    );
  }

  _BatteryConfig _getBatteryConfig(double level) {
    if (level >= 80) {
      return _BatteryConfig(
        icon: Icons.battery_full,
        color: const Color(0xFF4CAF50),
      );
    } else if (level >= 60) {
      return _BatteryConfig(
        icon: Icons.battery_6_bar,
        color: const Color(0xFF8BC34A),
      );
    } else if (level >= 40) {
      return _BatteryConfig(
        icon: Icons.battery_4_bar,
        color: const Color(0xFFFFC107),
      );
    } else if (level >= 20) {
      return _BatteryConfig(
        icon: Icons.battery_2_bar,
        color: const Color(0xFFFF9800),
      );
    } else {
      return _BatteryConfig(
        icon: Icons.battery_1_bar,
        color: const Color(0xFFF44336),
      );
    }
  }
}

class _BatteryConfig {
  final IconData icon;
  final Color color;

  _BatteryConfig({
    required this.icon,
    required this.color,
  });
}
