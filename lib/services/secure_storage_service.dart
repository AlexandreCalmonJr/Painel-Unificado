// File: lib/services/secure_storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço para armazenamento seguro de dados sensíveis
/// Usa flutter_secure_storage para criptografar dados localmente
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  static SecureStorageService get instance => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    wOptions: WindowsOptions(),
  );

  // ===== TOKEN =====

  /// Salva o token de autenticação de forma segura
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Recupera o token de autenticação
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Remove o token de autenticação
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // ===== USER DATA =====

  /// Salva os dados do usuário de forma segura
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(
      key: 'user_data',
      value: jsonEncode(user),
    );
  }

  /// Recupera os dados do usuário
  Future<Map<String, dynamic>?> getUser() async {
    final userData = await _storage.read(key: 'user_data');
    if (userData == null) return null;

    try {
      return jsonDecode(userData) as Map<String, dynamic>;
    } catch (e) {
      // Se houver erro ao decodificar, remove os dados corrompidos
      await deleteUser();
      return null;
    }
  }

  /// Remove os dados do usuário
  Future<void> deleteUser() async {
    await _storage.delete(key: 'user_data');
  }

  // ===== CONFIGURAÇÕES =====

  /// Salva uma configuração genérica
  Future<void> saveConfig(String key, String value) async {
    await _storage.write(key: 'config_$key', value: value);
  }

  /// Recupera uma configuração genérica
  Future<String?> getConfig(String key) async {
    return await _storage.read(key: 'config_$key');
  }

  /// Remove uma configuração genérica
  Future<void> deleteConfig(String key) async {
    await _storage.delete(key: 'config_$key');
  }

  // ===== LIMPEZA =====

  /// Remove todos os dados armazenados
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Verifica se há dados armazenados
  Future<bool> hasData() async {
    final all = await _storage.readAll();
    return all.isNotEmpty;
  }

  /// Lista todas as chaves armazenadas (útil para debug)
  Future<Map<String, String>> getAllData() async {
    return await _storage.readAll();
  }
}
