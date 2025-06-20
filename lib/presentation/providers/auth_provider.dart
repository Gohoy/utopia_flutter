import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null && _token != null;
  bool get initialized => _initialized;

  // 设置加载状态
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
      print('🔄 AuthProvider loading: $loading'); // 调试日志
    }
  }

  // 设置错误信息
  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
      print('❌ AuthProvider error: $error'); // 调试日志
    }
  }

  // 清除错误
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // 初始化 - 检查本地存储的用户信息
  Future<void> initialize() async {
    if (_initialized) return;

    print('🚀 AuthProvider 初始化开始'); // 调试日志
    _setLoading(true);

    try {
      final localUser = await _authRepository.getLocalUser();
      if (localUser != null) {
        // 验证用户数据完整性
        
        UserModel.fromJson(localUser.toJson());
      }
      final localToken = await _authRepository.getLocalToken();

      print('📱 本地用户: ${localUser?.username}'); // 调试日志
      print('🔐 本地Token: ${localToken != null ? "存在" : "不存在"}'); // 调试日志

      if (localUser != null && localToken != null) {
        // 验证token是否有效
        final isValid = await _authRepository.verifyToken();
        print('✅ Token验证结果: $isValid'); // 调试日志

        if (isValid) {
          _user = localUser;
          _token = localToken;
          print('👤 用户自动登录: ${_user?.username}'); // 调试日志
        } else {
          // Token无效，清除本地数据
          await _authRepository.logout();
          print('🗑️ Token无效，已清除本地数据'); // 调试日志
        }
      }
    } catch (e) {
      print('❌ 初始化失败: $e'); // 调试日志
      _setError('初始化失败：${e.toString()}');
    } finally {
      _initialized = true;
      _setLoading(false);
      print('✅ AuthProvider 初始化完成'); // 调试日志
    }
  }

  // 用户登录
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    print('🔄 开始登录流程: $username'); // 调试日志

    _setLoading(true);
    _setError(null);

    try {
      final result = await _authRepository.login(
        username: username,
        password: password,
      );

      print('📝 登录API调用成功'); // 调试日志
      print('👤 返回用户: ${result.user.username}'); // 调试日志
      print('🔐 返回Token: ${result.token.substring(0, 20)}...'); // 调试日志

      _user = result.user;
      _token = result.token;

      print('✅ 登录成功，状态已更新'); // 调试日志
      print('🔐 isLoggedIn: $isLoggedIn'); // 调试日志

      _setLoading(false);
      return true;
    } catch (e) {
      print('❌ 登录失败: $e'); // 调试日志
      _setError(_parseError(e));
      _setLoading(false);
      return false;
    }
  }

  // 用户注册
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? nickname,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        nickname: nickname,
      );

      // 注册成功后不自动登录，需要用户手动登录
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      _setLoading(false);
      return false;
    }
  }

  // 更新用户信息
  Future<bool> updateProfile({
    String? nickname,
    String? bio,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedUser = await _authRepository.updateProfile(
        nickname: nickname,
        bio: bio,
        avatarUrl: avatarUrl,
      );

      _user = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      _setLoading(false);
      return false;
    }
  }

  // 修改密码
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      _setLoading(false);
      return false;
    }
  }

  // 刷新用户信息
  Future<void> refreshProfile() async {
    if (!isLoggedIn) return;

    try {
      final updatedUser = await _authRepository.getProfile();
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('刷新用户信息失败：${_parseError(e)}');
    }
  }

  // 退出登录
  Future<void> logout() async {
    print('🚪 开始退出登录'); // 调试日志
    _setLoading(true);

    try {
      await _authRepository.logout();
      _user = null;
      _token = null;
      _error = null;
      print('✅ 退出登录成功'); // 调试日志
    } catch (e) {
      print('❌ 退出登录失败: $e'); // 调试日志
      _setError('退出登录失败：${_parseError(e)}');
    } finally {
      _setLoading(false);
    }
  }

  // 解析错误信息
  String _parseError(dynamic error) {
    String errorString = error.toString();

    // 常见错误的友好提示
    if (errorString.contains('用户名或密码错误') ||
        errorString.contains('401') ||
        errorString.contains('Unauthorized')) {
      return '用户名或密码错误';
    } else if (errorString.contains('用户已存在') ||
        errorString.contains('already exists')) {
      return '用户名或邮箱已存在';
    } else if (errorString.contains('网络') ||
        errorString.contains('connection')) {
      return '网络连接失败，请检查网络设置';
    } else if (errorString.contains('timeout')) {
      return '网络超时，请重试';
    } else if (errorString.contains('服务器') || errorString.contains('500')) {
      return '服务器错误，请稍后重试';
    }

    return errorString;
  }
}
