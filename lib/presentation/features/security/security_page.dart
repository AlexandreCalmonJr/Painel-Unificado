import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSecurityCard(
            'Firewall',
            'Ativo',
            LucideIcons.shield,
            const Color(0xFF10B981),
            true,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSecurityCard(
            'VPN',
            'WireGuard Online',
            LucideIcons.lock,
            const Color(0xFF3B82F6),
            true,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSecurityCard(
            'SSL',
            'Expira em 12 dias',
            LucideIcons.key,
            const Color(0xFFF59E0B),
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard(
    String title,
    String status,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isActive)
                Icon(LucideIcons.checkCircle, color: color, size: 16),
              if (isActive) const SizedBox(width: 8),
              Text(status, style: TextStyle(color: color, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
