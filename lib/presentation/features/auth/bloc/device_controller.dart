// File: lib/controllers/device_controller.dart
import 'package:get/get.dart';
import 'package:painel_windowns/data/models/device.dart';
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/data/models/bssid_mapping.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/controllers/auth_controller.dart';

/// Controller para gerenciamento de dispositivos usando GetX
class DeviceController extends GetxController {
  final DeviceService _deviceService = DeviceService();
  final AuthController _authController = Get.find<AuthController>();

  // Estado reativo
  final RxList<Device> devices = <Device>[].obs;
  final RxList<Unit> units = <Unit>[].obs;
  final RxList<BssidMapping> bssidMappings = <BssidMapping>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Filtros
  List<Device> get filteredDevices {
    if (searchQuery.value.isEmpty) return devices;

    return devices.where((device) {
      final query = searchQuery.value.toLowerCase();
      return device.deviceName?.toLowerCase().contains(query) == true ||
          device.serialNumber?.toLowerCase().contains(query) == true ||
          device.location?.toLowerCase().contains(query) == true;
    }).toList();
  }

  // Estatísticas
  int get onlineDevices => devices.where((d) => d.status == 'online').length;
  int get offlineDevices => devices.where((d) => d.status == 'offline').length;
  int get maintenanceDevices =>
      devices.where((d) => d.status == 'maintenance').length;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  /// Inicializa dados
  Future<void> _initializeData() async {
    await Future.wait([fetchUnits(), fetchDevices(), fetchBssidMappings()]);
  }

  /// Busca dispositivos
  Future<void> fetchDevices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = _authController.token;
      if (token == null) {
        errorMessage.value = 'Token não encontrado';
        return;
      }

      final fetchedDevices = await _deviceService.fetchDevices(token, units);
      devices.value = fetchedDevices;
    } catch (e) {
      errorMessage.value = 'Erro ao buscar dispositivos: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Busca unidades
  Future<void> fetchUnits() async {
    try {
      final token = _authController.token;
      if (token == null) return;

      final fetchedUnits = await _deviceService.fetchUnits(token);
      units.value = fetchedUnits;
    } catch (e) {
      errorMessage.value = 'Erro ao buscar unidades: ${e.toString()}';
    }
  }

  /// Busca mapeamentos BSSID
  Future<void> fetchBssidMappings() async {
    try {
      final token = _authController.token;
      if (token == null) return;

      final mappings = await _deviceService.fetchBssidMappings(token);
      bssidMappings.value = mappings;
    } catch (e) {
      errorMessage.value = 'Erro ao buscar mapeamentos: ${e.toString()}';
    }
  }

  /// Envia comando para dispositivo
  Future<bool> sendCommand(
    String serialNumber,
    String command,
    Map<String, dynamic> parameters,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = _authController.token;
      if (token == null) {
        errorMessage.value = 'Token não encontrado';
        return false;
      }

      await _deviceService.sendCommand(
        token,
        serialNumber,
        command,
        parameters,
      );

      // Atualiza o dispositivo na lista se necessário
      await fetchDevices();
      return true;
    } catch (e) {
      errorMessage.value = 'Erro ao enviar comando: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Deleta dispositivo
  Future<bool> deleteDevice(String serialNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = _authController.token;
      if (token == null) {
        errorMessage.value = 'Token não encontrado';
        return false;
      }

      await _deviceService.deleteDevice(token, serialNumber);

      devices.removeWhere((d) => d.serialNumber == serialNumber);
      return true;
    } catch (e) {
      errorMessage.value = 'Erro ao deletar dispositivo: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cria unidade
  Future<bool> createUnit(Unit unit) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = _authController.token;
      if (token == null) {
        errorMessage.value = 'Token não encontrado';
        return false;
      }

      await _deviceService.createUnit(token, unit);

      units.add(unit);
      return true;
    } catch (e) {
      errorMessage.value = 'Erro ao criar unidade: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza unidade
  Future<bool> updateUnit(String unitName, Unit unit) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = _authController.token;
      if (token == null) {
        errorMessage.value = 'Token não encontrado';
        return false;
      }

      await _deviceService.updateUnit(token, unitName, unit);

      final index = units.indexWhere((u) => u.name == unitName);
      if (index != -1) {
        units[index] = unit;
      }
      return true;
    } catch (e) {
      errorMessage.value = 'Erro ao atualizar unidade: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Deleta unidade
  Future<bool> deleteUnit(String unitName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = _authController.token;
      if (token == null) {
        errorMessage.value = 'Token não encontrado';
        return false;
      }

      await _deviceService.deleteUnit(token, unitName);

      units.removeWhere((u) => u.name == unitName);
      return true;
    } catch (e) {
      errorMessage.value = 'Erro ao deletar unidade: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza query de pesquisa
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Limpa mensagem de erro
  void clearError() {
    errorMessage.value = '';
  }

  /// Atualiza dados (refresh)
  @override
  Future<void> refresh() async {
    await _initializeData();
  }
}
