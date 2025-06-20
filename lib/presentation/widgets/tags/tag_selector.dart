import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/tag_provider.dart';
import '../../../data/models/tag_model.dart';
import '../common/custom_text_field.dart';
import '../common/loading_widget.dart';
import 'tag_chip.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TagSelector extends StatefulWidget {
  final List<TagModel> selectedTags;
  final ValueChanged<List<TagModel>>? onChanged;
  final int? maxSelection;
  final bool showSearch;
  final bool showPopular;
  final bool showRecommended;
  final bool allowCreate;

  const TagSelector({
    Key? key,
    required this.selectedTags,
    this.onChanged,
    this.maxSelection,
    this.showSearch = true,
    this.showPopular = true,
    this.showRecommended = true,
    this.allowCreate = false,
  }) : super(key: key);

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tagProvider = context.read<TagProvider>();
      tagProvider.setSelectedTags(
        widget.selectedTags.map((tag) => tag.name).toList(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TagProvider>(
      builder: (context, tagProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 已选择的标签
            if (tagProvider.selectedTags.isNotEmpty) ...[
              _buildSectionTitle('已选择', tagProvider.selectedTags.length),
              SizedBox(height: 8.h),
              TagChipList(
                tags: tagProvider.selectedTags,
                style: TagChipStyle.input,
                onTagDelete: (tag) => _onTagToggle(tagProvider, tag),
              ),
              SizedBox(height: 16.h),
            ],

            // 搜索框
            if (widget.showSearch) ...[
              _buildSearchField(tagProvider),
              SizedBox(height: 16.h),
            ],

            // 搜索结果
            if (_searchQuery.isNotEmpty) ...[
              _buildSearchResults(tagProvider),
            ] else ...[
              // 推荐标签
              if (widget.showRecommended && tagProvider.recommendedTags.isNotEmpty) ...[
                _buildRecommendedTags(tagProvider),
                SizedBox(height: 16.h),
              ],

              // 热门标签
              if (widget.showPopular) ...[
                _buildPopularTags(tagProvider),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, [int? count]) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.h4,
        ),
        if (count != null) ...[
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              count.toString(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchField(TagProvider tagProvider) {
    return CustomTextField(
      controller: _searchController,
      hint: '搜索标签...',
      type: TextFieldType.search,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
        if (value.trim().isNotEmpty) {
          tagProvider.searchTags(value);
        } else {
          tagProvider.clearSearch();
        }
      },
      onSubmitted: (value) {
        if (widget.allowCreate && value.trim().isNotEmpty) {
          _createNewTag(tagProvider, value.trim());
        }
      },
      textInputAction: widget.allowCreate 
          ? TextInputAction.done 
          : TextInputAction.search,
    );
  }

  Widget _buildSearchResults(TagProvider tagProvider) {
    if (tagProvider.isLoading) {
      return const LoadingWidget(message: '搜索中...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('搜索结果', tagProvider.searchResults.length),
            if (widget.allowCreate && _searchQuery.isNotEmpty)
              TextButton.icon(
                onPressed: () => _createNewTag(tagProvider, _searchQuery),
                icon: const Icon(Icons.add),
                label: Text('创建 "$_searchQuery"'),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        if (tagProvider.searchResults.isEmpty)
          _buildEmptyState('未找到相关标签')
        else
          TagChipList(
            tags: tagProvider.searchResults,
            selectedTags: tagProvider.selectedTags,
            style: TagChipStyle.selectable,
            onTagTap: (tag) => _onTagToggle(tagProvider, tag),
          ),
      ],
    );
  }

  Widget _buildRecommendedTags(TagProvider tagProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('推荐标签', tagProvider.recommendedTags.length),
        SizedBox(height: 8.h),
        TagChipList(
          tags: tagProvider.recommendedTags,
          selectedTags: tagProvider.selectedTags,
          style: TagChipStyle.colorful,
          onTagTap: (tag) => _onTagToggle(tagProvider, tag),
        ),
      ],
    );
  }

  Widget _buildPopularTags(TagProvider tagProvider) {
    if (tagProvider.isLoading && tagProvider.popularTags.isEmpty) {
      return const LoadingWidget(message: '加载热门标签...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('热门标签', tagProvider.popularTags.length),
        SizedBox(height: 8.h),
        if (tagProvider.popularTags.isEmpty)
          _buildEmptyState('暂无热门标签')
        else
          TagChipList(
            tags: tagProvider.popularTags,
            selectedTags: tagProvider.selectedTags,
            style: TagChipStyle.colorful,
            onTagTap: (tag) => _onTagToggle(tagProvider, tag),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        children: [
          Icon(
            Icons.label_outline,
            size: 48.w,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _onTagToggle(TagProvider tagProvider, TagModel tag) {
    // 检查最大选择限制
    if (widget.maxSelection != null && 
        !tagProvider.isTagSelected(tag) && 
        tagProvider.selectedTags.length >= widget.maxSelection!) {
      _showMessage('最多只能选择${widget.maxSelection}个标签');
      return;
    }

    tagProvider.toggleTag(tag);
    widget.onChanged?.call(tagProvider.selectedTags);
  }

  void _createNewTag(TagProvider tagProvider, String tagName) {
    tagProvider.addTagByName(tagName);
    widget.onChanged?.call(tagProvider.selectedTags);
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    tagProvider.clearSearch();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class CompactTagSelector extends StatelessWidget {
  final List<TagModel> selectedTags;
  final ValueChanged<List<TagModel>>? onChanged;
  final VoidCallback? onTap;
  final String? hint;

  const CompactTagSelector({
    Key? key,
    required this.selectedTags,
    this.onChanged,
    this.onTap,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: selectedTags.isEmpty
            ? _buildPlaceholder()
            : _buildSelectedTags(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Row(
      children: [
        Icon(
          Icons.label_outline,
          size: 20.w,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 12.w),
        Text(
          hint ?? '添加标签',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.keyboard_arrow_right,
          size: 20.w,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildSelectedTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.label,
              size: 20.w,
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              '已选择 ${selectedTags.length} 个标签',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_right,
              size: 20.w,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: selectedTags.take(6).map((tag) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                tag.name,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        if (selectedTags.length > 6) ...[
          SizedBox(height: 4.h),
          Text(
            '还有${selectedTags.length - 6}个标签...',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
