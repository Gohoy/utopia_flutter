import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/entry_provider.dart';
// import '../../providers/tag_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/tags/tag_selector.dart';
import '../../../data/models/tag_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/media_service.dart';
import '../../../core/services/ai_recognition_service.dart';
import 'dart:io';

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
  final _mediaService = MediaService();

  String _contentType = 'mixed';
  String _visibility = 'public';
  int? _moodScore;
  List<TagModel> _selectedTags = [];
  
  // 媒体相关状态
  String? _selectedImageUrl;
  File? _selectedImageFile;
  bool _isProcessingImage = false;

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

                    // 拍照区域
                    _buildCameraSection(),

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

  Widget _buildCameraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '拍照识别',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        
        // 图片显示区域
        if (_selectedImageUrl != null) ...[
          Container(
            width: double.infinity,
            height: 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                _selectedImageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceVariant,
                    child: Center(
                      child: Icon(
                        Icons.error,
                        size: 48.w,
                        color: AppColors.error,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        
                 // 拍照按钮
         Row(
           children: [
             Expanded(
               child: CustomButton(
                 text: '拍照识别',
                 onPressed: _isProcessingImage ? null : _captureAndRecognize,
                 isLoading: _isProcessingImage,
                 icon: Icon(Icons.camera_alt, size: 18.w),
               ),
             ),
             SizedBox(width: 12.w),
             Expanded(
               child: CustomButton(
                 text: '从相册选择',
                 onPressed: _isProcessingImage ? null : _selectAndRecognize,
                 isLoading: _isProcessingImage,
                 icon: Icon(Icons.photo_library, size: 18.w),
                 type: ButtonType.secondary,
               ),
             ),
           ],
         ),
        
        // 提示文字
        if (_selectedImageUrl == null) ...[
          SizedBox(height: 8.h),
          Text(
            '点击拍照或选择图片，AI将自动识别内容并填充图鉴信息',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  // Widget _buildContentTypeSelector() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         '内容类型',
  //         style: AppTextStyles.bodyLarge.copyWith(
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       SizedBox(height: 8.h),
  //       Wrap(
  //         spacing: 8.w,
  //         children: [
  //           _buildContentTypeChip('mixed', '混合', Icons.dashboard_outlined),
  //           _buildContentTypeChip('text', '文字', Icons.text_snippet_outlined),
  //           // _buildContentTypeChip('image', '图片', Icons.image_outlined),
  //           // _buildContentTypeChip('video', '视频', Icons.videocam_outlined),
  //           // _buildContentTypeChip('audio', '音频', Icons.audiotrack_outlined),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildContentTypeChip(String type, String label, IconData icon) {
  //   final isSelected = _contentType == type;
  //   return FilterChip(
  //     selected: isSelected,
  //     onSelected: (selected) {
  //       setState(() {
  //         _contentType = type;
  //       });
  //     },
  //     avatar: Icon(
  //       icon,
  //       size: 18.w,
  //       color: isSelected ? AppColors.white : AppColors.textSecondary,
  //     ),
  //     label: Text(label),
  //     backgroundColor: AppColors.surfaceVariant,
  //     selectedColor: AppColors.primary,
  //     labelStyle: AppTextStyles.bodyMedium.copyWith(
  //       color: isSelected ? AppColors.white : AppColors.textPrimary,
  //     ),
  //   );
  // }

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
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
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
      mediaUrls: _selectedImageUrl != null ? [_selectedImageUrl!] : [],
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

  /// 拍照并识别
  Future<void> _captureAndRecognize() async {
    setState(() {
      _isProcessingImage = true;
    });

    try {
             final result = await _mediaService.captureAndRecognize();
       
       if (result != null) {
         setState(() {
           _selectedImageUrl = result.imageUrl;
           _selectedImageFile = result.imageFile;
         });
         
         // 使用AI识别结果填充表单
         if (result.recognition != null) {
           final recognition = result.recognition!;
           
           // 填充标题 - 使用最有信心的对象名称或场景描述
           String? derivedTitle;
           if (recognition.objects.isNotEmpty) {
             final mostConfident = recognition.objects.reduce((a, b) => a.confidence > b.confidence ? a : b);
             derivedTitle = mostConfident.name;
           } else if (recognition.scene.isNotEmpty) {
             derivedTitle = recognition.scene['description'] ?? recognition.scene.values.first?.toString();
           }
           
           if (derivedTitle != null && _titleController.text.isEmpty) {
             _titleController.text = derivedTitle;
           }
           
           // 填充内容 - 使用识别结果创建描述
           String? derivedDescription;
           if (recognition.objects.isNotEmpty) {
             final objectNames = recognition.objects.map((obj) => obj.name).take(3).join('、');
             derivedDescription = '识别到的物体：$objectNames';
             if (recognition.colors.isNotEmpty) {
               derivedDescription += '\n主要颜色：${recognition.colors.take(3).join('、')}';
             }
           }
           
           if (derivedDescription != null && _contentController.text.isEmpty) {
             _contentController.text = derivedDescription;
           }
           
           // 填充标签
           if (recognition.suggestedTags.isNotEmpty) {
             final newTags = recognition.suggestedTags.map((tagName) => TagModel(
               id: tagName,
               name: tagName,
               category: recognition.objects.isNotEmpty ? recognition.objects.first.category : '其他',
               level: 0,
               usageCount: 0,
               qualityScore: 0.5,
               aliases: [],
               status: 'active',
               createdAt: DateTime.now(),
             )).toList();
             
             setState(() {
               _selectedTags = newTags;
             });
           }
           
           // 设置内容类型为混合
           setState(() {
             _contentType = 'mixed';
           });
           
           _showMessage('AI识别完成！已自动填充图鉴信息', isError: false);
         } else {
           _showMessage('图片上传成功，但AI识别失败，请手动填写信息', isError: false);
         }
       } else {
         _showMessage('拍照或上传失败，请重试');
       }
    } catch (e) {
      _showMessage('拍照识别失败：$e');
    } finally {
      setState(() {
        _isProcessingImage = false;
      });
    }
  }

  /// 从相册选择并识别
  Future<void> _selectAndRecognize() async {
    setState(() {
      _isProcessingImage = true;
    });

    try {
             final result = await _mediaService.selectAndRecognize();
       
       if (result != null) {
         setState(() {
           _selectedImageUrl = result.imageUrl;
           _selectedImageFile = result.imageFile;
         });
         
         // 使用AI识别结果填充表单
         if (result.recognition != null) {
           final recognition = result.recognition!;
           
           // 填充标题 - 使用最有信心的对象名称或场景描述
           String? derivedTitle;
           if (recognition.objects.isNotEmpty) {
             final mostConfident = recognition.objects.reduce((a, b) => a.confidence > b.confidence ? a : b);
             derivedTitle = mostConfident.name;
           } else if (recognition.scene.isNotEmpty) {
             derivedTitle = recognition.scene['description'] ?? recognition.scene.values.first?.toString();
           }
           
           if (derivedTitle != null && _titleController.text.isEmpty) {
             _titleController.text = derivedTitle;
           }
           
           // 填充内容 - 使用识别结果创建描述
           String? derivedDescription;
           if (recognition.objects.isNotEmpty) {
             final objectNames = recognition.objects.map((obj) => obj.name).take(3).join('、');
             derivedDescription = '识别到的物体：$objectNames';
             if (recognition.colors.isNotEmpty) {
               derivedDescription += '\n主要颜色：${recognition.colors.take(3).join('、')}';
             }
           }
           
           if (derivedDescription != null && _contentController.text.isEmpty) {
             _contentController.text = derivedDescription;
           }
           
           // 填充标签
           if (recognition.suggestedTags.isNotEmpty) {
             final newTags = recognition.suggestedTags.map((tagName) => TagModel(
               id: tagName,
               name: tagName,
               category: recognition.objects.isNotEmpty ? recognition.objects.first.category : '其他',
               level: 0,
               usageCount: 0,
               qualityScore: 0.5,
               aliases: [],
               status: 'active',
               createdAt: DateTime.now(),
             )).toList();
             
             setState(() {
               _selectedTags = newTags;
             });
           }
           
           // 设置内容类型为混合
           setState(() {
             _contentType = 'mixed';
           });
           
           _showMessage('AI识别完成！已自动填充图鉴信息', isError: false);
         } else {
           _showMessage('图片上传成功，但AI识别失败，请手动填写信息', isError: false);
         }
       } else {
         _showMessage('选择图片或上传失败，请重试');
       }
    } catch (e) {
      _showMessage('选择识别失败：$e');
    } finally {
      setState(() {
        _isProcessingImage = false;
      });
    }
  }
}
