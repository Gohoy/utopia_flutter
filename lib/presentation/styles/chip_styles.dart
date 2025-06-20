import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ChipStyles {
  ChipStyles._();

  // 基础标签样式
  static Widget buildBasicChip({
    required String label,
    bool selected = false,
    VoidCallback? onTap,
    VoidCallback? onDeleted,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 8.w, bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected 
                ? (backgroundColor ?? AppColors.primary)
                : (backgroundColor ?? AppColors.surfaceVariant),
            borderRadius: BorderRadius.circular(20.r),
            border: selected 
                ? null 
                : Border.all(color: AppColors.border, width: 1.w),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.tagText.copyWith(
                  color: selected 
                      ? AppColors.white 
                      : (textColor ?? AppColors.textPrimary),
                ),
              ),
              if (onDeleted != null) ...[
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: onDeleted,
                  child: Icon(
                    Icons.close,
                    size: 16.w,
                    color: selected 
                        ? AppColors.white 
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 彩色标签样式
  static Widget buildColorfulChip({
    required String label,
    required int colorIndex,
    bool selected = false,
    VoidCallback? onTap,
    VoidCallback? onDeleted,
  }) {
    final backgroundColor = selected 
        ? AppColors.tagTextColors[colorIndex % AppColors.tagTextColors.length]
        : AppColors.tagColors[colorIndex % AppColors.tagColors.length];
    
    final textColor = selected 
        ? AppColors.white
        : AppColors.tagTextColors[colorIndex % AppColors.tagTextColors.length];

    return buildBasicChip(
      label: label,
      selected: selected,
      onTap: onTap,
      onDeleted: onDeleted,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  // 可选择的标签样式
  static Widget buildSelectableChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    int? colorIndex,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: colorIndex != null 
          ? AppColors.tagColors[colorIndex % AppColors.tagColors.length]
          : AppColors.surfaceVariant,
      selectedColor: colorIndex != null 
          ? AppColors.tagTextColors[colorIndex % AppColors.tagTextColors.length]
          : AppColors.primary,
      labelStyle: AppTextStyles.tagText.copyWith(
        color: selected 
            ? AppColors.white 
            : (colorIndex != null 
                ? AppColors.tagTextColors[colorIndex % AppColors.tagTextColors.length]
                : AppColors.textPrimary),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: selected 
            ? BorderSide.none 
            : BorderSide(color: AppColors.border, width: 1.w),
      ),
    );
  }

  // 输入标签样式
  static Widget buildInputChip({
    required String label,
    required VoidCallback onDeleted,
    int? colorIndex,
  }) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
      backgroundColor: colorIndex != null 
          ? AppColors.tagColors[colorIndex % AppColors.tagColors.length]
          : AppColors.surfaceVariant,
      labelStyle: AppTextStyles.tagText.copyWith(
        color: colorIndex != null 
            ? AppColors.tagTextColors[colorIndex % AppColors.tagTextColors.length]
            : AppColors.textPrimary,
      ),
      deleteIconColor: colorIndex != null 
          ? AppColors.tagTextColors[colorIndex % AppColors.tagTextColors.length]
          : AppColors.textSecondary,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: AppColors.border, width: 1.w),
      ),
    );
  }

  // 紧凑型标签样式
  static Widget buildCompactChip({
    required String label,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 4.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: textColor ?? AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
