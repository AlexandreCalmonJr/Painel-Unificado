// File: lib/admin/tabs/admin_apk_manager_tab.dart
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class AdminApkManagerTab extends StatefulWidget {
  final AuthService authService;

  const AdminApkManagerTab({super.key, required this.authService});

  @override
  State<AdminApkManagerTab> createState() => _AdminApkManagerTabState();
}

class _AdminApkManagerTabState extends State<AdminApkManagerTab> {
  List<Map<String, dynamic>> apks = [];
  bool isLoading = false;
  bool isUploading = false;
  double uploadProgress = 0.0;
  String? uploadingFileName;

  @override
  void initState() {
    super.initState();
    _loadApks();
  }

  Future<void> _loadApks() async {
    setState(() => isLoading = true);
    try {
      final config = ServerConfigService.instance.loadConfig();
      final url = 'http://${config['ip']}:${config['port']}/api/server/apks';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.authService.currentToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          apks = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        _showSnackbar('Erro ao carregar APKs: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackbar('Erro: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _uploadApk() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['apk'],
      );

      if (result == null) return;

      setState(() {
        isUploading = true;
        uploadProgress = 0.0;
        uploadingFileName = result.files.single.name;
      });

      final config = ServerConfigService.instance.loadConfig();
      final url = 'http://${config['ip']}:${config['port']}/api/server/upload-apk';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer ${widget.authService.currentToken}';

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'apk',
          result.files.single.bytes!,
          filename: result.files.single.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'apk',
          result.files.single.path!,
          filename: result.files.single.name,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _showSnackbar('APK enviado com sucesso!');
        await _loadApks();
      } else {
        final error = jsonDecode(response.body);
        _showSnackbar('Erro: ${error['message'] ?? response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackbar('Erro ao enviar APK: $e', isError: true);
    } finally {
      setState(() {
        isUploading = false;
        uploadProgress = 0.0;
        uploadingFileName = null;
      });
    }
  }

  Future<void> _deleteApk(String fileName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmar Exclusão'),
          ],
        ),
        content: Text('Deseja realmente excluir "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final config = ServerConfigService.instance.loadConfig();
      final url = 'http://${config['ip']}:${config['port']}/api/server/apks/${Uri.encodeComponent(fileName)}';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.authService.currentToken}',
        },
      );

      if (response.statusCode == 200) {
        _showSnackbar('APK excluído com sucesso!');
        await _loadApks();
      } else {
        final error = jsonDecode(response.body);
        _showSnackbar('Erro: ${error['message'] ?? response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackbar('Erro ao excluir APK: $e', isError: true);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.blue.shade50],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.android, color: Colors.green, size: 32),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gerenciamento de APKs',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Envie e gerencie aplicativos para dispositivos Android',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Upload Button
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enviar novo APK',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Selecione um arquivo .apk para enviar ao servidor',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: isUploading ? null : _uploadApk,
                        icon: Icon(
                          isUploading ? Icons.hourglass_empty : Icons.upload_file,
                          color: Colors.white,
                        ),
                        label: Text(isUploading ? 'Enviando...' : 'Selecionar APK'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Upload Progress
              if (isUploading) ...[
                SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Enviando: $uploadingFileName',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 16),

              // APK List
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.folder_open, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'APKs Disponíveis',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${apks.length} arquivo(s)',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                    if (isLoading)
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (apks.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                'Nenhum APK disponível',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Envie um arquivo APK para começar',
                                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: apks.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final apk = apks[index];
                          return ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.android, color: Colors.green, size: 24),
                            ),
                            title: Text(
                              apk['name'] ?? 'Unknown',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text('Tamanho: ${_formatBytes(apk['size'] ?? 0)}'),
                                if (apk['lastModified'] != null)
                                  Text(
                                    'Modificado: ${DateTime.parse(apk['lastModified']).toLocal().toString().split('.')[0]}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.link, color: Colors.blue),
                                  tooltip: 'Copiar URL',
                                  onPressed: () {
                                    // TODO: Implementar copiar URL
                                    _showSnackbar('URL: ${apk['url']}');
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Excluir',
                                  onPressed: () => _deleteApk(apk['name']),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}