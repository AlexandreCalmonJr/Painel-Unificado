import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/data/models/homelab_models.dart';

class BackupView extends StatelessWidget {
  const BackupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backupJobs = [
      BackupJob(
        name: 'Daily VM Snapshot',
        target: 'Local NAS',
        status: 'success',
        time: '03:00 AM',
      ),
      BackupJob(
        name: 'Photo Archive Sync',
        target: 'Cloud',
        status: 'running',
        time: 'In progress...',
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Estratégia 3-2-1',
                  '100%',
                  'Protegido',
                  LucideIcons.shield,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatCard(
                  'Último Backup Local',
                  '2h atrás',
                  'TrueNAS ZFS Snap',
                  LucideIcons.hardDrive,
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatCard(
                  'Nuvem (Offsite)',
                  '12h atrás',
                  'AWS S3 Glacier',
                  LucideIcons.cloud,
                  const Color(0xFFA855F7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Backup Jobs
          Container(
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
                  'Tarefas de Backup',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ...backupJobs.map(
                  (job) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617),
                      border: Border.all(color: const Color(0xFF1E293B)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                job.status == 'running'
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Destino: ${job.target}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          job.time,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
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
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Icon(icon, size: 24, color: color),
            ],
          ),
        ],
      ),
    );
  }
}
