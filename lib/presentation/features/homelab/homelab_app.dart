import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/presentation/features/ai/ai_view.dart';
import 'package:painel_windowns/presentation/features/apps/app_manager_view.dart';
import 'package:painel_windowns/presentation/features/assets/asset_import_view.dart';
import 'package:painel_windowns/presentation/features/backup/backup_view.dart';
import 'package:painel_windowns/presentation/features/cctv/cctv_view.dart';
import 'package:painel_windowns/presentation/features/commands/commands_view.dart';
import 'package:painel_windowns/presentation/features/containers/containers_view.dart';
// Import all views
import 'package:painel_windowns/presentation/features/dashboard/dashboard_home_view.dart';
import 'package:painel_windowns/presentation/features/files/file_manager_view.dart';
import 'package:painel_windowns/presentation/features/infrastructure/infrastructure_view.dart';
import 'package:painel_windowns/presentation/features/mdm/mdm_view.dart';
import 'package:painel_windowns/presentation/features/modules/modules_view.dart';
import 'package:painel_windowns/presentation/features/monitoring/monitoring_view.dart';
import 'package:painel_windowns/presentation/features/power/power_view.dart';
import 'package:painel_windowns/presentation/features/provisioning/provisioning_view.dart';
import 'package:painel_windowns/presentation/features/security/security_view.dart';
import 'package:painel_windowns/presentation/features/settings/settings_view.dart';
import 'package:painel_windowns/presentation/features/workstations/workstations_view.dart';
import 'package:painel_windowns/presentation/widgets/common_widgets.dart';

class HomelabApp extends StatefulWidget {
  const HomelabApp({super.key});

  @override
  State<HomelabApp> createState() => _HomelabAppState();
}

class _HomelabAppState extends State<HomelabApp> {
  String _currentView = 'dashboard';
  final List<dynamic> _mockDevices = [
    {'name': 'Proxmox Node 01', 'ip': '192.168.1.10', 'status': 'online'},
    {'name': 'TrueNAS Core', 'ip': '192.168.1.20', 'status': 'online'},
  ];

  final Map<String, Map<String, dynamic>> _menuItems = {
    'dashboard': {
      'label': 'Dashboard',
      'icon': LucideIcons.layoutDashboard,
      'badge': 0,
    },
    'assets': {
      'label': 'Cadastro & Import',
      'icon': LucideIcons.clipboardList,
      'badge': 0,
    },
    'ai': {
      'label': 'Inteligência Artificial',
      'icon': LucideIcons.brainCircuit,
      'badge': 0,
    },
    'power': {'label': 'Energia (UPS)', 'icon': LucideIcons.zap, 'badge': 0},
    'files': {'label': 'Arquivos', 'icon': LucideIcons.folder, 'badge': 0},
    'cctv': {'label': 'Câmeras', 'icon': LucideIcons.camera, 'badge': 0},
    'backup': {'label': 'Backups', 'icon': LucideIcons.hardDrive, 'badge': 0},
    'commands': {
      'label': 'Comandos Remotos',
      'icon': LucideIcons.terminal,
      'badge': 0,
    },
    'provisioning': {
      'label': 'Provisionamento',
      'icon': LucideIcons.qrCode,
      'badge': 0,
    },
    'monitoring': {
      'label': 'Monitoramento',
      'icon': LucideIcons.activity,
      'badge': 0,
    },
    'security': {'label': 'Segurança', 'icon': LucideIcons.shield, 'badge': 0},
    'infrastructure': {
      'label': 'Infraestrutura',
      'icon': LucideIcons.network,
      'badge': 0,
    },
    'workstations': {
      'label': 'Workstations',
      'icon': LucideIcons.monitor,
      'badge': 0,
    },
    'apps': {'label': 'Aplicações', 'icon': LucideIcons.box, 'badge': 0},
    'containers': {
      'label': 'Containers',
      'icon': LucideIcons.container,
      'badge': 4,
    },
    'modules': {'label': 'Módulos', 'icon': LucideIcons.box, 'badge': 0},
    'mdm': {
      'label': 'Mobile (MDM)',
      'icon': LucideIcons.smartphone,
      'badge': 0,
    },
    'settings': {
      'label': 'Configurações',
      'icon': LucideIcons.settings,
      'badge': 0,
    },
  };

  Widget _getCurrentView() {
    switch (_currentView) {
      case 'dashboard':
        return DashboardHomeView(devices: _mockDevices);
      case 'assets':
        return const AssetImportView();
      case 'ai':
        return const AIView();
      case 'power':
        return const PowerView();
      case 'files':
        return const FileManagerView();
      case 'cctv':
        return const CCTVView();
      case 'backup':
        return const BackupView();
      case 'commands':
        return const CommandsView();
      case 'provisioning':
        return const ProvisioningView();
      case 'monitoring':
        return const MonitoringView();
      case 'security':
        return const SecurityView();
      case 'infrastructure':
        return const InfrastructureView();
      case 'workstations':
        return const WorkstationsView();
      case 'apps':
        return const AppManagerView();
      case 'containers':
        return const ContainersView();
      case 'modules':
        return const ModulesView();
      case 'mdm':
        return const MDMView();
      case 'settings':
        return const SettingsView();
      default:
        return DashboardHomeView(devices: _mockDevices);
    }
  }

  String _getViewTitle() {
    return _menuItems[_currentView]?['label'] as String? ?? 'Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(right: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              children: [
                // Logo/Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF1E293B)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withOpacity(0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.server,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Homelab',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Items
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            'NAVEGAÇÃO',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        ..._menuItems.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: SidebarItem(
                              icon: entry.value['icon'] as IconData,
                              label: entry.value['label'] as String,
                              active: _currentView == entry.key,
                              onClick:
                                  () =>
                                      setState(() => _currentView = entry.key),
                              badgeCount: entry.value['badge'] as int,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // User Profile
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          LucideIcons.user,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin User',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'admin@homelab.local',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF1E293B)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getViewTitle(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Homelab Management System',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(LucideIcons.bell),
                            color: const Color(0xFF94A3B8),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(LucideIcons.search),
                            color: const Color(0xFF94A3B8),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    child: _getCurrentView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
