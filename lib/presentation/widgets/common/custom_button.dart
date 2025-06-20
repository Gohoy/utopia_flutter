import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/button_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    
    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? Colors.white,
              ),
            ),
          )
        : _buildButtonContent();

    Widget button;
    
    switch (type) {
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonType.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      default:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
    }

    return isFullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }

  ButtonStyle _getButtonStyle() {
    ButtonStyle baseStyle;
    
    switch (type) {
      case ButtonType.primary:
        baseStyle = ButtonStyles.primary;
        break;
      case ButtonType.secondary:
        baseStyle = ButtonStyles.secondary;
        break;
      case ButtonType.outlined:
        baseStyle = ButtonStyles.outline;
        break;
      case ButtonType.text:
        baseStyle = ButtonStyles.text;
        break;
      case ButtonType.danger:
        baseStyle = ButtonStyles.danger;
        break;
      case ButtonType.success:
        baseStyle = ButtonStyles.success;
        break;
    }

    // 根据尺寸调整
    if (size == ButtonSize.small) {
      baseStyle = ButtonStyles.small;
    }

    // 自定义颜色
    if (backgroundColor != null) {
      baseStyle = baseStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(backgroundColor),
      );
    }

    return baseStyle;
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: 8.w),
          Text(text),
        ],
      );
    }
    return Text(text);
  }
}

enum ButtonType {
  primary,
  secondary,
  outlined,
  text,
  danger,
  success,
}

enum ButtonSize {
  small,
  medium,
  large,
}
