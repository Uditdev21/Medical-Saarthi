import 'package:get_storage/get_storage.dart';
import 'dart:developer';

class StorageHelper {
  static GetStorage? _storage;

  /// Initialize GetStorage - must be called before using any storage methods
  static Future<void> init() async {
    try {
      await GetStorage.init();
      _storage = GetStorage();
      log('✅ GetStorage initialized successfully');
    } catch (e) {
      log('❌ GetStorage initialization failed: $e');
      rethrow;
    }
  }

  /// Get storage instance with initialization check
  static GetStorage get _box {
    if (_storage == null) {
      throw Exception(
        'StorageHelper not initialized. Call StorageHelper.init() first.',
      );
    }
    return _storage!;
  }

  /// Save data to storage
  static Future<void> saveData(String key, dynamic value) async {
    try {
      await _box.write(key, value);
      log('💾 Saved data for key: $key');
    } catch (e) {
      log('❌ Failed to save data for key $key: $e');
      rethrow;
    }
  }

  /// Get data from storage
  static T? getData<T>(String key) {
    try {
      final data = _box.read<T>(key);
      log('📖 Retrieved data for key: $key');
      return data;
    } catch (e) {
      log('❌ Failed to get data for key $key: $e');
      return null;
    }
  }

  /// Remove specific key from storage
  static Future<void> removeData(String key) async {
    try {
      await _box.remove(key);
      log('🗑️ Removed data for key: $key');
    } catch (e) {
      log('❌ Failed to remove data for key $key: $e');
      rethrow;
    }
  }

  /// Clear all data from storage
  static Future<void> clearAll() async {
    try {
      await _box.erase();
      log('🧹 Cleared all storage data');
    } catch (e) {
      log('❌ Failed to clear storage: $e');
      rethrow;
    }
  }

  /// Check if key exists in storage
  static bool hasData(String key) {
    try {
      return _box.hasData(key);
    } catch (e) {
      log('❌ Failed to check if key exists $key: $e');
      return false;
    }
  }

  /// Get all keys from storage
  static Iterable<String> getKeys() {
    try {
      return _box.getKeys().cast<String>();
    } catch (e) {
      log('❌ Failed to get all keys: $e');
      return <String>[];
    }
  }
}

class StorageKeys {
  static const String gmail = 'gmail';
  static const String password = 'password';
}
