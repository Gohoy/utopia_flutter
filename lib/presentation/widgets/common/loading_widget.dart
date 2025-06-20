import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;
  final Color? color;
  final double? size;

  const LoadingWidget({
    Key? key,
    this.message,
    this.showMessage = true,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40.w,
            height: size ?? 40.h,
            child: CircularProgressIndicator(
              strokeWidth: 3.w,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (showMessage && message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: LoadingWidget(
              message: loadingMessage ?? '加载中...',
            ),
          ),
      ],
    );
  }
}

class ListLoadingWidget extends StatelessWidget {
  final bool isLoading;
  final String? message;

  const ListLoadingWidget({
    Key? key,
    required this.isLoading,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            message ?? '加载更多...',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final String? message;
  final Widget? icon;
  final VoidCallback? onRetry;
  final String? retryText;

  const EmptyWidget({
    Key? key,
    this.message,
    this.icon,
    this.onRetry,
    this.retryText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                Icon(
                  Icons.inbox_outlined,
                  size: 64.w,
                  color: AppColors.textSecondary,
                ),
            SizedBox(height: 16.h),
            Text(
              message ?? '暂无数据',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              TextButton(
                onPressed: onRetry,
                child: Text(retryText ?? '重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorWidget({
    Key? key,
    this.message,
    this.onRetry,
    this.retryText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              message ?? '加载失败',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              TextButton(
                onPressed: onRetry,
                child: Text(retryText ?? '重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
