import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ButtonStyles {
  ButtonStyles._();

  // 主要按钮样式
  static ButtonStyle get primary => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    elevation: 2,
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    textStyle: AppTextStyles.buttonMedium,
    minimumSize: Size(120.w, 48.h),
  );

  // 次要按钮样式
  static ButtonStyle get secondary => ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary,
    foregroundColor: AppColors.white,
    elevation: 2,
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    textStyle: AppTextStyles.buttonMedium,
    minimumSize: Size(120.w, 48.h),
  );

  // 轮廓按钮样式
  static ButtonStyle get outline => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: BorderSide(color: AppColors.primary, width: 1.5.w),
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    textStyle: AppTextStyles.buttonMedium.copyWith(
      color: AppColors.primary,
    ),
    minimumSize: Size(120.w, 48.h),
  );

  // 文本按钮样式
  static ButtonStyle get text => TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    ),
    textStyle: AppTextStyles.buttonMedium.copyWith(
      color: AppColors.primary,
    ),
  );

  // 小型按钮样式
  static ButtonStyle get small => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    elevation: 1,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    ),
    textStyle: AppTextStyles.buttonSmall,
    minimumSize: Size(80.w, 32.h),
  );

  // 危险按钮样式
  static ButtonStyle get danger => ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: AppColors.white,
    elevation: 2,
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    textStyle: AppTextStyles.buttonMedium,
    minimumSize: Size(120.w, 48.h),
  );

  // 成功按钮样式
  static ButtonStyle get success => ElevatedButton.styleFrom(
    backgroundColor: AppColors.success,
    foregroundColor: AppColors.white,
    elevation: 2,
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    textStyle: AppTextStyles.buttonMedium,
    minimumSize: Size(120.w, 48.h),
  );

  // 浮动按钮样式
  static ButtonStyle get floating => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    elevation: 6,
    padding: EdgeInsets.all(16.w),
    shape: CircleBorder(),
    fixedSize: Size(56.w, 56.h),
  );
}
