import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'image_service.dart';
import 'ai_recognition_service.dart';
import '../models/recognition_result.dart';
import '../../data/models/media_model.dart';
import '../../data/models/entry_model.dart';

/// 媒体服务类
class MediaService {
  final ImageService _imageService = ImageService();
  final AIRecognitionService _aiRecognitionService = AIRecognitionService();
  final ImagePicker _imagePicker = ImagePicker();

  /// 从相机拍照
  Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      print('Take photo error: $e');
      return null;
    }
  }

  /// 从相册选择图片
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Pick image error: $e');
      return null;
    }
  }

  /// 上传图片并获取URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      return await _imageService.uploadImage(imageFile);
    } catch (e) {
      print('Upload image error: $e');
      return null;
    }
  }

  /// 通过AI识别图片内容
  Future<RecognitionResult?> recognizeImage(File imageFile) async {
    try {
      // 首先上传图片获取URL
      final imageUrl = await uploadImage(imageFile);
      if (imageUrl == null) return null;
      
      // 使用URL进行AI识别
      return await _aiRecognitionService.recognizeFromUrl(imageUrl);
    } catch (e) {
      print('Recognize image error: $e');
      return null;
    }
  }

  /// 拍照并识别 - 完整流程
  Future<PhotoRecognitionResult?> captureAndRecognize() async {
    try {
      // 拍照
      final photo = await takePhoto();
      if (photo == null) return null;

      // 上传图片
      final imageUrl = await uploadImage(photo);
      if (imageUrl == null) return null;

      // AI识别
      final recognition = await _aiRecognitionService.recognizeFromUrl(imageUrl);
      
      return PhotoRecognitionResult(
        imageFile: photo,
        imageUrl: imageUrl,
        recognition: recognition,
      );
    } catch (e) {
      print('Capture and recognize error: $e');
      return null;
    }
  }

  /// 从图片选择并识别
  Future<PhotoRecognitionResult?> selectAndRecognize() async {
    try {
      // 选择图片
      final image = await pickImage();
      if (image == null) return null;

      // 上传图片
      final imageUrl = await uploadImage(image);
      if (imageUrl == null) return null;

      // AI识别
      final recognition = await _aiRecognitionService.recognizeFromUrl(imageUrl);
      
      return PhotoRecognitionResult(
        imageFile: image,
        imageUrl: imageUrl,
        recognition: recognition,
      );
    } catch (e) {
      print('Select and recognize error: $e');
      return null;
    }
  }

  /// 获取媒体类型
  MediaType getMediaType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.webp':
        return MediaType.image;
      case '.mp4':
      case '.mov':
      case '.avi':
      case '.mkv':
        return MediaType.video;
      case '.mp3':
      case '.wav':
      case '.aac':
      case '.m4a':
        return MediaType.audio;
      default:
        return MediaType.file;
    }
  }

  /// 获取MIME类型
  String getMimeType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.mkv':
        return 'video/x-matroska';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.aac':
        return 'audio/aac';
      case '.m4a':
        return 'audio/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  /// 模拟AI识别（用于测试）
  Future<RecognitionResult> mockRecognition() async {
    return await _aiRecognitionService.mockRecognition();
  }
}

/// 拍照识别结果
class PhotoRecognitionResult {
  final File imageFile;
  final String imageUrl;
  final RecognitionResult? recognition;

  PhotoRecognitionResult({
    required this.imageFile,
    required this.imageUrl,
    this.recognition,
  });

  /// 转换为Entry创建的建议数据
  EntryCreationSuggestion toEntryCreationSuggestion() {
    // 从识别结果中派生标题
    String title = '未识别的图片';
    String? content;
    
    if (recognition != null) {
      // 使用最有信心的对象名称作为标题
      if (recognition!.objects.isNotEmpty) {
        final mostConfident = recognition!.objects.reduce((a, b) => a.confidence > b.confidence ? a : b);
        title = mostConfident.name;
        
        // 创建内容描述
        final objectNames = recognition!.objects.map((obj) => obj.name).take(3).join('、');
        content = '识别到的物体：$objectNames';
        if (recognition!.colors.isNotEmpty) {
          content += '\n主要颜色：${recognition!.colors.take(3).join('、')}';
        }
      } else if (recognition!.scene.isNotEmpty) {
        title = recognition!.scene['description'] ?? recognition!.scene.values.first?.toString() ?? title;
      }
    }
    
    return EntryCreationSuggestion(
      title: title,
      content: content,
      tags: recognition?.suggestedTags ?? [],
      imageUrl: imageUrl,
      contentType: 'mixed',
    );
  }
}

/// Entry创建建议
class EntryCreationSuggestion {
  final String title;
  final String? content;
  final List<String> tags;
  final String imageUrl;
  final String contentType;

  EntryCreationSuggestion({
    required this.title,
    this.content,
    required this.tags,
    required this.imageUrl,
    required this.contentType,
  });
} 