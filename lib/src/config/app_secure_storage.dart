import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  static FlutterSecureStorage? _instance;

  static getSecureStorageInstance() {
    _instance ??= const FlutterSecureStorage();
    return _instance;
  }

  static Future<String?> read({required String key}) async {
    final storage = getSecureStorageInstance();
    return await storage.read(key: key);
  }

  static Future<void> write(
      {required String key, required String value}) async {
    final storage = getSecureStorageInstance();
    await storage.write(key: key, value: value);
  }

  static Future<void> delete({required String key}) async {
    final storage = getSecureStorageInstance();
    await storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    final storage = getSecureStorageInstance();
    await storage.deleteAll();
  }

  static Future<Map<String, String>> readAll() async {
    final storage = getSecureStorageInstance();
    return await storage.readAll();
  }

  static Future<void> writeAll(Map<String, String> map) async {
    final storage = getSecureStorageInstance();
    await storage.writeAll(map: map);
  }

  static Future<bool> containsKey({required String key}) async {
    final storage = getSecureStorageInstance();
    return await storage.containsKey(key: key);
  }

  static Future<void> setUID(String uid) async {
    final storage = getSecureStorageInstance();
    await storage.write(key: 'uid', value: uid);
  }

  static Future<bool> isUIDSet() async {
    final uid = await read(key: 'uid');
    return uid != null;
  }

  static Future<String?> getUID() async {
    final storage = getSecureStorageInstance();
    return await storage.read(key: 'uid');
  }
}
