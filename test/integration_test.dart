// Arquivo: test/integration_test.dart
// Testes de integração para o Painel Flutter

import 'package:flutter_test/flutter_test.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/asset_command_service.dart';
import 'package:painel_windowns/services/asset_maintenance_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

void main() {
  group('🧪 Testes de Integração do Painel', () {
    late AuthService authService;
    late ModuleManagementService moduleService;
    late AssetCommandService commandService;
    late AssetMaintenanceService maintenanceService;

    String? testModuleId;
    String? testAssetId;

    setUpAll(() async {
      // Configurar servidor
      final config = ServerConfigService.instance;
      await config.saveConfig('localhost', '3000');

      // Inicializar serviços
      authService = AuthService();
      moduleService = ModuleManagementService(authService: authService);
      commandService = AssetCommandService(authService: authService);
      maintenanceService = AssetMaintenanceService(authService: authService);

      print('\n📝 Configuração inicial concluída');
    });

    test('1️⃣ Login no sistema', () async {
      final result = await authService.login('admin', 'admin123');

      expect(result['success'], isTrue, reason: 'Login deve ser bem-sucedido');
      expect(authService.isLoggedIn, isTrue);
      expect(authService.currentToken, isNotNull);

      print('✅ Login realizado com sucesso');
      print('   Token: ${authService.currentToken?.substring(0, 20)}...');
    });

    test('2️⃣ Criar módulo de teste', () async {
      final module = await moduleService.createModule(
        name: 'Teste Flutter Desktop',
        type:
            AssetModuleType.desktop, // ✅ CORRIGIDO: Usar enum em vez de String
        description: 'Módulo criado por teste automático',
        tableColumns: [
          {'dataKey': 'assetName', 'label': 'Nome'},
          {'dataKey': 'serialNumber', 'label': 'Serial'},
        ],
      );

      expect(module, isNotNull);
      testModuleId = module.id; // ✅ CORRIGIDO: Usar propriedade do objeto
      expect(testModuleId, isNotNull);

      print('✅ Módulo criado: $testModuleId');
    });

    test('3️⃣ Listar módulos', () async {
      final modules =
          await moduleService
              .listModules(); // ✅ CORRIGIDO: Nome correto do método

      expect(modules, isNotEmpty);
      expect(modules.any((m) => m.id == testModuleId), isTrue);

      print('✅ Módulos listados: ${modules.length} encontrados');
    });

    test('4️⃣ Criar asset de teste', () async {
      if (testModuleId == null) {
        fail('Module ID não disponível');
      }

      final asset = await moduleService.addAssetToModule(
        // ✅ CORRIGIDO: Nome correto do método
        moduleId: testModuleId!,
        assetData: {
          'serial_number':
              'FLUTTER-TEST-${DateTime.now().millisecondsSinceEpoch}',
          'asset_name': 'Desktop Teste Flutter',
          'hostname': 'DESKTOP-FLUTTER',
          'ip_address': '192.168.1.150',
          'mac_address': 'FF:EE:DD:CC:BB:AA',
          'model': 'HP EliteDesk',
          'manufacturer': 'HP',
          'processor': 'Intel i5',
          'ram': '8GB',
          'storage': '256GB',
          'operating_system': 'Windows 10',
        },
      );

      expect(asset, isNotNull);
      testAssetId = asset['_id'] ?? asset['id'];
      expect(testAssetId, isNotNull);

      print('✅ Asset criado: $testAssetId');
    });

    test('5️⃣ Listar assets do módulo', () async {
      if (testModuleId == null) {
        fail('Module ID não disponível');
      }

      // ✅ CORRIGIDO: Buscar units e bssids primeiro
      final units = await moduleService.fetchUnits();
      final bssids = await moduleService.fetchBssidMappings();

      final assets = await moduleService.listModuleAssetsTyped(
        moduleId: testModuleId!,
        moduleType: AssetModuleType.desktop,
        units: units,
        bssidMappings: bssids,
      );

      expect(assets, isNotEmpty);
      print('✅ Assets listados: ${assets.length} encontrados');
    });

    test('6️⃣ Enviar comando para asset', () async {
      if (testModuleId == null || testAssetId == null) {
        fail('IDs não disponíveis');
      }

      final success = await commandService.sendCommand(
        moduleId: testModuleId!,
        assetId: testAssetId!,
        commandType: 'flush_dns',
      );

      expect(success, isTrue);
      print('✅ Comando enviado com sucesso');
    });

    test('7️⃣ Buscar histórico de comandos', () async {
      if (testModuleId == null || testAssetId == null) {
        fail('IDs não disponíveis');
      }

      final history = await commandService.getCommandHistory(
        moduleId: testModuleId!,
        assetId: testAssetId!,
      );

      expect(history, isNotEmpty);
      print('✅ Histórico de comandos: ${history.length} comandos');
    });

    test('8️⃣ Colocar asset em manutenção', () async {
      if (testModuleId == null || testAssetId == null) {
        fail('IDs não disponíveis');
      }

      final success = await maintenanceService.setMaintenanceStatus(
        moduleId: testModuleId!,
        assetId: testAssetId!,
        status: true,
        ticket: 'FLUTTER-TEST-001',
        reason: 'Teste automático de manutenção',
      );

      expect(success, isTrue);
      print('✅ Asset colocado em manutenção');
    });

    test('9️⃣ Retirar asset de manutenção', () async {
      if (testModuleId == null || testAssetId == null) {
        fail('IDs não disponíveis');
      }

      final success = await maintenanceService.setMaintenanceStatus(
        moduleId: testModuleId!,
        assetId: testAssetId!,
        status: false,
      );

      expect(success, isTrue);
      print('✅ Asset retirado de manutenção');
    });

    test('🔟 Deletar asset de teste', () async {
      if (testModuleId == null || testAssetId == null) {
        fail('IDs não disponíveis');
      }

      final success = await moduleService.deleteAsset(
        moduleId: testModuleId!,
        assetId: testAssetId!,
      );

      expect(success, isTrue);
      print('✅ Asset deletado');
    });

    test('1️⃣1️⃣ Deletar módulo de teste', () async {
      if (testModuleId == null) {
        fail('Module ID não disponível');
      }

      // ✅ CORRIGIDO: deleteModule agora retorna bool
      final success = await moduleService.deleteModule(testModuleId!);

      expect(success, isTrue);
      print('✅ Módulo deletado');
    });

    test('1️⃣2️⃣ Logout', () async {
      await authService.logout();

      expect(authService.isLoggedIn, isFalse);
      expect(authService.currentToken, isNull);

      print('✅ Logout realizado');
    });
  });
}
