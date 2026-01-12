// File: lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/services/auth_service.dart';


/// Controller para gerenciamento de autenticação usando GetX
class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Estado reativo
  final Rx<Map<String, dynamic>?> currentUser = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;

  // Getters
  bool get isLoggedIn => currentUser.value != null;
  bool get isAdmin => currentUser.value?['role'] == 'admin';
  String? get token => _authService.currentToken;
  List<String> get permissions =>
      List<String>.from(currentUser.value?['permissions'] as List<String> ?? []);

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  /// Inicializa autenticação do armazenamento local
  Future<void> _initializeAuth() async {
    try {
      await _authService.initializeFromStorage();
      if (_authService.isLoggedIn) {
        currentUser.value = _authService.currentUser;
      }
    } catch (e) {
      errorMessage.value = 'Erro ao carregar dados de autenticação';
    }
  }

  /// Realiza login
  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authService.login(username, password);

      if (result['success'] as bool) {
        currentUser.value = _authService.currentUser;
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = result['message'] as String ?? 'Erro ao fazer login';
        isLoading.value = false;
        return false;
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message as String;
      isLoading.value = false;
      return false;
    } on NetworkException catch (e) {
      errorMessage.value = e.message as String;
      isLoading.value = false;
      return false;
    } catch (e) {
      errorMessage.value = 'Erro inesperado: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  /// Realiza logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      currentUser.value = null;
      users.clear();
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = 'Erro ao fazer logout';
    }
  }

  /// Busca lista de usuários (apenas admin)
  Future<void> fetchUsers() async {
    if (!isAdmin) {
      errorMessage.value = 'Acesso não autorizado';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authService.getUsers();

      if (result['success'] as bool) {
        users.value = List<Map<String, dynamic>>.from(result['users'] as List<dynamic> ?? []);
      } else {
        errorMessage.value = result['message'] as String ?? 'Erro ao buscar usuários';
      }
    } catch (e) {
      errorMessage.value = 'Erro ao buscar usuários: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Cria novo usuário (apenas admin)
  Future<bool> createUser(Map<String, dynamic> userData) async {
    if (!isAdmin) {
      errorMessage.value = 'Acesso não autorizado';
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authService.createUser(userData);

      if (result['success'] as bool) {
        // Adiciona o novo usuário à lista
        if (result['user'] != null) {
          users.add(result['user'] as Map<String, dynamic>);
        }
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = result['message'] as String ?? 'Erro ao criar usuário';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Erro ao criar usuário: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  /// Atualiza usuário existente (apenas admin)
  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    if (!isAdmin) {
      errorMessage.value = 'Acesso não autorizado';
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authService.updateUser(userId, userData);

      if (result['success'] as bool) {
        // Atualiza o usuário na lista
        final index = users.indexWhere((u) => u['_id'] == userId);
        if (index != -1) {
          users[index] = {...users[index], ...userData};
        }
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = result['message'] as String ?? 'Erro ao atualizar usuário';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Erro ao atualizar usuário: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  /// Deleta usuário (apenas admin)
  Future<bool> deleteUser(String userId) async {
    if (!isAdmin) {
      errorMessage.value = 'Acesso não autorizado';
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authService.deleteUser(userId);

      if (result['success'] as bool) {
        // Remove o usuário da lista
        users.removeWhere((u) => u['_id'] == userId);
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = result['message'] as String ?? 'Erro ao deletar usuário';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Erro ao deletar usuário: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  /// Altera senha do usuário logado
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authService.changePassword(currentPassword, newPassword);

      if (result['success'] as bool) {
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = result['message'] as String ?? 'Erro ao alterar senha';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Erro ao alterar senha: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    errorMessage.value = '';
  }
}
