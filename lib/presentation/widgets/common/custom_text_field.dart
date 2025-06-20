import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/text_field_styles.dart';
import '../../../core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool required;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextFieldType type;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.type = TextFieldType.basic,
    this.focusNode,
    this.textInputAction,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _buildLabel(),
          SizedBox(height: 8.h),
        ],
        _buildTextField(),
        if (widget.helperText != null || widget.errorText != null) ...[
          SizedBox(height: 4.h),
          _buildHelperText(),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          widget.label!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        if (widget.required) ...[
          SizedBox(width: 4.w),
          Text(
            '*',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 14.sp,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField() {
    InputDecoration decoration = _getDecoration();
    
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      decoration: decoration,
    );
  }

  InputDecoration _getDecoration() {
    InputDecoration baseDecoration;
    
    switch (widget.type) {
      case TextFieldType.search:
        baseDecoration = TextFieldStyles.search;
        break;
      case TextFieldType.multiline:
        baseDecoration = TextFieldStyles.multiline;
        break;
      case TextFieldType.clean:
        baseDecoration = TextFieldStyles.clean;
        break;
      default:
        baseDecoration = TextFieldStyles.basic;
    }

    return baseDecoration.copyWith(
      hintText: widget.hint,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(),
      counterText: widget.maxLength != null ? null : '',
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: AppColors.textSecondary,
          size: 20.w,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  Widget _buildHelperText() {
    final text = widget.errorText ?? widget.helperText;
    final color = widget.errorText != null ? AppColors.error : AppColors.textSecondary;
    
    return Text(
      text!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: color,
      ),
    );
  }
}

enum TextFieldType {
  basic,
  search,
  multiline,
  clean,
}
