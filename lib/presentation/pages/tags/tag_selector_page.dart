import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/tag_provider.dart';
import '../../widgets/tags/tag_selector.dart';
import '../../../data/models/tag_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TagSelectorPage extends StatefulWidget {
  final List<TagModel>? initialTags;
  final int? maxSelection;
  final bool allowCreate;

  const TagSelectorPage({
    Key? key,
    this.initialTags,
    this.maxSelection,
    this.allowCreate = false,
  }) : super(key: key);

  @override
  State<TagSelectorPage> createState() => _TagSelectorPageState();
}

class _TagSelectorPageState extends State<TagSelectorPage> {
  List<TagModel> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _selectedTags = widget.initialTags ?? [];
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tagProvider = context.read<TagProvider>();
      tagProvider.initialize();
      if (_selectedTags.isNotEmpty) {
        tagProvider.setSelectedTags(
          _selectedTags.map((tag) => tag.name).toList(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 统计信息
          _buildStatsBar(),
          
          // 分割线
          const Divider(height: 1),
          
          // 标签选择器
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: TagSelector(
                selectedTags: _selectedTags,
                onChanged: (tags) {
                  setState(() {
                    _selectedTags = tags;
                  });
                },
                maxSelection: widget.maxSelection,
                allowCreate: widget.allowCreate,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('选择标签'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (widget.allowCreate)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateTagDialog,
            tooltip: '创建新标签',
          ),
        TextButton(
          onPressed: _selectedTags.isNotEmpty ? _confirmSelection : null,
          child: const Text('确定'),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.surfaceVariant,
      child: Row(
        children: [
          Icon(
            Icons.label,
            size: 18.w,
            color: AppColors.primary,
          ),
          SizedBox(width: 8.w),
          Text(
            '已选择 ${_selectedTags.length} 个标签',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.maxSelection != null) ...[
            Text(
              ' / ${widget.maxSelection}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const Spacer(),
          if (_selectedTags.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTags.clear();
                });
                context.read<TagProvider>().clearSelectedTags();
              },
              child: Text(
                '清空',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('取消'),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedTags.isNotEmpty ? _confirmSelection : null,
              child: Text('确定 (${_selectedTags.length})'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSelection() {
    context.pop(_selectedTags);
  }

  void _showCreateTagDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateTagDialog(
        onTagCreated: (tag) {
          setState(() {
            _selectedTags.add(tag);
          });
          context.read<TagProvider>().selectTag(tag);
        },
      ),
    );
  }
}

class _CreateTagDialog extends StatefulWidget {
  final ValueChanged<TagModel> onTagCreated;

  const _CreateTagDialog({
    Key? key,
    required this.onTagCreated,
  }) : super(key: key);

  @override
  State<_CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends State<_CreateTagDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameEnController = TextEditingController();
  String _selectedCategory = 'user_defined';
  
  final List<String> _categories = [
    'user_defined',
    'animal',
    'plant',
    'food',
    'travel',
    'life',
    'emotion',
    'hobby',
    'other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameEnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建新标签'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '标签名称',
                hintText: '输入标签名称',
              ),
              autofocus: true,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述（可选）',
                hintText: '输入标签描述',
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _nameEnController,
              decoration: const InputDecoration(
                labelText: '英文名称（可选）',
                hintText: '输入英文名称',
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '分类',
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryName(category)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        Consumer<TagProvider>(
          builder: (context, tagProvider, child) {
            return ElevatedButton(
              onPressed: tagProvider.isLoading 
                  ? null 
                  : () => _createTag(tagProvider),
              child: tagProvider.isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('创建'),
            );
          },
        ),
      ],
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'user_defined': return '用户定义';
      case 'animal': return '动物';
      case 'plant': return '植物';
      case 'food': return '美食';
      case 'travel': return '旅行';
      case 'life': return '生活';
      case 'emotion': return '情感';
      case 'hobby': return '爱好';
      case 'other': return '其他';
      default: return category;
    }
  }

  void _createTag(TagProvider tagProvider) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('请输入标签名称');
      return;
    }

    final success = await tagProvider.createTag(
      name: name,
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      category: _selectedCategory,
      nameEn: _nameEnController.text.trim().isEmpty 
          ? null 
          : _nameEnController.text.trim(),
    );

    if (success) {
      // 创建本地标签对象
      final newTag = TagModel(
        id: name.toLowerCase().replaceAll(' ', '_'),
        name: name,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        level: 0,
        usageCount: 0,
        qualityScore: 0.0,
        aliases: [],
        status: 'active',
        createdAt: DateTime.now(),
        nameEn: _nameEnController.text.trim().isEmpty 
            ? null 
            : _nameEnController.text.trim(),
      );

      widget.onTagCreated(newTag);
      if (mounted) {
        Navigator.pop(context);
        _showMessage('标签创建成功', isError: false);
      }
    } else {
      if (mounted && tagProvider.error != null) {
        _showMessage(tagProvider.error!);
      }
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }
}
