import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '注册账户',
          style: AppTextStyles.h3,
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题描述
                    _buildHeader(),
                    
                    SizedBox(height: 32.h),
                    
                    // 用户名
                    CustomTextField(
                      label: '用户名',
                      hint: '请输入用户名 (3-20个字符)',
                      controller: _usernameController,
                      required: true,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        size: 20.w,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // 邮箱
                    CustomTextField(
                      label: '邮箱',
                      hint: '请输入邮箱地址',
                      controller: _emailController,
                      required: true,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        size: 20.w,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // 昵称
                    CustomTextField(
                      label: '昵称',
                      hint: '请输入昵称 (可选)',
                      controller: _nicknameController,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        size: 20.w,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // 密码
                    CustomTextField(
                      label: '密码',
                      hint: '请输入密码 (至少8个字符)',
                      controller: _passwordController,
                      required: true,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        size: 20.w,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          size: 20.w,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // 确认密码
                    CustomTextField(
                      label: '确认密码',
                      hint: '请再次输入密码',
                      controller: _confirmPasswordController,
                      required: true,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        size: 20.w,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          size: 20.w,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      onSubmitted: (_) => _register(authProvider),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // 同意条款
                    _buildTermsCheckbox(),
                    
                    SizedBox(height: 32.h),
                    
                    // 注册按钮
                    CustomButton(
                      text: '注册',
                      onPressed: _agreeTerms ? () => _register(authProvider) : null,
                      isFullWidth: true,
                      isLoading: authProvider.isLoading,
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // 登录链接
                    _buildLoginLink(),
                    
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '创建你的账户',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '加入虚拟乌托邦，开始记录你的精彩生活',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeTerms,
          onChanged: (value) {
            setState(() {
              _agreeTerms = value ?? false;
            });
          },
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreeTerms = !_agreeTerms;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: '我已阅读并同意 '),
                    TextSpan(
                      text: '用户协议',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' 和 '),
                    TextSpan(
                      text: '隐私政策',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () => context.go('/login'),
        child: RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium,
            children: [
              TextSpan(
                text: '已有账户？',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextSpan(
                text: ' 立即登录',
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

  void _register(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // 验证输入
    final validation = _validateInputs();
    if (validation != null) {
      _showMessage(validation);
      return;
    }

    authProvider.clearError();
    
    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nickname: _nicknameController.text.trim().isEmpty 
          ? null 
          : _nicknameController.text.trim(),
    );

    if (success) {
      if (mounted) {
        _showMessage('注册成功！请登录您的账户', isError: false);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/login');
          }
        });
      }
    } else {
      if (mounted && authProvider.error != null) {
        _showMessage(authProvider.error!);
      }
    }
  }

  String? _validateInputs() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty) return '请输入用户名';
    if (username.length < 3 || username.length > 20) {
      return '用户名长度应在3-20个字符之间';
    }

    if (email.isEmpty) return '请输入邮箱';
    if (!Validators.isValidEmail(email)) return '请输入有效的邮箱地址';

    if (password.isEmpty) return '请输入密码';
    if (password.length < 8) return '密码长度至少8个字符';

    if (confirmPassword.isEmpty) return '请确认密码';
    if (password != confirmPassword) return '两次输入的密码不一致';

    if (!_agreeTerms) return '请同意用户协议和隐私政策';

    return null;
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }
}
