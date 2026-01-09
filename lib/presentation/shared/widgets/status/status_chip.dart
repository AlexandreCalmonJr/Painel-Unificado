import 'package:flutter/material.dart';

/// Widget de chip de status reutilizável
class StatusChip extends StatelessWidget {

  const StatusChip({
    super.key,
    required this.status,
    this.color,
    this.icon,
    this.showIcon = true,
  });

  /// Factory para criar chip baseado em status de dispositivo
  factory StatusChip.fromDeviceStatus(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'online':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'offline':
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      case 'maintenance':
      case 'manutenção':
        color = Colors.orange;
        icon = Icons.build_outlined;
        break;
      case 'retired':
      case 'aposentado':
        color = Colors.purple;
        icon = Icons.archive_outlined;
        break;
      case 'collected':
      case 'recolhido':
        color = Colors.blue;
        icon = Icons.inventory_2_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return StatusChip(status: status, color: color, icon: icon);
  }
  final String status;
  final Color? color;
  final IconData? icon;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && icon != null) ...[
            Icon(icon, size: 14, color: chipColor),
            const SizedBox(width: 6),
          ],
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
