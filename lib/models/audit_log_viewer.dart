// File: lib/widgets/audit_log_viewer.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/models/audit_log.dart'; // Presumido
import 'package:painel_windowns/services/auth_service.dart'; // Presumido
import 'package:painel_windowns/services/server_config_service.dart'; // Presumido

class AuditLogViewer extends StatelessWidget {
  final String assetId;
  final AuthService authService;

  const AuditLogViewer({
    Key? key, // ✅ Adicionado Key
    required this.assetId,
    required this.authService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AuditLog>>(
      future: _fetchAuditLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar histórico: ${snapshot.error}'));
        }

        final logs = snapshot.data ?? [];

        if (logs.isEmpty) {
          return const Center(child: Text('Nenhuma alteração registrada'));
        }

        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildLogEntry(log);
          },
        );
      },
    );
  }

  Widget _buildLogEntry(AuditLog log) {
    IconData icon;
    Color color;

    switch (log.action) {
      case 'created':
        icon = Icons.add_circle_outline;
        color = Colors.green;
        break;
      case 'updated':
        icon = Icons.edit_outlined;
        color = Colors.blue;
        break;
      case 'deleted':
        icon = Icons.delete_outline;
        color = Colors.red;
        break;
      case 'status_changed':
        icon = Icons.swap_horiz;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(_getActionDescription(log)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (log.field != null) ...[
              const SizedBox(height: 4),
              Text('Campo: ${log.field}'),
              if (log.oldValue != null && log.newValue != null)
                Text(
                  '${log.oldValue} → ${log.newValue}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
            ],
            const SizedBox(height: 4),
            Text(
              'Por ${log.username} em ${_formatDateTime(log.timestamp)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _getActionDescription(AuditLog log) {
    switch (log.action) {
      case 'created':
        return 'Ativo criado';
      case 'updated':
        return 'Ativo atualizado';
      case 'deleted':
        return 'Ativo excluído';
      case 'status_changed':
        return 'Status alterado';
      default:
        return log.action;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<List<AuditLog>> _fetchAuditLogs() async {
    final config = ServerConfigService.instance.loadConfig();
    final response = await http.get(
      Uri.parse(
          'http://${config['ip']}:${config['port']}/api/assets/$assetId/audit-log'),
      headers: {'Authorization': 'Bearer ${authService.currentToken}'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['logs'] as List)
          .map((json) => AuditLog.fromJson(json))
          .toList();
    }

    throw Exception('Erro ao carregar histórico');
  }
}