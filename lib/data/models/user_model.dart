class UserModel {
  final String id;
  final String username;
  final String email;
  final String? nickname;
  final String? avatarUrl;
  final String? bio;
  final int reputationScore;
  final int contributionCount;
  final bool isActive;
  final String accountStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final UserPermissionModel? permissions;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.nickname,
    this.avatarUrl,
    this.bio,
    required this.reputationScore,
    required this.contributionCount,
    required this.isActive,
    required this.accountStatus,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.permissions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 解析用户数据: $json'); // 调试日志

      return UserModel(
        id: _parseString(json['id'], 'id'),
        username: _parseString(json['username'], 'username'),
        email: _parseString(json['email'], 'email'),
        nickname: json['nickname'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        reputationScore: _parseInt(json['reputation_score']) ?? 0,
        contributionCount: _parseInt(json['contribution_count']) ?? 0,
        isActive: _parseBool(json['is_active']) ?? true,
        accountStatus: _parseString(json['account_status'], 'account_status',
            defaultValue: 'normal'),
        createdAt: _parseDateTime(json['created_at'], 'created_at'),
        updatedAt: _parseDateTime(json['updated_at'], 'updated_at'),
        lastLoginAt: json['last_login_at'] != null
            ? _parseDateTime(json['last_login_at'], 'last_login_at')
            : null,
        permissions: json['permissions'] != null
            ? UserPermissionModel.fromJson(
                json['permissions'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('❌ 用户数据解析失败: $e');
      print('📊 原始数据: $json');
      rethrow;
    }
  }

  // 辅助解析方法
  static String _parseString(dynamic value, String fieldName,
      {String? defaultValue}) {
    if (value == null) {
      if (defaultValue != null) {
        return defaultValue;
      }
      throw ArgumentError('字段 $fieldName 不能为null');
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return null;
  }

  static DateTime _parseDateTime(dynamic value, String fieldName) {
    if (value == null) {
      throw ArgumentError('字段 $fieldName 不能为null');
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        throw ArgumentError('字段 $fieldName 日期格式错误: $value');
      }
    }
    throw ArgumentError('字段 $fieldName 类型错误: ${value.runtimeType}');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'bio': bio,
      'reputation_score': reputationScore,
      'contribution_count': contributionCount,
      'is_active': isActive,
      'account_status': accountStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'permissions': permissions?.toJson(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? nickname,
    String? avatarUrl,
    String? bio,
    int? reputationScore,
    int? contributionCount,
    bool? isActive,
    String? accountStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    UserPermissionModel? permissions,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      reputationScore: reputationScore ?? this.reputationScore,
      contributionCount: contributionCount ?? this.contributionCount,
      isActive: isActive ?? this.isActive,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      permissions: permissions ?? this.permissions,
    );
  }
}

class UserPermissionModel {
  final bool canCreateTags;
  final bool canEditTags;
  final bool canApproveChanges;
  final int maxEditsPerDay;

  UserPermissionModel({
    required this.canCreateTags,
    required this.canEditTags,
    required this.canApproveChanges,
    required this.maxEditsPerDay,
  });

  factory UserPermissionModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 解析权限数据: $json'); // 调试日志

      return UserPermissionModel(
        canCreateTags: json['can_create_tags'] as bool? ?? false,
        canEditTags: json['can_edit_tags'] as bool? ?? false,
        canApproveChanges: json['can_approve_changes'] as bool? ?? false,
        maxEditsPerDay: json['max_edits_per_day'] as int? ?? 10,
      );
    } catch (e) {
      print('❌ 权限数据解析失败: $e');
      print('📊 原始数据: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'can_create_tags': canCreateTags,
      'can_edit_tags': canEditTags,
      'can_approve_changes': canApproveChanges,
      'max_edits_per_day': maxEditsPerDay,
    };
  }
}
