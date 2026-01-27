import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/data/models/homelab_models.dart';

class InfrastructureView extends StatelessWidget {
  const InfrastructureView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subnets = [
      IPAMSubnet(
        id: 1,
        name: 'LAN Principal',
        cidr: '192.168.1.0/24',
        usage: 85,
        vlan: 10,
        gateway: '192.168.1.1',
      ),
      IPAMSubnet(
        id: 2,
        name: 'IoT Devices',
        cidr: '192.168.20.0/24',
        usage: 42,
        vlan: 20,
        gateway: '192.168.20.1',
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
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
                const Text(
                  'IPAM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ...subnets.map(
                  (subnet) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617),
                      border: Border.all(color: const Color(0xFF1E293B)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              subnet.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              subnet.cidr,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'VLAN ${subnet.vlan}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Gateway: ${subnet.gateway}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
              children: const [
                Text(
                  'Rack',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Visualização de rack indisponível.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
