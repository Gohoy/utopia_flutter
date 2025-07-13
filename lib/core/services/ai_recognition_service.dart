import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';

/// AI识图结果模型
class RecognitionResult {
  final String? title;
  final String? description;
  final String? category;
  final List<String> tags;
  final double confidence;
  final Map<String, dynamic> rawData;

  RecognitionResult({
    this.title,
    this.description,
    this.category,
    this.tags = const [],
    this.confidence = 0.0,
    this.rawData = const {},
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      rawData: json,
    );
  }
}

class AIRecognitionService {
  final Dio _dio = Dio();

  /// 通过图片URL进行识别
  Future<RecognitionResult?> recognizeFromUrl(String imageUrl) async {
    try {
      // 暂时使用模拟识别，避免需要真实的API配置
      print('使用模拟AI识别，图片URL: $imageUrl');
      return await mockRecognition();
      
      // 真实API调用代码（需要配置真实的API）
      /*
      final response = await _dio.post(
        ApiConstants.aiRecognitionUrl,
        data: {
          'image_url': imageUrl,
          'api_key': ApiConstants.aiApiKey,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${ApiConstants.aiApiKey}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return _parseRecognitionResult(response.data);
      }
      return null;
      */
    } catch (e) {
      print('AI recognition error: $e');
      return null;
    }
  }

  /// 通过本地图片文件进行识别
  Future<RecognitionResult?> recognizeFromFile(File imageFile) async {
    try {
      // 暂时使用模拟识别，避免需要真实的API配置
      print('使用模拟AI识别，图片文件: ${imageFile.path}');
      return await mockRecognition();
      
      // 真实API调用代码（需要配置真实的API）
      /*
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _dio.post(
        ApiConstants.aiRecognitionUrl,
        data: {
          'image_base64': base64Image,
          'api_key': ApiConstants.aiApiKey,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${ApiConstants.aiApiKey}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return _parseRecognitionResult(response.data);
      }
      return null;
      */
    } catch (e) {
      print('AI recognition error: $e');
      return null;
    }
  }

  /// 解析AI识别结果
  RecognitionResult _parseRecognitionResult(Map<String, dynamic> data) {
    // 这里需要根据你使用的AI服务的返回格式进行调整
    // 以下是通用的解析示例

    String? title;
    String? description;
    String? category;
    List<String> tags = [];
    double confidence = 0.0;

    // 示例：如果使用百度AI
    if (data['result'] != null) {
      final result = data['result'];

      // 尝试从不同字段获取信息
      title = result['name'] ?? result['title'];
      description = result['description'] ?? result['summary'];
      category = result['category'];
      confidence = (result['score'] ?? 0.0).toDouble();

      // 解析标签
      if (result['tags'] != null) {
        tags = List<String>.from(result['tags']);
      }

      // 如果没有直接的标签，尝试从关键词生成
      if (tags.isEmpty && result['keywords'] != null) {
        tags = List<String>.from(result['keywords']);
      }
    }

    // 如果没有获取到标题，使用类别或生成默认标题
    title ??= category ?? '未知物体';

    return RecognitionResult(
      title: title,
      description: description,
      category: category,
      tags: tags,
      confidence: confidence,
      rawData: data,
    );
  }

  /// 模拟AI识别（用于测试）
  Future<RecognitionResult> mockRecognition() async {
    await Future.delayed(const Duration(seconds: 2));

    // 模拟不同类型的识别结果
    final mockResults = [
      RecognitionResult(
        title: '美丽的花朵',
        description: '这是一朵盛开的玫瑰花，颜色鲜艳，花瓣层次分明。',
        category: '植物',
        tags: ['花朵', '玫瑰', '植物', '自然'],
        confidence: 0.95,
        rawData: {'mock': true},
      ),
      RecognitionResult(
        title: '可爱的小猫',
        description: '一只毛茸茸的小猫咪，眼睛明亮，非常可爱。',
        category: '动物',
        tags: ['猫', '宠物', '动物', '可爱'],
        confidence: 0.92,
        rawData: {'mock': true},
      ),
      RecognitionResult(
        title: '美味的蛋糕',
        description: '精致的生日蛋糕，装饰华丽，看起来非常美味。',
        category: '食物',
        tags: ['蛋糕', '甜点', '食物', '美味'],
        confidence: 0.88,
        rawData: {'mock': true},
      ),
      RecognitionResult(
        title: '壮观的风景',
        description: '美丽的山水风景，蓝天白云，令人心旷神怡。',
        category: '风景',
        tags: ['风景', '山水', '自然', '美丽'],
        confidence: 0.90,
        rawData: {'mock': true},
      ),
      RecognitionResult(
        title: '精美的建筑',
        description: '古典建筑风格，雕刻精美，具有历史文化价值。',
        category: '建筑',
        tags: ['建筑', '古典', '历史', '文化'],
        confidence: 0.85,
        rawData: {'mock': true},
      ),
    ];

    // 随机返回一个结果
    final randomIndex = DateTime.now().millisecondsSinceEpoch % mockResults.length;
    return mockResults[randomIndex];
  }

  
}
