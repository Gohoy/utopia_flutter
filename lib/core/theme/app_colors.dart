import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 主色调
  static const Color primary = Color(0xFF6B73FF);
  static const Color primaryLight = Color(0xFF9BA3FF);
  static const Color primaryDark = Color(0xFF4A5BFF);
  
  // 辅助色
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color secondaryLight = Color(0xFFFF9BC7);
  static const Color secondaryDark = Color(0xFFE94B7D);
  
  // 中性色
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF424242);
  
  // 背景色
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  
  // 状态色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 文字色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // 边框色
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  
  // 标签相关色彩
  static const List<Color> tagColors = [
    Color(0xFFE3F2FD), // 蓝色系
    Color(0xFFF3E5F5), // 紫色系
    Color(0xFFE8F5E8), // 绿色系
    Color(0xFFFFF3E0), // 橙色系
    Color(0xFFFFEBEE), // 红色系
    Color(0xFFE0F7FA), // 青色系
    Color(0xFFFFF8E1), // 黄色系
    Color(0xFFF1F8E9), // 浅绿系
  ];
  
  static const List<Color> tagTextColors = [
    Color(0xFF1976D2),
    Color(0xFF7B1FA2),
    Color(0xFF388E3C),
    Color(0xFFF57C00),
    Color(0xFFD32F2F),
    Color(0xFF0097A7),
    Color(0xFFFBC02D),
    Color(0xFF689F38),
  ];
}
