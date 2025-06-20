import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  // 用户登录
  Future<({UserModel user, String token})> login({
    required String username,
    required String password,
  }) async {
    try {
      print('🔐 AuthRepository: 开始登录请求');

      final response = await _apiService.post(
        ApiConstants.loginPath,
        data: {
          'username': username,
          'password': password,
        },
      );

      print('📥 AuthRepository: 收到响应');
      print('📊 响应状态: ${response.statusCode}');
      print('📊 响应数据类型: ${response.data.runtimeType}');
      print('📊 响应内容: ${response.data}');

      // 检查响应数据结构
      if (response.data == null) {
        throw Exception('服务器返回空数据');
      }

      final responseData = response.data as Map<String, dynamic>;

      // 检查success字段
      final success = responseData['success'];
      print('✅ Success字段: $success (${success.runtimeType})');

      if (success == true) {
        final data = responseData['data'];
        print('📦 Data字段: $data (${data?.runtimeType})');

        if (data == null) {
          throw Exception('响应数据中缺少data字段');
        }

        final dataMap = data as Map<String, dynamic>;

        // 检查用户数据
        final userData = dataMap['user'];
        print('👤 User数据: $userData (${userData?.runtimeType})');

        if (userData == null) {
          throw Exception('响应数据中缺少user字段');
        }

        // 检查token数据
        final tokensData = dataMap['tokens'];
        print('🔐 Tokens数据: $tokensData (${tokensData?.runtimeType})');

        if (tokensData == null) {
          throw Exception('响应数据中缺少tokens字段');
        }

        final tokensMap = tokensData as Map<String, dynamic>;
        final token = tokensMap['access_token'];
        print('🎫 Access Token: ${token != null ? "存在" : "不存在"}');

        if (token == null) {
          throw Exception('响应数据中缺少access_token字段');
        }

        // 解析用户数据
        print('🔄 开始解析用户数据...');
        final user = UserModel.fromJson(userData as Map<String, dynamic>);
        print('✅ 用户数据解析成功: ${user.username}');

        // 保存到本地存储
        print('💾 保存到本地存储...');
        await _storageService.saveToken(token as String);
        await _storageService.saveUser(userData as Map<String, dynamic>);
        print('✅ 本地存储保存成功');

        return (user: user, token: token as String);
      } else {
        final message = responseData['message'] as String? ?? '登录失败';
        print('❌ 登录失败: $message');
        throw Exception(message);
      }
    } catch (e) {
      print('❌ AuthRepository登录异常: $e');
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('登录失败: $e');
      }
    }
  }

  // 用户注册
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? nickname,
  }) async {
    final response = await _apiService.post(
      ApiConstants.registerPath,
      data: {
        'username': username,
        'email': email,
        'password': password,
        if (nickname != null) 'nickname': nickname,
      },
    );

    if (response.data['success'] == true) {
      final userData = response.data['data']['user'] as Map<String, dynamic>;
      print(012);
      return UserModel.fromJson(userData);
    } else {
      throw Exception(response.data['message'] ?? '注册失败');
    }
  }

  // 用户登录
  // 获取用户信息
  Future<UserModel> getProfile() async {
    final response = await _apiService.get(ApiConstants.profilePath);

    if (response.data['success'] == true) {
      final userData = response.data['data']['user'] as Map<String, dynamic>;
      print('013');
      final user = UserModel.fromJson(userData);

      // 更新本地存储
      await _storageService.saveUser(userData);

      return user;
    } else {
      throw Exception(response.data['message'] ?? '获取用户信息失败');
    }
  }

  // 更新用户信息
  Future<UserModel> updateProfile({
    String? nickname,
    String? bio,
    String? avatarUrl,
  }) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (bio != null) data['bio'] = bio;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;

    final response = await _apiService.put(
      ApiConstants.profilePath,
      data: data,
    );

    if (response.data['success'] == true) {
      final userData = response.data['data']['user'] as Map<String, dynamic>;
      print(014);
      final user = UserModel.fromJson(userData);

      // 更新本地存储
      await _storageService.saveUser(userData);

      return user;
    } else {
      throw Exception(response.data['message'] ?? '更新用户信息失败');
    }
  }

  // 修改密码
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _apiService.post(
      ApiConstants.changePasswordPath,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? '修改密码失败');
    }
  }

  // 验证Token
  Future<bool> verifyToken() async {
    try {
      final response = await _apiService.post(ApiConstants.verifyTokenPath);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // 退出登录
  Future<void> logout() async {
    await _storageService.clearToken();
    await _storageService.clearUser();
  }

  // 获取本地用户信息
  Future<UserModel?> getLocalUser() async {
    final userData = await _storageService.getUser();

    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  // 获取本地Token
  Future<String?> getLocalToken() async {
    return await _storageService.getToken();
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getLocalToken();
    return token != null;
  }
}
