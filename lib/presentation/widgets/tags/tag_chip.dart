import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/chip_styles.dart';
import '../../../data/models/tag_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TagChip extends StatelessWidget {
  final TagModel tag;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final TagChipStyle style;
  final int? colorIndex;

  const TagChip({
    Key? key,
    required this.tag,
    this.selected = false,
    this.onTap,
    this.onDelete,
    this.style = TagChipStyle.basic,
    this.colorIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case TagChipStyle.colorful:
        return ChipStyles.buildColorfulChip(
          label: tag.name,
          colorIndex: colorIndex ?? tag.name.hashCode,
          selected: selected,
          onTap: onTap,
          onDeleted: onDelete,
        );
      case TagChipStyle.selectable:
        return ChipStyles.buildSelectableChip(
          label: tag.name,
          selected: selected,
          onSelected: (value) => onTap?.call(),
          colorIndex: colorIndex,
        );
      case TagChipStyle.input:
        return ChipStyles.buildInputChip(
          label: tag.name,
          onDeleted: onDelete!,
          colorIndex: colorIndex,
        );
      case TagChipStyle.compact:
        return ChipStyles.buildCompactChip(
          label: tag.name,
          onTap: onTap,
        );
      default:
        return ChipStyles.buildBasicChip(
          label: tag.name,
          selected: selected,
          onTap: onTap,
          onDeleted: onDelete,
        );
    }
  }
}

class TagChipList extends StatelessWidget {
  final List<TagModel> tags;
  final List<TagModel>? selectedTags;
  final ValueChanged<TagModel>? onTagTap;
  final ValueChanged<TagModel>? onTagDelete;
  final TagChipStyle style;
  final int maxLines;
  final bool showMoreButton;
  final VoidCallback? onShowMore;

  const TagChipList({
    Key? key,
    required this.tags,
    this.selectedTags,
    this.onTagTap,
    this.onTagDelete,
    this.style = TagChipStyle.basic,
    this.maxLines = 3,
    this.showMoreButton = false,
    this.onShowMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        ...tags.map((tag) {
          final isSelected = selectedTags?.any((t) => t.id == tag.id) ?? false;
          return TagChip(
            tag: tag,
            selected: isSelected,
            onTap: onTagTap != null ? () => onTagTap!(tag) : null,
            onDelete: onTagDelete != null ? () => onTagDelete!(tag) : null,
            style: style,
            colorIndex: tag.name.hashCode,
          );
        }).toList(),
        if (showMoreButton && onShowMore != null)
          _buildMoreButton(context),
      ],
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: onShowMore,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '更多',
              style: AppTextStyles.tagText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_right,
              size: 16.w,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class EditableTagList extends StatefulWidget {
  final List<TagModel> tags;
  final ValueChanged<List<TagModel>>? onChanged;
  final String? hint;
  final bool allowAdd;
  final bool allowDelete;

  const EditableTagList({
    Key? key,
    required this.tags,
    this.onChanged,
    this.hint,
    this.allowAdd = true,
    this.allowDelete = true,
  }) : super(key: key);

  @override
  State<EditableTagList> createState() => _EditableTagListState();
}

class _EditableTagListState extends State<EditableTagList> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tags.isNotEmpty) ...[
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.tags.map((tag) {
              return TagChip(
                tag: tag,
                style: TagChipStyle.input,
                onDelete: widget.allowDelete
                    ? () => _removeTag(tag)
                    : null,
                colorIndex: tag.name.hashCode,
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),
        ],
        if (widget.allowAdd) _buildAddTagField(),
      ],
    );
  }

  Widget _buildAddTagField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: widget.hint ?? '输入标签名称...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: _addTag,
        ),
      ),
      onSubmitted: (_) => _addTag(),
      textInputAction: TextInputAction.done,
    );
  }

  void _addTag() {
    final tagName = _controller.text.trim();
    if (tagName.isEmpty) return;

    // 检查是否已存在
    final exists = widget.tags.any(
      (tag) => tag.name.toLowerCase() == tagName.toLowerCase(),
    );

    if (exists) {
      _showMessage('标签已存在');
      return;
    }

    // 创建新标签
    final newTag = TagModel(
      id: tagName.toLowerCase().replaceAll(' ', '_'),
      name: tagName,
      category: 'user_defined',
      level: 0,
      usageCount: 0,
      qualityScore: 0.0,
      aliases: [],
      status: 'active',
      createdAt: DateTime.now(),
    );

    final updatedTags = [...widget.tags, newTag];
    widget.onChanged?.call(updatedTags);

    _controller.clear();
    _focusNode.requestFocus();
  }

  void _removeTag(TagModel tag) {
    final updatedTags = widget.tags.where((t) => t.id != tag.id).toList();
    widget.onChanged?.call(updatedTags);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

enum TagChipStyle {
  basic,
  colorful,
  selectable,
  input,
  compact,
}
