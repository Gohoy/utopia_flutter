import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../core/services/ai_recognition_service.dart';
import '../../core/models/recognition_result.dart';

class CameraRecognitionPage extends StatefulWidget {
  const CameraRecognitionPage({Key? key}) : super(key: key);

  @override
  State<CameraRecognitionPage> createState() => _CameraRecognitionPageState();
}

class _CameraRecognitionPageState extends State<CameraRecognitionPage> {
  final AIRecognitionService _aiService = AIRecognitionService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // 为Web平台存储图片字节数据
  RecognitionResult? _recognitionResult;
  bool _isLoading = false;
  String _loadingMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能识别'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_selectedImage != null || _selectedImageBytes != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetSelection,
            ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16.h),
                    Text(
                      _loadingMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_selectedImage == null && _selectedImageBytes == null) {
      return _buildWelcomeScreen();
    } else if (_recognitionResult == null) {
      return _buildImagePreview();
    } else {
      return _buildRecognitionResults();
    }
  }

  // 根据平台显示图片的辅助方法
  Widget _buildImageWidget({BoxFit fit = BoxFit.cover}) {
    if (kIsWeb) {
      return _selectedImageBytes != null
          ? Image.memory(_selectedImageBytes!, fit: fit)
          : Container();
    } else {
      return _selectedImage != null
          ? Image.file(_selectedImage!, fit: fit)
          : Container();
    }
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 80.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24.h),
          Text(
            '拍照识别',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '拍摄或选择图片，AI将自动识别内容\n并生成相应的标签',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 48.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.camera_alt,
                label: '拍照',
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              _buildActionButton(
                icon: Icons.photo_library,
                label: '相册',
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 28.w),
            onPressed: onPressed,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: _buildImageWidget(fit: BoxFit.cover),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: _recognizeImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '开始识别',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecognitionResults() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片预览
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: _buildImageWidget(fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 24.h),
          
          // 识别结果
          _buildRecognitionResultCard(),
          SizedBox(height: 24.h),
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetSelection,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '重新拍摄',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _showCreateEntryDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '创建图鉴',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionResultCard() {
    final result = _recognitionResult!;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '识别结果',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            // 识别到的物体
            if (result.objects.isNotEmpty) ...[
              Text(
                '识别到的物体:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: result.objects.map((obj) => Chip(
                  label: Text('${obj.name} (${(obj.confidence * 100).toInt()}%)'),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                )).toList(),
              ),
              SizedBox(height: 16.h),
            ],
            
            // 颜色
            if (result.colors.isNotEmpty) ...[
              Text(
                '主要颜色:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: result.colors.map((color) => Chip(
                  label: Text(color),
                  backgroundColor: Colors.green.withOpacity(0.1),
                )).toList(),
              ),
              SizedBox(height: 16.h),
            ],
            
            // 建议的标签
            if (result.suggestedTags.isNotEmpty) ...[
              Text(
                '建议的标签:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: result.suggestedTags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.orange.withOpacity(0.1),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  FloatingActionButton? _buildFloatingActionButton() {
    if ((_selectedImage != null || _selectedImageBytes != null) && _recognitionResult != null) {
      return null;
    }
    
    return FloatingActionButton.extended(
      onPressed: () => _pickImage(ImageSource.camera),
      icon: const Icon(Icons.camera_alt),
      label: const Text('拍照'),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile == null) return;

      setState(() {
        if (kIsWeb) {
          _selectedImage = null;
          _selectedImageBytes = null;
          // 在Web平台读取字节数据
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _selectedImageBytes = bytes;
            });
          });
        } else {
          _selectedImage = File(pickedFile.path);
          _selectedImageBytes = null;
        }
        _recognitionResult = null;
      });
    } catch (e) {
      _showErrorDialog('选择图片失败: ${e.toString()}');
    }
  }

  Future<void> _recognizeImage() async {
    if (_selectedImage == null && _selectedImageBytes == null) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = '正在识别图片内容...';
    });

    try {
      RecognitionResult? result;
      
      if (kIsWeb) {
        // Web平台：使用模拟识别，因为无法直接处理File
        result = await _aiService.mockRecognition();
      } else {
        // 移动平台：使用文件识别
        result = await _aiService.recognizeFromFile(_selectedImage!);
      }
      
      setState(() {
        _recognitionResult = result;
        _isLoading = false;
      });
    } catch (e,s) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('识别失败3: ${e.toString()}');
      print('识别失败31: ${e.toString()},${s.toString()}');
    }
  }

  void _showCreateEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建图鉴'),
        content: const Text('图鉴创建功能即将推出，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _resetSelection() {
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
      _recognitionResult = null;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 