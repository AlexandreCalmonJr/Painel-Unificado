import 'package:shared_preferences/shared_preferences.dart';
import 'package:painel_windowns/core/error/exceptions.dart';

/// Data Source local para configurações do sistema
abstract class ConfigLocalDataSource {
  Future<String?> getServerUrl();
  Future<void> saveServerUrl(String url);
  Future<String?> getApiKey();
  Future<void> saveApiKey(String apiKey);
  Future<Map<String, dynamic>> getAllSettings();
  Future<void> saveSetting(String key, dynamic value);
  Future<dynamic> getSetting(String key);
  Future<void> clearAllSettings();
}

class ConfigLocalDataSourceImpl implements ConfigLocalDataSource {

  ConfigLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  static const String SERVER_URL_KEY = 'SERVER_URL';
  static const String API_KEY = 'API_KEY';
  static const String SETTINGS_PREFIX = 'SETTING_';

  @override
  Future<String?> getServerUrl() async {
    try {
      return sharedPreferences.getString(SERVER_URL_KEY);
    } catch (e) {
      throw CacheException(message: 'Error reading server URL: $e');
    }
  }

  @override
  Future<void> saveServerUrl(String url) async {
    try {
      await sharedPreferences.setString(SERVER_URL_KEY, url);
    } catch (e) {
      throw CacheException(message: 'Error saving server URL: $e');
    }
  }

  @override
  Future<String?> getApiKey() async {
    try {
      return sharedPreferences.getString(API_KEY);
    } catch (e) {
      throw CacheException(message: 'Error reading API key: $e');
    }
  }

  @override
  Future<void> saveApiKey(String apiKey) async {
    try {
      await sharedPreferences.setString(API_KEY, apiKey);
    } catch (e) {
      throw CacheException(message: 'Error saving API key: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getAllSettings() async {
    try {
      final keys = sharedPreferences.getKeys();
      final settings = <String, dynamic>{};

      for (final key in keys) {
        if (key.startsWith(SETTINGS_PREFIX)) {
          final settingKey = key.substring(SETTINGS_PREFIX.length);
          settings[settingKey] = sharedPreferences.get(key);
        }
      }

      return settings;
    } catch (e) {
      throw CacheException(message: 'Error reading settings: $e');
    }
  }

  @override
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      final prefKey = '$SETTINGS_PREFIX$key';

      if (value is String) {
        await sharedPreferences.setString(prefKey, value);
      } else if (value is int) {
        await sharedPreferences.setInt(prefKey, value);
      } else if (value is double) {
        await sharedPreferences.setDouble(prefKey, value);
      } else if (value is bool) {
        await sharedPreferences.setBool(prefKey, value);
      } else if (value is List<String>) {
        await sharedPreferences.setStringList(prefKey, value);
      } else {
        throw CacheException(
          message: 'Unsupported value type: ${value.runtimeType}',
        );
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error saving setting: $e');
    }
  }

  @override
  Future<dynamic> getSetting(String key) async {
    try {
      final prefKey = '$SETTINGS_PREFIX$key';
      return sharedPreferences.get(prefKey);
    } catch (e) {
      throw CacheException(message: 'Error reading setting: $e');
    }
  }

  @override
  Future<void> clearAllSettings() async {
    try {
      final keys = sharedPreferences.getKeys();
      for (final key in keys) {
        if (key.startsWith(SETTINGS_PREFIX)) {
          await sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw CacheException(message: 'Error clearing settings: $e');
    }
  }
}
