import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import '../models/recognition_result.dart';

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



  /// 模拟AI识别（用于测试）
  Future<RecognitionResult> mockRecognition() async {
    await Future.delayed(const Duration(seconds: 2));

    // 模拟不同类型的识别结果
    final mockResults = [
      RecognitionResult(
        objects: [
          RecognizedObject(name: '玫瑰花', confidence: 0.95, category: '植物'),
          RecognizedObject(name: '花瓣', confidence: 0.88, category: '植物部位'),
        ],
        scene: {'type': '花园', 'lighting': '自然光', 'setting': '户外'},
        colors: ['红色', '绿色', '粉色'],
        suggestedTags: ['花朵', '玫瑰', '植物', '自然', '美丽'],
        tagGenerationMessage: '成功识别到花卉相关内容',
      ),
      RecognitionResult(
        objects: [
          RecognizedObject(name: '猫', confidence: 0.92, category: '动物'),
          RecognizedObject(name: '毛发', confidence: 0.85, category: '动物特征'),
        ],
        scene: {'type': '室内', 'lighting': '柔和光线', 'setting': '家居'},
        colors: ['橙色', '白色', '棕色'],
        suggestedTags: ['猫', '宠物', '动物', '可爱', '毛茸茸'],
        tagGenerationMessage: '成功识别到宠物相关内容',
      ),
      RecognitionResult(
        objects: [
          RecognizedObject(name: '蛋糕', confidence: 0.88, category: '食物'),
          RecognizedObject(name: '奶油', confidence: 0.82, category: '食物配料'),
        ],
        scene: {'type': '餐桌', 'lighting': '室内光', 'setting': '聚会'},
        colors: ['白色', '粉色', '黄色'],
        suggestedTags: ['蛋糕', '甜点', '食物', '美味', '庆祝'],
        tagGenerationMessage: '成功识别到美食相关内容',
      ),
      RecognitionResult(
        objects: [
          RecognizedObject(name: '山脉', confidence: 0.90, category: '地理'),
          RecognizedObject(name: '云朵', confidence: 0.85, category: '天气'),
        ],
        scene: {'type': '自然风光', 'lighting': '阳光', 'setting': '户外'},
        colors: ['蓝色', '白色', '绿色'],
        suggestedTags: ['风景', '山水', '自然', '美丽', '宁静'],
        tagGenerationMessage: '成功识别到风景相关内容',
      ),
      RecognitionResult(
        objects: [
          RecognizedObject(name: '古建筑', confidence: 0.85, category: '建筑'),
          RecognizedObject(name: '雕刻', confidence: 0.78, category: '装饰'),
        ],
        scene: {'type': '历史遗迹', 'lighting': '自然光', 'setting': '古迹'},
        colors: ['灰色', '棕色', '金色'],
        suggestedTags: ['建筑', '古典', '历史', '文化', '艺术'],
        tagGenerationMessage: '成功识别到建筑相关内容',
      ),
    ];

    // 随机返回一个结果
    final randomIndex = DateTime.now().millisecondsSinceEpoch % mockResults.length;
    return mockResults[randomIndex];
  }

  
}
