import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'storage_service.dart';

class RecognitionService {
  static const String _baseUrl = 'http://localhost:15000/api/ai_recognition';
  final StorageService _storageService = StorageService();

  /// 获取认证头部
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// 获取带文件上传的认证头部
  Future<Map<String, String>> _getAuthHeadersForUpload() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// 识别图片 - 基础版本
  Future<RecognitionResult> recognizeImage(File imageFile) async {
    try {
      final headers = await _getAuthHeadersForUpload();
      final uri = Uri.parse('$_baseUrl/recognize');
      
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      
      // 获取文件MIME类型
      final mimeType = lookupMimeType(imageFile.path);
      final mimeTypeParts = mimeType?.split('/') ?? ['image', 'jpeg'];
      
      // 添加图片文件
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
        ),
      );
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(responseBody);
          print('Basic Recognition API Response: $jsonData'); // 调试信息
          return RecognitionResult.fromJson(jsonData);
        } catch (parseError) {
          print('Basic Recognition JSON Parse Error: $parseError');
          print('Response Body: $responseBody');
          throw Exception('JSON解析失败: $parseError');
        }
      } else {
        print('Basic Recognition HTTP Error: ${response.statusCode}');
        print('Response Body: $responseBody');
        throw Exception('识别失败2: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('识别服务调用失败: $e');
    }
  }

  /// 综合识别图片 - 增强版本
  Future<ComprehensiveRecognitionResult> comprehensiveRecognition(File imageFile) async {
    try {
      final headers = await _getAuthHeadersForUpload();
      final uri = Uri.parse('$_baseUrl/comprehensive');
      
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      
      // 获取文件MIME类型
      final mimeType = lookupMimeType(imageFile.path);
      final mimeTypeParts = mimeType?.split('/') ?? ['image', 'jpeg'];
      
      // 添加图片文件
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
        ),
      );
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(responseBody);
          print('API Response: $jsonData'); // 调试信息
          return ComprehensiveRecognitionResult.fromJson(jsonData);
        } catch (parseError) {
          print('JSON Parse Error: $parseError');
          print('Response Body: $responseBody');
          throw Exception('JSON解析失败: $parseError');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response Body: $responseBody');
        throw Exception('综合识别失败: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('综合识别服务调用失败: $e');
    }
  }

  /// 为图鉴条目自动生成标签
  Future<AutoTagResult> autoTagEntry(String entryId) async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('$_baseUrl/auto-tag/$entryId');
      
      final response = await http.post(
        uri,
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AutoTagResult.fromJson(jsonData);
      } else {
        throw Exception('自动标签生成失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('自动标签服务调用失败: $e');
    }
  }

  /// 从文本生成标签
  Future<TagGenerationResult> generateTagsFromText(String text) async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('$_baseUrl/generate-tags');
      
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({'text': text}),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TagGenerationResult.fromJson(jsonData);
      } else {
        throw Exception('标签生成失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('标签生成服务调用失败: $e');
    }
  }

  /// 获取AI模型状态
  Future<ModelStatus> getModelStatus() async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('$_baseUrl/model-status');
      
      final response = await http.get(
        uri,
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ModelStatus.fromJson(jsonData);
      } else {
        throw Exception('获取模型状态失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('模型状态服务调用失败: $e');
    }
  }

  /// 获取识别提供者列表
  Future<List<RecognitionProvider>> getRecognitionProviders() async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('$_baseUrl/providers');
      
      final response = await http.get(
        uri,
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> providersData = jsonData['data'] ?? [];
        return providersData.map((data) => RecognitionProvider.fromJson(data)).toList();
      } else {
        throw Exception('获取识别提供者失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('识别提供者服务调用失败: $e');
    }
  }
}

/// 基础识别结果
class RecognitionResult {
  final bool success;
  final String message;
  final RecognitionData? data;

  RecognitionResult({
    required this.success,
    required this.message,
    this.data,
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? RecognitionData.fromJson(json['data']) : null,
    );
  }
}

/// 识别数据
class RecognitionData {
  final List<DetectedObject> objects;
  final String description;
  final List<String> tags;
  final List<String> colors;

  RecognitionData({
    required this.objects,
    required this.description,
    required this.tags,
    required this.colors,
  });

  factory RecognitionData.fromJson(Map<String, dynamic> json) {
    return RecognitionData(
      objects: (json['objects'] as List<dynamic>?)
          ?.map((obj) => DetectedObject.fromJson(obj))
          .toList() ?? [],
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
    );
  }
}

/// 检测到的物体
class DetectedObject {
  final String name;
  final double confidence;
  final String category;
  final List<double>? bbox;

  DetectedObject({
    required this.name,
    required this.confidence,
    required this.category,
    this.bbox,
  });

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    return DetectedObject(
      name: json['name'] ?? json['class'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'unknown',
      bbox: json['bbox'] != null ? List<double>.from(json['bbox']) : null,
    );
  }
}

/// 综合识别结果
class ComprehensiveRecognitionResult {
  final bool success;
  final String message;
  final ComprehensiveRecognitionData? data;

  ComprehensiveRecognitionResult({
    required this.success,
    required this.message,
    this.data,
  });

  factory ComprehensiveRecognitionResult.fromJson(Map<String, dynamic> json) {
    return ComprehensiveRecognitionResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ComprehensiveRecognitionData.fromJson(json['data']) : null,
    );
  }
}

/// 综合识别数据
class ComprehensiveRecognitionData {
  final RecognitionAnalysis recognition;
  final TagSuggestions tagSuggestions;

  ComprehensiveRecognitionData({
    required this.recognition,
    required this.tagSuggestions,
  });

  factory ComprehensiveRecognitionData.fromJson(Map<String, dynamic> json) {
    try {
      print('ComprehensiveRecognitionData.fromJson input: $json'); // 调试信息
      
      // 处理 recognition_result 字段
      Map<String, dynamic> recognitionData = {};
      if (json['recognition_result'] != null) {
        if (json['recognition_result'] is Map<String, dynamic>) {
          recognitionData = json['recognition_result'];
        } else {
          print('Warning: recognition_result is not a Map: ${json['recognition_result']}');
        }
      }
      
      // 处理 tag_suggestions 字段  
      Map<String, dynamic> tagData = {};
      if (json['tag_suggestions'] != null) {
        if (json['tag_suggestions'] is Map<String, dynamic>) {
          tagData = json['tag_suggestions'];
        } else {
          print('Warning: tag_suggestions is not a Map: ${json['tag_suggestions']}');
        }
      }
      
      return ComprehensiveRecognitionData(
        recognition: RecognitionAnalysis.fromJson(recognitionData),
        tagSuggestions: TagSuggestions.fromJson(tagData),
      );
    } catch (e) {
      print('Error in ComprehensiveRecognitionData.fromJson: $e');
      rethrow;
    }
  }
}

/// 识别分析结果
class RecognitionAnalysis {
  final bool success;
  final String timestamp;
  final AnalysisData? analysis;

  RecognitionAnalysis({
    required this.success,
    required this.timestamp,
    this.analysis,
  });

  factory RecognitionAnalysis.fromJson(Map<String, dynamic> json) {
    try {
      print('RecognitionAnalysis.fromJson input: $json'); // 调试信息
      
      Map<String, dynamic> analysisData = {};
      if (json['analysis'] != null) {
        if (json['analysis'] is Map<String, dynamic>) {
          analysisData = json['analysis'];
        } else {
          print('Warning: analysis is not a Map: ${json['analysis']}');
        }
      }
      
      return RecognitionAnalysis(
        success: json['success'] ?? false,
        timestamp: json['timestamp'] ?? '',
        analysis: json['analysis'] != null ? AnalysisData.fromJson(analysisData) : null,
      );
    } catch (e) {
      print('Error in RecognitionAnalysis.fromJson: $e');
      rethrow;
    }
  }
}

/// 分析数据
class AnalysisData {
  final List<DetectedObject> objects;
  final String description;
  final List<EntityInfo> entities;
  final List<String> suggestedTags;
  final List<String> dominantColors;
  final ImageInfo? imageInfo;

  AnalysisData({
    required this.objects,
    required this.description,
    required this.entities,
    required this.suggestedTags,
    required this.dominantColors,
    this.imageInfo,
  });

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    try {
      print('AnalysisData.fromJson input: $json'); // 调试信息
      
      // 安全地处理 objects 数组
      List<DetectedObject> objects = [];
      if (json['objects'] != null && json['objects'] is List) {
        objects = (json['objects'] as List<dynamic>)
            .map((obj) {
              try {
                return DetectedObject.fromJson(obj as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing object: $obj, error: $e');
                return null;
              }
            })
            .where((obj) => obj != null)
            .cast<DetectedObject>()
            .toList();
      }
      
      // 安全地处理 entities 数组
      List<EntityInfo> entities = [];
      if (json['entities'] != null && json['entities'] is List) {
        entities = (json['entities'] as List<dynamic>)
            .map((entity) {
              try {
                return EntityInfo.fromJson(entity as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing entity: $entity, error: $e');
                return null;
              }
            })
            .where((entity) => entity != null)
            .cast<EntityInfo>()
            .toList();
      }
      
      // 安全地处理字符串数组
      List<String> suggestedTags = [];
      if (json['suggested_tags'] != null && json['suggested_tags'] is List) {
        suggestedTags = (json['suggested_tags'] as List<dynamic>)
            .map((tag) => tag.toString())
            .toList();
      }
      
      List<String> dominantColors = [];
      if (json['dominant_colors'] != null && json['dominant_colors'] is List) {
        dominantColors = (json['dominant_colors'] as List<dynamic>)
            .map((color) => color.toString())
            .toList();
      }
      
      // 安全地处理 imageInfo
      ImageInfo? imageInfo;
      if (json['image_info'] != null && json['image_info'] is Map<String, dynamic>) {
        try {
          imageInfo = ImageInfo.fromJson(json['image_info']);
        } catch (e) {
          print('Error parsing image_info: ${json['image_info']}, error: $e');
        }
      }
      
      return AnalysisData(
        objects: objects,
        description: json['description']?.toString() ?? '',
        entities: entities,
        suggestedTags: suggestedTags,
        dominantColors: dominantColors,
        imageInfo: imageInfo,
      );
    } catch (e) {
      print('Error in AnalysisData.fromJson: $e');
      rethrow;
    }
  }
}

/// 实体信息
class EntityInfo {
  final String entity;
  final String category;
  final double confidence;
  final String description;

  EntityInfo({
    required this.entity,
    required this.category,
    required this.confidence,
    required this.description,
  });

  factory EntityInfo.fromJson(Map<String, dynamic> json) {
    return EntityInfo(
      entity: json['entity'] ?? '',
      category: json['category'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
    );
  }
}

/// 图像信息
class ImageInfo {
  final int width;
  final int height;
  final String mode;
  final String? format;

  ImageInfo({
    required this.width,
    required this.height,
    required this.mode,
    this.format,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      mode: json['mode'] ?? '',
      format: json['format'],
    );
  }
}

/// 标签建议
class TagSuggestions {
  final bool success;
  final String message;
  final List<String> tagIds;

  TagSuggestions({
    required this.success,
    required this.message,
    required this.tagIds,
  });

  factory TagSuggestions.fromJson(Map<String, dynamic> json) {
    try {
      print('TagSuggestions.fromJson input: $json'); // 调试信息
      
      List<String> tagIds = [];
      if (json['tag_ids'] != null && json['tag_ids'] is List) {
        tagIds = (json['tag_ids'] as List<dynamic>)
            .map((id) => id.toString())
            .toList();
      }
      
      return TagSuggestions(
        success: json['success'] ?? false,
        message: json['message']?.toString() ?? '',
        tagIds: tagIds,
      );
    } catch (e) {
      print('Error in TagSuggestions.fromJson: $e');
      rethrow;
    }
  }
}

/// 自动标签结果
class AutoTagResult {
  final bool success;
  final String message;
  final List<String>? tagIds;

  AutoTagResult({
    required this.success,
    required this.message,
    this.tagIds,
  });

  factory AutoTagResult.fromJson(Map<String, dynamic> json) {
    return AutoTagResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      tagIds: json['data'] != null ? List<String>.from(json['data']) : null,
    );
  }
}

/// 标签生成结果
class TagGenerationResult {
  final bool success;
  final String message;
  final List<String>? tags;

  TagGenerationResult({
    required this.success,
    required this.message,
    this.tags,
  });

  factory TagGenerationResult.fromJson(Map<String, dynamic> json) {
    return TagGenerationResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      tags: json['data'] != null ? List<String>.from(json['data']) : null,
    );
  }
}

/// 模型状态
class ModelStatus {
  final bool success;
  final String message;
  final ModelStatusData? data;

  ModelStatus({
    required this.success,
    required this.message,
    this.data,
  });

  factory ModelStatus.fromJson(Map<String, dynamic> json) {
    return ModelStatus(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ModelStatusData.fromJson(json['data']) : null,
    );
  }
}

/// 模型状态数据
class ModelStatusData {
  final bool modelsLoaded;
  final bool yoloLoaded;
  final bool blipLoaded;
  final int knowledgeBaseSize;

  ModelStatusData({
    required this.modelsLoaded,
    required this.yoloLoaded,
    required this.blipLoaded,
    required this.knowledgeBaseSize,
  });

  factory ModelStatusData.fromJson(Map<String, dynamic> json) {
    return ModelStatusData(
      modelsLoaded: json['models_loaded'] ?? false,
      yoloLoaded: json['yolo_loaded'] ?? false,
      blipLoaded: json['blip_loaded'] ?? false,
      knowledgeBaseSize: json['knowledge_base_size'] ?? 0,
    );
  }
}

/// 识别提供者
class RecognitionProvider {
  final String id;
  final String name;
  final bool enabled;
  final double confidenceThreshold;

  RecognitionProvider({
    required this.id,
    required this.name,
    required this.enabled,
    required this.confidenceThreshold,
  });

  factory RecognitionProvider.fromJson(Map<String, dynamic> json) {
    return RecognitionProvider(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      enabled: json['enabled'] ?? false,
      confidenceThreshold: (json['confidence_threshold'] ?? 0.0).toDouble(),
    );
  }
} 