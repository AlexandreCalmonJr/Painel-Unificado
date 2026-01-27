import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/data/models/homelab_models.dart';

class FileManagerView extends StatefulWidget {
  const FileManagerView({Key? key}) : super(key: key);

  @override
  State<FileManagerView> createState() => _FileManagerViewState();
}

class _FileManagerViewState extends State<FileManagerView> {
  final List<FileItem> _files = [
    FileItem(
      name: 'backup_config_2024.zip',
      size: '45MB',
      date: '2024-01-20',
      isDir: false,
    ),
    FileItem(
      name: 'documentos_importantes',
      size: '-',
      date: '2024-01-15',
      isDir: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: const Color(0xFF1E293B)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      LucideIcons.folder,
                      color: Color(0xFF818CF8),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Gerenciador de Arquivos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Nova Pasta'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF334155)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.upload, size: 16),
                      label: const Text('Upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // File List
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  const Color(0xFF1E293B).withOpacity(0.5),
                ),
                headingTextStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                dataRowColor: MaterialStateProperty.resolveWith(
                  (states) =>
                      states.contains(MaterialState.hovered)
                          ? const Color(0xFF1E293B).withOpacity(0.5)
                          : null,
                ),
                columns: const [
                  DataColumn(label: Text('Nome')),
                  DataColumn(label: Text('Tamanho')),
                  DataColumn(label: Text('Data')),
                  DataColumn(label: Text('Ações')),
                ],
                rows:
                    _files.map((file) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Icon(
                                  file.isDir
                                      ? LucideIcons.folder
                                      : LucideIcons.file,
                                  color:
                                      file.isDir
                                          ? const Color(0xFFFBBF24)
                                          : const Color(0xFF3B82F6),
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  file.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              file.size,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              file.date,
                              style: const TextStyle(color: Color(0xFF94A3B8)),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(LucideIcons.download, size: 16),
                              color: const Color(0xFF94A3B8),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
