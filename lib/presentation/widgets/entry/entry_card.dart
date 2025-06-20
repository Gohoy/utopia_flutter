import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:utopia_flutter/data/models/tag_model.dart';
import '../../../data/models/entry_model.dart';
import '../tags/tag_chip.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../styles/card_styles.dart';

class EntryCard extends StatelessWidget {
  final EntryModel entry;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final bool showAuthor;
  final bool showStats;
  final EntryCardType type;

  const EntryCard({
    Key? key,
    required this.entry,
    this.onTap,
    this.onLike,
    this.onShare,
    this.showAuthor = true,
    this.showStats = true,
    this.type = EntryCardType.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case EntryCardType.compact:
        return _buildCompactCard(context);
      case EntryCardType.featured:
        return _buildFeaturedCard(context);
      default:
        return _buildNormalCard(context);
    }
  }

  Widget _buildNormalCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和时间
              _buildHeader(context),
              
              // 内容预览
              if (entry.content != null && entry.content!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                _buildContent(context),
              ],

              // 标签
              if (entry.tags.isNotEmpty) ...[
                SizedBox(height: 12.h),
                _buildTags(context),
              ],

              // 底部信息
              SizedBox(height: 12.h),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 内容类型图标
              _buildContentTypeIcon(),
              SizedBox(width: 12.w),
              
              // 主要内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(entry.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 统计信息
              if (showStats) _buildCompactStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 特色标识
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16.w,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '精选',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(entry.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12.h),
              
              // 标题
              Text(
                entry.title,
                style: AppTextStyles.h3,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // 内容预览
              if (entry.content != null && entry.content!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  entry.content!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // 标签
              if (entry.tags.isNotEmpty) ...[
                SizedBox(height: 12.h),
                _buildTags(context),
              ],

              // 底部信息
              SizedBox(height: 16.h),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentTypeIcon(),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                _formatDate(entry.createdAt),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // 可见性图标
        _buildVisibilityIcon(),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      entry.content!,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags(BuildContext context) {
    // 将字符串标签转换为TagModel
    final tagModels = entry.tags.map((tagName) => TagModel(
      id: tagName.toLowerCase().replaceAll(' ', '_'),
      name: tagName,
      category: 'general',
      level: 0,
      usageCount: 0,
      qualityScore: 0.0,
      aliases: [],
      status: 'active',
      createdAt: DateTime.now(),
    )).toList();

    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: tagModels.take(4).map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.tagColors[tag.name.hashCode.abs() % AppColors.tagColors.length],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            tag.name,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.tagTextColors[tag.name.hashCode.abs() % AppColors.tagTextColors.length],
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // 作者信息
        if (showAuthor && entry.author != null) ...[
          CircleAvatar(
            radius: 12.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              entry.author!.nickname?.substring(0, 1) ?? 
              entry.author!.username.substring(0, 1),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            entry.author!.nickname ?? entry.author!.username,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
        ] else
          const Spacer(),

        // 统计信息
        if (showStats) ...[
          _buildStatItem(Icons.visibility, entry.viewCount),
          SizedBox(width: 16.w),
          _buildStatItem(Icons.favorite_border, entry.likeCount),
        ],
      ],
    );
  }

  Widget _buildCompactStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (entry.viewCount > 0)
          Text(
            '${entry.viewCount}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        Icon(
          Icons.keyboard_arrow_right,
          size: 16.w,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildContentTypeIcon() {
    IconData iconData;
    Color color;

    switch (entry.contentType) {
      case 'text':
        iconData = Icons.text_snippet_outlined;
        color = AppColors.info;
        break;
      case 'image':
        iconData = Icons.image_outlined;
        color = AppColors.success;
        break;
      case 'video':
        iconData = Icons.play_circle_outlined;
        color = AppColors.warning;
        break;
      case 'audio':
        iconData = Icons.audiotrack_outlined;
        color = AppColors.secondary;
        break;
      default:
        iconData = Icons.article_outlined;
        color = AppColors.primary;
    }

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        iconData,
        size: 16.w,
        color: color,
      ),
    );
  }

  Widget _buildVisibilityIcon() {
    if (entry.visibility == 'private') {
      return Icon(
        Icons.lock_outlined,
        size: 16.w,
        color: AppColors.warning,
      );
    } else if (entry.visibility == 'friends') {
      return Icon(
        Icons.people_outlined,
        size: 16.w,
        color: AppColors.info,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatItem(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14.w,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 4.w),
        Text(
          _formatCount(count),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

enum EntryCardType {
  normal,
  compact,
  featured,
}
