import 'package:flutter/material.dart';

enum StatusType { asset, device, user }

/// Widget de chip de status reutilizável
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.status, super.key,
    this.color,
    this.icon,
    this.showIcon = true,
    this.type,
    this.isCompact = false,
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

    return StatusChip(
      status: status,
      color: color,
      icon: icon,
      type: StatusType.device,
    );
  }
  final String status;
  final Color? color;
  final IconData? icon;
  final bool showIcon;
  final StatusType? type;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.grey;
    final fontSize = isCompact ? 10.0 : 11.0;
    final padding =
        isCompact
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    final iconSize = isCompact ? 12.0 : 14.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && icon != null) ...[
            Icon(icon, size: iconSize, color: chipColor),
            SizedBox(width: isCompact ? 4 : 6),
          ],
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
