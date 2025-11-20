// File: lib/widgets/common/status_chip.dart
import 'package:flutter/material.dart';

/// Tipo de entidade para determinar cores e comportamento do status
enum StatusType {
  device,
  asset,
  totem,
}

/// Widget reutilizável para exibir status com cores consistentes
class StatusChip extends StatelessWidget {
  final String status;
  final StatusType type;
  final bool isCompact;

  const StatusChip({
    super.key,
    required this.status,
    this.type = StatusType.device,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status.toLowerCase(), type);

    return Container(
      padding: isCompact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: isCompact ? 14 : 16,
            color: config.color,
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: isCompact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status, StatusType type) {
    // Status comuns a todos os tipos
    switch (status) {
      case 'online':
        return _StatusConfig(
          label: 'Online',
          color: const Color(0xFF4CAF50),
          icon: Icons.check_circle,
        );
      case 'offline':
        return _StatusConfig(
          label: 'Offline',
          color: const Color(0xFF9E9E9E),
          icon: Icons.cancel,
        );
      case 'maintenance':
      case 'manutenção':
        return _StatusConfig(
          label: 'Manutenção',
          color: const Color(0xFFFF9800),
          icon: Icons.build,
        );
      case 'collected':
      case 'recolhido':
        return _StatusConfig(
          label: 'Recolhido',
          color: const Color(0xFF9C27B0),
          icon: Icons.inventory,
        );
      case 'production':
      case 'produção':
        return _StatusConfig(
          label: 'Produção',
          color: const Color(0xFF2196F3),
          icon: Icons.factory,
        );
      case 'inactive':
      case 'inativo':
        return _StatusConfig(
          label: 'Inativo',
          color: const Color(0xFF757575),
          icon: Icons.power_off,
        );
      case 'active':
      case 'ativo':
        return _StatusConfig(
          label: 'Ativo',
          color: const Color(0xFF4CAF50),
          icon: Icons.check_circle_outline,
        );
      default:
        return _StatusConfig(
          label: status.toUpperCase(),
          color: const Color(0xFF607D8B),
          icon: Icons.help_outline,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}
