import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _hasHandledLoginSuccess = false; // 添加这个标记

  @override
  void initState() {
    super.initState();
    // 监听登录状态变化
    context.read<AuthProvider>().addListener(_onAuthStatusChanged);
  }

  @override
  void dispose() {
    // 移除监听器
    context.read<AuthProvider>().removeListener(_onAuthStatusChanged);
    
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onAuthStatusChanged() {
    if (context.read<AuthProvider>().isLoggedIn && mounted) {
      _handleLoginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60.h),

                    // 标题
                    _buildHeader(),

                    SizedBox(height: 48.h),

                    // 错误提示
                    if (authProvider.error != null &&
                        !authProvider.isLoggedIn) ...[
                      _buildErrorCard(authProvider.error!),
                      SizedBox(height: 16.h),
                    ],

                    // 用户名输入框
                    CustomTextField(
                      label: '用户名或邮箱',
                      hint: '请输入用户名或邮箱',
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !authProvider.isLoading,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        size: 20.w,
                        color: AppColors.textSecondary,
                      ),
                      onSubmitted: (_) {
                        _passwordFocusNode.requestFocus();
                      },
                    ),

                    SizedBox(height: 20.h),

                    // 密码输入框
                    CustomTextField(
                      label: '密码',
                      hint: '请输入密码',
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !authProvider.isLoading,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        size: 20.w,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20.w,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      onSubmitted: (_) => _handleLogin(authProvider),
                    ),

                    SizedBox(height: 32.h),

                    // 登录按钮
                    CustomButton(
                      text: authProvider.isLoading ? '登录中...' : '登录',
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleLogin(authProvider),
                      isFullWidth: true,
                      isLoading: authProvider.isLoading,
                    ),

                    SizedBox(height: 24.h),

                    // 分割线
                    _buildDivider(),

                    SizedBox(height: 24.h),

                    // 注册链接
                    _buildSignUpLink(),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '欢迎回来',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '登录到你的虚拟乌托邦账户',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.error,
              size: 18.w,
            ),
            onPressed: () {
              context.read<AuthProvider>().clearError();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1.h,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            '或',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1.h,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: TextButton(
        onPressed: () => context.go('/register'),
        child: RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium,
            children: [
              TextSpan(
                text: '还没有账户？',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextSpan(
                text: ' 立即注册',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin(AuthProvider authProvider) async {
    // 重置状态
    _hasHandledLoginSuccess = false;

    // 清除之前的错误
    authProvider.clearError();

    // 验证输入
    if (!_validateInputs()) {
      return;
    }

    // 取消键盘焦点
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    print('🔄 开始登录: $username');

    try {
      final success = await authProvider.login(
        username: username,
        password: password,
      );

      print('📝 登录结果: $success');

      if (!success) {
        final errorMessage = authProvider.error ?? '登录失败，请检查用户名和密码';
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      print('❌ 登录异常: $e');
      _showErrorSnackBar('登录失败：$e');
    }
  }

  bool _validateInputs() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty) {
      _showErrorSnackBar('请输入用户名或邮箱');
      _usernameFocusNode.requestFocus();
      return false;
    }

    if (password.isEmpty) {
      _showErrorSnackBar('请输入密码');
      _passwordFocusNode.requestFocus();
      return false;
    }

    if (password.length < 6) {
      _showErrorSnackBar('密码长度至少6位');
      _passwordFocusNode.requestFocus();
      return false;
    }

    return true;
  }

  void _handleLoginSuccess() {
    if (!_hasHandledLoginSuccess) {
      _hasHandledLoginSuccess = true;
      print('🎉 处理登录成功');

      // 显示成功提示
      _showSuccessSnackBar('登录成功！');

      // 清空表单
      _usernameController.clear();
      _passwordController.clear();

      // 直接跳转
      context.go('/home');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.white,
              size: 20.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.white,
              size: 20.w,
            ),
            SizedBox(width: 12.w),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}
