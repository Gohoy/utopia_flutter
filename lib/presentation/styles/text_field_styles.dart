import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class TextFieldStyles {
  TextFieldStyles._();

  // 基础输入框样式
  static InputDecoration get basic => InputDecoration(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.primary, width: 2.w),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.error, width: 2.w),
    ),
    labelStyle: AppTextStyles.bodyMedium,
    hintStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textSecondary,
    ),
    errorStyle: AppTextStyles.error,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
  );

  // 搜索框样式
  static InputDecoration get search => basic.copyWith(
    prefixIcon: Icon(
      Icons.search,
      color: AppColors.textSecondary,
      size: 20.w,
    ),
    hintText: '搜索...',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.r),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.r),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.r),
      borderSide: BorderSide(color: AppColors.primary, width: 2.w),
    ),
  );

  // 多行文本框样式
  static InputDecoration get multiline => basic.copyWith(
    alignLabelWithHint: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
  );

  // 密码输入框样式
  static InputDecoration password({
    required bool obscureText,
    required VoidCallback onToggle,
  }) => basic.copyWith(
    suffixIcon: IconButton(
      icon: Icon(
        obscureText ? Icons.visibility : Icons.visibility_off,
        color: AppColors.textSecondary,
        size: 20.w,
      ),
      onPressed: onToggle,
    ),
  );

  // 简洁样式（无边框）
  static InputDecoration get clean => InputDecoration(
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.primary, width: 2.w),
    ),
    labelStyle: AppTextStyles.bodyMedium,
    hintStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textSecondary,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
  );
}
