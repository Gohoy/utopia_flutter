import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token相关
  Future<void> saveToken(String token) async {
    await _prefs?.setString(ApiConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs?.getString(ApiConstants.tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs?.remove(ApiConstants.tokenKey);
  }

  // 用户信息相关
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs?.setString(ApiConstants.userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final jsonString = await _prefs?.getString(ApiConstants.userKey);
    if (jsonString != null) {
      print('📂 从存储读取用户数据: $jsonString'); // 增加调试输出
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearUser() async {
    await _prefs?.remove(ApiConstants.userKey);
  }

  // 应用设置相关
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs?.setString(ApiConstants.settingsKey, jsonEncode(settings));
  }

  Future<Map<String, dynamic>?> getSettings() async {
    final settingsString = _prefs?.getString(ApiConstants.settingsKey);
    if (settingsString != null) {
      return jsonDecode(settingsString) as Map<String, dynamic>;
    }
    return null;
  }

  // 通用存储方法
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}
