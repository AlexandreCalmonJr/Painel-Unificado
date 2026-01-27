import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProvisioningPage extends StatefulWidget {
   ProvisioningPage({super.key});

  @override
  State<ProvisioningPage> createState() => _ProvisioningPageState();
}

class _ProvisioningPageState extends State<ProvisioningPage> {
  String _deviceType = 'mobile'; // 'mobile', 'desktop', 'server'
  final String _enrollToken = 'NX-7823-99XA-K2L1';

  void _copyToken() {
    Clipboard.setData(ClipboardData(text: _enrollToken));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token copiado para a área de transferência'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel - Device Type Selection
        SizedBox(
          width: 320,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  border: Border.all(color: const Color(0xFF1E293B)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de Dispositivo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDeviceTypeButton(
                      'mobile',
                      'Smartphone / Tablet',
                      LucideIcons.smartphone,
                    ),
                    const SizedBox(height: 8),
                    _buildDeviceTypeButton(
                      'desktop',
                      'Desktop Workstation',
                      LucideIcons.monitor,
                    ),
                    const SizedBox(height: 8),
                    _buildDeviceTypeButton(
                      'server',
                      'Linux Server / Node',
                      LucideIcons.server,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  border: Border.all(color: const Color(0xFF1E293B)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOKEN DE INSCRIÇÃO',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF020617),
                        border: Border.all(color: const Color(0xFF1E293B)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _enrollToken,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.copy, size: 14),
                            color: const Color(0xFF94A3B8),
                            onPressed: _copyToken,
                            tooltip: 'Copiar',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Válido por 24 horas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        // Right Panel - Provisioning Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(64),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border.all(color: const Color(0xFF1E293B)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildProvisioningContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceTypeButton(String type, String label, IconData icon) {
    final isActive = _deviceType == type;
    return InkWell(
      onTap: () => setState(() => _deviceType = type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvisioningContent() {
    switch (_deviceType) {
      case 'mobile':
        return _buildMobileProvisioning();
      case 'desktop':
        return _buildDesktopProvisioning();
      case 'server':
        return _buildServerProvisioning();
      default:
        return const SizedBox();
    }
  }

  Widget _buildMobileProvisioning() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.qrCode,
              color: Color(0xFF818CF8),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Escaneie para Conectar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Abra a câmara do dispositivo para provisionar.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: QrImageView(
              data: 'nexus://enroll?token=$_enrollToken',
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopProvisioning() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.downloadCloud,
              color: Color(0xFF60A5FA),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Instalar Agente Desktop',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Baixe o agente para Windows ou macOS.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDownloadCard(
                'Windows (.msi)',
                LucideIcons.monitor,
                const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 16),
              _buildDownloadCard(
                'macOS (.dmg)',
                LucideIcons.laptop,
                const Color(0xFFA855F7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServerProvisioning() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.terminal,
              color: Color(0xFF34D399),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Via Terminal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Execute o comando no servidor Linux.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          const SizedBox(height: 32),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              border: Border.all(color: const Color(0xFF1E293B)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    'curl -sfL https://get.nexus.local/agent.sh | sudo sh -s -- --token $_enrollToken',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.copy, size: 16),
                  color: const Color(0xFF94A3B8),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            'curl -sfL https://get.nexus.local/agent.sh | sudo sh -s -- --token $_enrollToken',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comando copiado'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.5),
          border: Border.all(color: const Color(0xFF334155)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
