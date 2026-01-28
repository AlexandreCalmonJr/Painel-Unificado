import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Badge de status com cores dinâmicas baseadas no estado
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  Map<String, Color> get _colorMap => {
    'online': const Color(0xFF10B981),
    'offline': const Color(0xFFEF4444),
    'running': const Color(0xFF3B82F6),
    'active': const Color(0xFF10B981),
    'loaded': const Color(0xFFA855F7),
    'downloaded': const Color(0xFF64748B),
    'downloading': const Color(0xFFF59E0B),
    'compliant': const Color(0xFF10B981),
    'non-compliant': const Color(0xFFEF4444),
    'stopped': const Color(0xFF64748B),
  };

  Color get _backgroundColor =>
      (_colorMap[status] ?? const Color(0xFF64748B)).withOpacity(0.1);
  Color get _borderColor =>
      (_colorMap[status] ?? const Color(0xFF64748B)).withOpacity(0.2);
  Color get _textColor => _colorMap[status] ?? const Color(0xFF64748B);

  bool get _isActive =>
      ['online', 'running', 'active', 'compliant', 'loaded'].contains(status);
  bool get _isDownloading => status == 'downloading';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color:
                  _isActive
                      ? _textColor
                      : _isDownloading
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            child:
                _isDownloading
                    ? const SizedBox(
                      width: 6,
                      height: 6,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFF59E0B),
                        ),
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: _textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de estatística com ícone, valor, progresso e subtexto
class StatWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final Color colorClass;
  final double? percent;

  const StatWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.colorClass,
    this.percent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: const Color(0xFF1E293B)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: colorClass),
              ),
            ],
          ),
          if (percent != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (percent! / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorClass,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ] else
            const SizedBox(height: 16),
          Text(
            subtext,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Gráfico de barras simples para visualizações
class SimpleBarChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;

  const SimpleBarChart({
    Key? key,
    required this.data,
    this.color = const Color(0xFF6366F1),
    this.height = 96,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children:
            data.map((val) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: FractionallySizedBox(
                    alignment: Alignment.bottomCenter,
                    heightFactor: (val / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.7),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

/// Toast de notificação flutuante
class NotificationToast extends StatelessWidget {
  final String title;
  final String message;
  final String level; // 'error', 'success', 'info'
  final VoidCallback onClose;

  const NotificationToast({
    Key? key,
    required this.title,
    required this.message,
    required this.level,
    required this.onClose,
  }) : super(key: key);

  Color get _backgroundColor {
    switch (level) {
      case 'error':
        return const Color(0xFF7F1D1D).withOpacity(0.9);
      case 'success':
        return const Color(0xFF064E3B).withOpacity(0.9);
      default:
        return const Color(0xFF1E293B);
    }
  }

  Color get _borderColor {
    switch (level) {
      case 'error':
        return const Color(0xFFB91C1C);
      case 'success':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF334155);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            level == 'error' ? LucideIcons.alertTriangle : LucideIcons.bell,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 16),
            color: Colors.white,
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Item de menu lateral com badge e estado ativo
class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onClick;
  final int badgeCount;
  final Color badgeColor;
  final bool isCollapsed;

  const SidebarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onClick,
    this.badgeCount = 0,
    this.badgeColor = const Color(0xFFEF4444),
    this.isCollapsed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isCollapsed ? label : '',
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF4F46E5) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment:
                isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? Colors.white : const Color(0xFF94A3B8),
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: active ? Colors.white : const Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
