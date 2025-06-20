class Validators {
  Validators._();

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidUsername(String username) {
    if (username.length < 3 || username.length > 20) return false;
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(username);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  static bool isValidNickname(String nickname) {
    return nickname.length <= 50;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '邮箱不能为空';
    }
    if (!isValidEmail(value.trim())) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '用户名不能为空';
    }
    if (!isValidUsername(value.trim())) {
      return '用户名只能包含字母、数字和下划线，长度3-20字符';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '密码不能为空';
    }
    if (!isValidPassword(value)) {
      return '密码长度至少8个字符';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != password) {
      return '两次输入的密码不一致';
    }
    return null;
  }
}
