import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/data/models/homelab_models.dart';

class AssetImportPage extends StatefulWidget {
  const AssetImportPage({Key? key}) : super(key: key);

  @override
  State<AssetImportPage> createState() => _AssetImportPageState();
}

class _AssetImportPageState extends State<AssetImportPage> {
  String _activeTab = 'manual'; // 'manual' | 'import'
  List<AssetImportData> _importedData = [];
  String? _notification;
  String _notificationType = 'success';

  // Form controllers
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  String _selectedType = 'Printer';
  final _locationController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _locationController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _handleFileUpload() {
    // Simulação de upload de arquivo
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _importedData = [
          AssetImportData(
            name: 'HP LaserJet Pro M404',
            ip: '192.168.1.201',
            type: 'Printer',
            location: 'Office A',
            model: 'M404dn',
          ),
          AssetImportData(
            name: 'Canon ImageRunner',
            ip: '192.168.1.202',
            type: 'Printer',
            location: 'Hallway 2',
            model: 'ADV DX',
          ),
          AssetImportData(
            name: 'Brother MFC-L2710',
            ip: '192.168.1.203',
            type: 'Printer',
            location: 'Reception',
            model: 'L2710DW',
          ),
          AssetImportData(
            name: 'Zebra ZT411',
            ip: '192.168.1.205',
            type: 'Label Printer',
            location: 'Warehouse',
            model: 'ZT411',
          ),
        ];
        _showNotification(
          '${_importedData.length} ativos carregados da planilha!',
          'success',
        );
      });
    });
  }

  void _handleSave() {
    // Aqui você enviaria para o backend
    _showNotification(
      'Ativos cadastrados no banco de dados com sucesso!',
      'success',
    );
    setState(() {
      _importedData = [];
      _nameController.clear();
      _ipController.clear();
      _selectedType = 'Printer';
      _locationController.clear();
      _modelController.clear();
    });
  }

  void _showNotification(String message, String type) {
    setState(() {
      _notification = message;
      _notificationType = type;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _notification = null;
        });
      }
    });
  }

  void _removeImportedItem(int index) {
    setState(() {
      _importedData.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notification
        if (_notification != null)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  _notificationType == 'success'
                      ? const Color(0xFF064E3B).withOpacity(0.5)
                      : const Color(0xFF1E3A8A).withOpacity(0.5),
              border: Border.all(
                color:
                    _notificationType == 'success'
                        ? const Color(0xFF059669)
                        : const Color(0xFF3B82F6),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.checkCircle,
                  color:
                      _notificationType == 'success'
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3B82F6),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _notification!,
                    style: TextStyle(
                      color:
                          _notificationType == 'success'
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFDBEAFE),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 16),
                  color: Colors.white,
                  onPressed: () => setState(() => _notification = null),
                ),
              ],
            ),
          ),

        // Tabs
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
          ),
          child: Row(
            children: [
              _buildTab('manual', 'Cadastro Manual', LucideIcons.clipboardList),
              _buildTab(
                'import',
                'Importar Excel / CSV',
                LucideIcons.fileSpreadsheet,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Content
        Expanded(
          child:
              _activeTab == 'manual' ? _buildManualForm() : _buildImportView(),
        ),
      ],
    );
  }

  Widget _buildTab(String value, String label, IconData icon) {
    final isActive = _activeTab == value;
    return InkWell(
      onTap: () => setState(() => _activeTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF6366F1) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualForm() {
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
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
              'Novo Ativo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 380,
                  child: _buildFormField(
                    'Nome do Dispositivo',
                    _nameController,
                    'Ex: Impressora RH',
                  ),
                ),
                SizedBox(
                  width: 380,
                  child: _buildFormField(
                    'Endereço IP',
                    _ipController,
                    '192.168.x.x',
                  ),
                ),
                SizedBox(width: 380, child: _buildDropdownField()),
                SizedBox(
                  width: 380,
                  child: _buildFormField(
                    'Localização',
                    _locationController,
                    'Ex: Sala 101',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _handleSave,
                icon: const Icon(LucideIcons.save, size: 18),
                label: const Text('Salvar Ativo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF475569)),
            filled: true,
            fillColor: const Color(0xFF020617),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E293B)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E293B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TIPO',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedType,
          dropdownColor: const Color(0xFF020617),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF020617),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E293B)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E293B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items:
              ['Printer', 'Switch', 'Router', 'Camera', 'IoT Device']
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedType = value!),
        ),
      ],
    );
  }

  Widget _buildImportView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Upload Area
          InkWell(
            onTap: _handleFileUpload,
            child: Container(
              padding: const EdgeInsets.all(64),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.5),
                border: Border.all(
                  color: const Color(0xFF334155),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      LucideIcons.fileUp,
                      size: 32,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Arraste sua planilha aqui',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Suporta arquivos .xlsx, .xls ou .csv',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Modelo: Nome, IP, Tipo, Local, Modelo',
                    style: TextStyle(color: Color(0xFF475569), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Staging Table
          if (_importedData.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                border: Border.all(color: const Color(0xFF1E293B)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF020617),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF1E293B)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.table,
                              color: Color(0xFF10B981),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Pré-visualização (${_importedData.length} itens)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed:
                                  () => setState(() => _importedData = []),
                              child: const Text(
                                'Descartar',
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _handleSave,
                              icon: const Icon(
                                LucideIcons.checkCircle,
                                size: 14,
                              ),
                              label: const Text('Importar Tudo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                textStyle: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        const Color(0xFF020617),
                      ),
                      headingTextStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      dataRowColor: MaterialStateProperty.resolveWith(
                        (states) =>
                            states.contains(MaterialState.hovered)
                                ? const Color(0xFF1E293B).withOpacity(0.5)
                                : null,
                      ),
                      columns: const [
                        DataColumn(label: Text('NOME')),
                        DataColumn(label: Text('IP')),
                        DataColumn(label: Text('TIPO')),
                        DataColumn(label: Text('MODELO')),
                        DataColumn(label: Text('LOCAL')),
                        DataColumn(label: Text('AÇÃO')),
                      ],
                      rows:
                          _importedData.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    item.ip,
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    item.type,
                                    style: const TextStyle(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    item.model,
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    item.location,
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.trash2,
                                      size: 14,
                                    ),
                                    color: const Color(0xFF64748B),
                                    hoverColor: const Color(0xFFEF4444),
                                    onPressed: () => _removeImportedItem(idx),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
