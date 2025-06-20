import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/entry_provider.dart';
import '../../providers/tag_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/tags/tag_selector.dart';
import '../../../data/models/tag_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CreateEntryPage extends StatefulWidget {
  const CreateEntryPage({Key? key}) : super(key: key);

  @override
  State<CreateEntryPage> createState() => _CreateEntryPageState();
}

class _CreateEntryPageState extends State<CreateEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _contentType = 'text';
  String _visibility = 'public';
  int? _moodScore;
  List<TagModel> _selectedTags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<EntryProvider>(
        builder: (context, entryProvider, child) {
          return LoadingOverlay(
            isLoading: entryProvider.isLoading,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题输入
                    _buildTitleField(),
                    
                    SizedBox(height: 20.h),
                    
                    // 内容类型选择
                    _buildContentTypeSelector(),
                    
                    SizedBox(height: 20.h),
                    
                    // 内容输入
                    _buildContentField(),
                    
                    SizedBox(height: 20.h),
                    
                    // 位置信息
                    _buildLocationField(),
                    
                    SizedBox(height: 20.h),
                    
                    // 心情评分
                    _buildMoodScoreSelector(),
                    
                    SizedBox(height: 20.h),
                    
                    // 可见性设置
                    _buildVisibilitySelector(),
                    
                    SizedBox(height: 20.h),
                    
                    // 标签选择
                    _buildTagSelector(),
                    
                    SizedBox(height: 32.h),
                    
                    // 提交按钮
                    _buildSubmitButton(entryProvider),
                    
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('创建图鉴'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => _showExitDialog(),
      ),
      actions: [
        TextButton(
          onPressed: _saveDraft,
          child: const Text('保存草稿'),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标题',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: _titleController,
          hint: '为你的图鉴起个好听的名字...',
          maxLength: 200,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildContentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '内容类型',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: [
            _buildContentTypeChip('text', '文字', Icons.text_snippet_outlined),
            _buildContentTypeChip('image', '图片', Icons.image_outlined),
            _buildContentTypeChip('video', '视频', Icons.videocam_outlined),
            _buildContentTypeChip('audio', '音频', Icons.audiotrack_outlined),
            _buildContentTypeChip('mixed', '混合', Icons.dashboard_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildContentTypeChip(String type, String label, IconData icon) {
    final isSelected = _contentType == type;
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _contentType = type;
        });
      },
      avatar: Icon(
        icon,
        size: 18.w,
        color: isSelected ? AppColors.white : AppColors.textSecondary,
      ),
      label: Text(label),
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '内容',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: _contentController,
          hint: '写下你想记录的内容...',
          type: TextFieldType.multiline,
          maxLines: 8,
          minLines: 4,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '位置信息',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: _locationController,
          hint: '记录地点（可选）',
          prefixIcon: Icon(
            Icons.location_on_outlined,
            size: 20.w,
            color: AppColors.textSecondary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.my_location,
              size: 20.w,
              color: AppColors.primary,
            ),
            onPressed: _getCurrentLocation,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodScoreSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '心情评分',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Text(
              '当前心情：',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 8.w),
            ...List.generate(10, (index) {
              final score = index + 1;
              final isSelected = _moodScore == score;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _moodScore = isSelected ? null : score;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 4.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    score.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? AppColors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '1分最低，10分最高（可选）',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '可见性',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildVisibilityChip('public', '公开', Icons.public),
            SizedBox(width: 8.w),
            _buildVisibilityChip('friends', '好友', Icons.people),
            SizedBox(width: 8.w),
            _buildVisibilityChip('private', '私有', Icons.lock),
          ],
        ),
      ],
    );
  }

  Widget _buildVisibilityChip(String type, String label, IconData icon) {
    final isSelected = _visibility == type;
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _visibility = type;
        });
      },
      avatar: Icon(
        icon,
        size: 18.w,
        color: isSelected ? AppColors.white : AppColors.textSecondary,
      ),
      label: Text(label),
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标签',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CompactTagSelector(
          selectedTags: _selectedTags,
          onChanged: (tags) {
            setState(() {
              _selectedTags = tags;
            });
          },
          onTap: () => _showTagSelector(),
          hint: '添加标签来分类你的图鉴',
        ),
      ],
    );
  }

  Widget _buildSubmitButton(EntryProvider entryProvider) {
    return CustomButton(
      text: '发布图鉴',
      onPressed: () => _submitEntry(entryProvider),
      isFullWidth: true,
      isLoading: entryProvider.isLoading,
    );
  }

  void _showTagSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Text(
                  '选择标签',
                  style: AppTextStyles.h3,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('完成'),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 标签选择器
            Expanded(
              child: TagSelector(
                selectedTags: _selectedTags,
                onChanged: (tags) {
                  setState(() {
                    _selectedTags = tags;
                  });
                },
                maxSelection: 10,
                allowCreate: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getCurrentLocation() {
    // TODO: 实现获取当前位置
    _showMessage('获取位置功能待实现');
  }

  void _saveDraft() {
    // TODO: 实现保存草稿
    _showMessage('草稿已保存');
  }

  void _submitEntry(EntryProvider entryProvider) async {
    if (!_validateForm()) return;

    final success = await entryProvider.createEntry(
      title: _titleController.text.trim(),
      content: _contentController.text.trim().isEmpty 
          ? null 
          : _contentController.text.trim(),
      contentType: _contentType,
      locationName: _locationController.text.trim().isEmpty 
          ? null 
          : _locationController.text.trim(),
      moodScore: _moodScore,
      visibility: _visibility,
      tags: _selectedTags.map((tag) => tag.name).toList(),
    );

    if (success) {
      if (mounted) {
        _showMessage('图鉴创建成功！', isError: false);
        context.pop();
      }
    } else {
      if (mounted && entryProvider.error != null) {
        _showMessage(entryProvider.error!);
      }
    }
  }

  bool _validateForm() {
    if (_titleController.text.trim().isEmpty) {
      _showMessage('请输入标题');
      return false;
    }

    if (_titleController.text.trim().length > 200) {
      _showMessage('标题长度不能超过200字符');
      return false;
    }

    return true;
  }

  void _showExitDialog() {
    final hasContent = _titleController.text.trim().isNotEmpty ||
                      _contentController.text.trim().isNotEmpty ||
                      _locationController.text.trim().isNotEmpty ||
                      _selectedTags.isNotEmpty;

    if (hasContent) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认退出'),
          content: const Text('你有未保存的内容，确定要退出吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('退出'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
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
