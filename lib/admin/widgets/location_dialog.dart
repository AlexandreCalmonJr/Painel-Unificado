// File: lib/admin/widgets/location_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/location.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/utils/app_constants.dart';

class LocationDialog extends StatefulWidget {
  final Location? location; // null = create mode, non-null = edit mode
  final Function(Map<String, dynamic>) onSave;
  final AuthService authService;

  const LocationDialog({
    super.key,
    this.location,
    required this.onSave,
    required this.authService,
  });

  @override
  State<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  // Listas para múltiplos IPs
  final List<TextEditingController> _ipStartControllers = [];
  final List<TextEditingController> _ipEndControllers = [];

  // Unidades e BSSIDs
  List<Unit> _availableUnits = [];
  List<BssidMapping> _allBssids = [];
  final Set<String> _selectedUnitNames = {};
  final Set<String> _selectedBssidMacs = {};

  bool _isLoadingData = false;
  bool _isLoading = false;
  bool _showBssidSelector = false;

  final DeviceService _deviceService = DeviceService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.location?.description ?? '',
    );

    // Inicializa com os IPs existentes ou um campo vazio
    if (widget.location != null && widget.location!.ipRanges.isNotEmpty) {
      for (var range in widget.location!.ipRanges) {
        _ipStartControllers.add(TextEditingController(text: range.start));
        _ipEndControllers.add(TextEditingController(text: range.end));
      }
    } else {
      _addIpRange();
    }

    // Inicializa BSSIDs selecionados
    if (widget.location != null && widget.location!.bssids.isNotEmpty) {
      _selectedBssidMacs.addAll(widget.location!.bssids);
    }

    // Carrega dados do servidor
    _loadServerData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _ipStartControllers) {
      controller.dispose();
    }
    for (var controller in _ipEndControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadServerData() async {
    setState(() => _isLoadingData = true);
    try {
      final token = widget.authService.currentToken;
      if (token != null) {
        // Carrega unidades e BSSIDs em paralelo
        final results = await Future.wait([
          _deviceService.fetchUnits(token),
          _deviceService.fetchBssidMappings(token),
        ]);

        setState(() {
          _availableUnits = results[0] as List<Unit>;
          _allBssids = results[1] as List<BssidMapping>;
          _isLoadingData = false;

          // Debug detalhado
          print(
            '📊 Carregado: ${_availableUnits.length} unidades, ${_allBssids.length} BSSIDs',
          );
          print('   Unidades disponíveis:');
          for (var unit in _availableUnits) {
            final count =
                _allBssids
                    .where(
                      (b) =>
                          b.unitName.trim().toLowerCase() ==
                          unit.name.trim().toLowerCase(),
                    )
                    .length;
            print('     - "${unit.name}" → $count BSSIDs');
          }

          // Mostra BSSIDs com unidades não reconhecidas
          final uniqueBssidUnits =
              _allBssids
                  .map((b) => b.unitName)
                  .where((u) => u.isNotEmpty)
                  .toSet();
          final unitNames =
              _availableUnits.map((u) => u.name.trim().toLowerCase()).toSet();
          final unknownUnits =
              uniqueBssidUnits
                  .where(
                    (bssidUnit) =>
                        !unitNames.contains(bssidUnit.trim().toLowerCase()),
                  )
                  .toList();

          if (unknownUnits.isNotEmpty) {
            print('   ⚠️ BSSIDs com unidades não cadastradas:');
            for (var unknownUnit in unknownUnits) {
              final count =
                  _allBssids.where((b) => b.unitName == unknownUnit).length;
              print('     - "$unknownUnit" → $count BSSIDs');
            }
          }

          // Auto-seleciona unidades baseado nos BSSIDs já selecionados
          if (_selectedBssidMacs.isNotEmpty) {
            for (var mac in _selectedBssidMacs) {
              final bssid = _allBssids.firstWhere(
                (b) => b.macAddressRadio == mac,
                orElse:
                    () => BssidMapping(
                      macAddressRadio: mac,
                      sector: '',
                      floor: '',
                      unitName: '',
                    ),
              );
              if (bssid.unitName.isNotEmpty) {
                _selectedUnitNames.add(bssid.unitName);
              }
            }
          }
        });
      }
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _addIpRange() {
    setState(() {
      _ipStartControllers.add(TextEditingController());
      _ipEndControllers.add(TextEditingController());
    });
  }

  void _removeIpRange(int index) {
    if (_ipStartControllers.length > 1) {
      setState(() {
        _ipStartControllers[index].dispose();
        _ipEndControllers[index].dispose();
        _ipStartControllers.removeAt(index);
        _ipEndControllers.removeAt(index);
      });
    }
  }

  void _toggleUnitSelection(String unitName) {
    setState(() {
      if (_selectedUnitNames.contains(unitName)) {
        _selectedUnitNames.remove(unitName);
        // Remove BSSIDs desta unidade
        _selectedBssidMacs.removeWhere((mac) {
          final bssid = _allBssids.firstWhere(
            (b) => b.macAddressRadio == mac,
            orElse:
                () => BssidMapping(
                  macAddressRadio: '',
                  sector: '',
                  floor: '',
                  unitName: '',
                ),
          );
          return bssid.unitName == unitName;
        });
      } else {
        _selectedUnitNames.add(unitName);
      }
    });
  }

  void _toggleBssidSelection(String mac) {
    setState(() {
      if (_selectedBssidMacs.contains(mac)) {
        _selectedBssidMacs.remove(mac);
      } else {
        _selectedBssidMacs.add(mac);
      }
    });
  }

  /// Verifica se dois nomes de unidades são similares usando busca fuzzy
  bool _areUnitNamesSimilar(String name1, String name2) {
    // Normaliza os nomes
    final n1 = name1.trim().toLowerCase();
    final n2 = name2.trim().toLowerCase();

    // Exatamente iguais
    if (n1 == n2) return true;

    // Remove palavras comuns e pontuação
    final cleanName1 =
        n1
            .replaceAll(RegExp(r'[^\w\s]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
    final cleanName2 =
        n2
            .replaceAll(RegExp(r'[^\w\s]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

    // Exatamente iguais após limpeza
    if (cleanName1 == cleanName2) return true;

    // Verifica se um contém o outro (para abreviações)
    if (cleanName1.contains(cleanName2) || cleanName2.contains(cleanName1)) {
      return true;
    }

    // Divide em palavras e verifica palavras-chave em comum
    final words1 = cleanName1.split(' ').where((w) => w.length > 2).toSet();
    final words2 = cleanName2.split(' ').where((w) => w.length > 2).toSet();

    // Se não há palavras significativas, não são similares
    if (words1.isEmpty || words2.isEmpty) return false;

    // Conta palavras em comum
    final commonWords = words1.intersection(words2);

    // Se 70% ou mais das palavras são comuns, considera similar
    final similarity =
        commonWords.length / words1.length.clamp(1, double.infinity);

    return similarity >= 0.7;
  }

  List<BssidMapping> get _filteredBssids {
    if (_selectedUnitNames.isEmpty) {
      return _allBssids;
    }

    final filtered =
        _allBssids.where((bssid) {
          if (bssid.unitName.isEmpty) return false;

          // Tenta match exato primeiro
          final normalizedBssidUnit = bssid.unitName.trim().toLowerCase();
          final normalizedSelectedUnits =
              _selectedUnitNames
                  .map((name) => name.trim().toLowerCase())
                  .toSet();

          if (normalizedSelectedUnits.contains(normalizedBssidUnit)) {
            return true;
          }

          // Tenta match fuzzy
          for (var selectedUnit in _selectedUnitNames) {
            if (_areUnitNamesSimilar(selectedUnit, bssid.unitName)) {
              return true;
            }
          }

          return false;
        }).toList();

    // Debug: mostra informações sobre a filtragem
    if (filtered.isEmpty && _selectedUnitNames.isNotEmpty) {
      print('⚠️ Nenhum BSSID encontrado para as unidades selecionadas:');
      print('   Unidades selecionadas: $_selectedUnitNames');
      print('   Total de BSSIDs disponíveis: ${_allBssids.length}');
      print('   Unidades nos BSSIDs:');
      final uniqueUnits = _allBssids.map((b) => b.unitName).toSet();
      for (var unit in uniqueUnits) {
        final count = _allBssids.where((b) => b.unitName == unit).length;
        print('     - "$unit" ($count BSSIDs)');
      }
    }

    return filtered;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Coleta as faixas de IP
      final ipRanges = <Map<String, String>>[];
      for (int i = 0; i < _ipStartControllers.length; i++) {
        final start = _ipStartControllers[i].text.trim();
        final end = _ipEndControllers[i].text.trim();
        if (start.isNotEmpty) {
          ipRanges.add({'start': start, 'end': end.isEmpty ? start : end});
        }
      }

      final data = {
        'name': _nameController.text.trim(),
        'ip_ranges': ipRanges,
        'bssids': _selectedBssidMacs.toList(),
        'description': _descriptionController.text.trim(),
      };

      try {
        await widget.onSave(data);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final isEditMode = widget.location != null;

      return AlertDialog(
        backgroundColor:
            isDark ? AppColors.surface : AppColors.surfaceLightMode,
        title: Row(
          children: [
            Icon(
              isEditMode ? Icons.edit_location : Icons.add_location,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              isEditMode ? 'Editar Localização' : 'Nova Localização',
              style: TextStyle(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 750,
          child: Form(
            key: _formKey,
            child:
                _isLoadingData
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo Nome
                          TextFormField(
                            controller: _nameController,
                            enabled: !isEditMode,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimaryLight,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Nome da Localização *',
                              labelStyle: TextStyle(
                                color:
                                    isDark
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight,
                              ),
                              prefixIcon: Icon(
                                Icons.location_on,
                                color:
                                    isDark
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight,
                              ),
                              filled: true,
                              fillColor:
                                  isDark
                                      ? AppColors.background
                                      : AppColors.surfaceLightVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      isDark
                                          ? AppColors.border
                                          : AppColors.borderLight,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      isDark
                                          ? AppColors.border
                                          : AppColors.borderLight,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nome é obrigatório';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Seção de Faixas de IP
                          _buildSectionHeader(
                            'Faixas de IP',
                            Icons.router,
                            isDark,
                            onAdd: _addIpRange,
                          ),
                          const SizedBox(height: 12),

                          // Lista de faixas de IP
                          ...List.generate(_ipStartControllers.length, (index) {
                            return _buildIpRangeRow(index, isDark);
                          }),

                          const SizedBox(height: 24),

                          // Seção de Unidades
                          _buildSectionHeader(
                            'Unidades',
                            Icons.business,
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildUnitSelector(isDark),

                          const SizedBox(height: 24),

                          // Seção de BSSIDs
                          _buildSectionHeader(
                            'BSSIDs (WiFi)',
                            Icons.wifi,
                            isDark,
                            onToggle: () {
                              setState(
                                () => _showBssidSelector = !_showBssidSelector,
                              );
                            },
                            showToggle: true,
                            isExpanded: _showBssidSelector,
                            badge: _selectedBssidMacs.length,
                          ),
                          const SizedBox(height: 12),

                          // BSSIDs Selecionados
                          if (_selectedBssidMacs.isNotEmpty)
                            _buildSelectedBssidsChips(isDark),

                          // Mensagem informativa
                          if (_showBssidSelector) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Para cadastrar novos BSSIDs, vá até a página de Unidades e adicione os BSSIDs lá.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            isDark
                                                ? AppColors.textPrimary
                                                : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Seletor de BSSIDs
                          if (_showBssidSelector) ...[
                            const SizedBox(height: 12),
                            _buildBssidSelector(isDark),
                          ],

                          const SizedBox(height: 24),

                          // Campo Descrição
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimaryLight,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Descrição',
                              labelStyle: TextStyle(
                                color:
                                    isDark
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight,
                              ),
                              prefixIcon: Icon(
                                Icons.description,
                                color:
                                    isDark
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight,
                              ),
                              filled: true,
                              fillColor:
                                  isDark
                                      ? AppColors.background
                                      : AppColors.surfaceLightVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      isDark
                                          ? AppColors.border
                                          : AppColors.borderLight,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      isDark
                                          ? AppColors.border
                                          : AppColors.borderLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(isEditMode ? 'Salvar' : 'Criar'),
          ),
        ],
      );
    });
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    bool isDark, {
    VoidCallback? onAdd,
    VoidCallback? onToggle,
    bool showToggle = false,
    bool isExpanded = false,
    int? badge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                ),
              ),
              if (badge != null && badge > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Row(
            children: [
              if (showToggle)
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  color: AppColors.primary,
                  tooltip: isExpanded ? 'Ocultar' : 'Mostrar seletor',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (onAdd != null)
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  color: AppColors.primary,
                  tooltip: 'Adicionar',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIpRangeRow(int index, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _ipStartControllers[index],
              style: TextStyle(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: 'IP Inicial',
                hintText: '192.168.1.1',
                labelStyle: TextStyle(
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
                filled: true,
                fillColor:
                    isDark
                        ? AppColors.background
                        : AppColors.surfaceLightVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.border : AppColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.border : AppColors.borderLight,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _ipEndControllers[index],
              style: TextStyle(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: 'IP Final (opcional)',
                hintText: '192.168.1.255',
                labelStyle: TextStyle(
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
                filled: true,
                fillColor:
                    isDark
                        ? AppColors.background
                        : AppColors.surfaceLightVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.border : AppColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.border : AppColors.borderLight,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeIpRange(index),
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.danger,
            tooltip: 'Remover',
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector(bool isDark) {
    if (_availableUnits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.background : AppColors.surfaceLightVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color:
                  isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nenhuma unidade cadastrada no servidor.',
                style: TextStyle(
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.background : AppColors.surfaceLightVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            _availableUnits.map((unit) {
              // Usa comparação normalizada
              final normalizedUnitName = unit.name.trim().toLowerCase();
              final isSelected = _selectedUnitNames.any(
                (selected) =>
                    selected.trim().toLowerCase() == normalizedUnitName,
              );
              final bssidCount =
                  _allBssids.where((b) {
                    // Match exato
                    if (b.unitName.trim().toLowerCase() == normalizedUnitName) {
                      return true;
                    }
                    // Match fuzzy
                    return _areUnitNamesSimilar(unit.name, b.unitName);
                  }).length;

              return FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(unit.name),
                    if (bssidCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          bssidCount.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected ? AppColors.primary : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                avatar: Icon(
                  Icons.business,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                onSelected: (selected) => _toggleUnitSelection(unit.name),
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color:
                      isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSelectedBssidsChips(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.background : AppColors.surfaceLightVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            _selectedBssidMacs.map((mac) {
              final bssid = _allBssids.firstWhere(
                (b) => b.macAddressRadio == mac,
                orElse:
                    () => BssidMapping(
                      macAddressRadio: mac,
                      sector: '',
                      floor: '',
                      unitName: '',
                    ),
              );

              return Chip(
                avatar: const Icon(Icons.wifi, size: 16, color: Colors.white),
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mac,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (bssid.unitName.isNotEmpty)
                      Text(
                        '${bssid.unitName} • ${bssid.sector} • ${bssid.floor}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
                backgroundColor: AppColors.primary,
                deleteIcon: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
                onDeleted: () => _toggleBssidSelection(mac),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildBssidSelector(bool isDark) {
    final filteredBssids = _filteredBssids;

    if (filteredBssids.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.background : AppColors.surfaceLightVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color:
                  isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedUnitNames.isEmpty
                    ? 'Selecione uma unidade para ver os BSSIDs disponíveis.'
                    : 'Nenhum BSSID cadastrado para as unidades selecionadas.',
                style: TextStyle(
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Agrupa BSSIDs por unidade
    final bssidsByUnit = <String, List<BssidMapping>>{};
    for (var bssid in filteredBssids) {
      final unit = bssid.unitName.isEmpty ? 'Sem Unidade' : bssid.unitName;
      bssidsByUnit.putIfAbsent(unit, () => []).add(bssid);
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 350),
      decoration: BoxDecoration(
        color: isDark ? AppColors.background : AppColors.surfaceLightVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      child: ListView(
        shrinkWrap: true,
        children:
            bssidsByUnit.entries.map((entry) {
              final selectedCount =
                  entry.value
                      .where(
                        (b) => _selectedBssidMacs.contains(b.macAddressRadio),
                      )
                      .length;

              return ExpansionTile(
                initiallyExpanded: _selectedUnitNames.contains(entry.key),
                title: Row(
                  children: [
                    Icon(Icons.business, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isDark
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  '$selectedCount/${entry.value.length} selecionados',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                  ),
                ),
                children:
                    entry.value.map((bssid) {
                      final isSelected = _selectedBssidMacs.contains(
                        bssid.macAddressRadio,
                      );
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged:
                            (value) =>
                                _toggleBssidSelection(bssid.macAddressRadio),
                        title: Text(
                          bssid.macAddressRadio,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryLight,
                          ),
                        ),
                        subtitle: Text(
                          '${bssid.sector} • ${bssid.floor}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isDark
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryLight,
                          ),
                        ),
                        secondary: Icon(
                          Icons.wifi,
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight),
                        ),
                        activeColor: AppColors.primary,
                      );
                    }).toList(),
              );
            }).toList(),
      ),
    );
  }
}
