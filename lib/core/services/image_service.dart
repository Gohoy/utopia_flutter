import 'dart:io';
import 'dart:typed_data';
import 'package:minio_new/minio.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../constants/api_constants.dart';

class ImageService {
  late final Minio _minioClient;
  final _uuid = const Uuid();

  ImageService() {
    _initMinioClient();
  }

  void _initMinioClient() {
    _minioClient = Minio(
      endPoint: ApiConstants.minioEndpoint,
      port: ApiConstants.minioPort,
      accessKey: ApiConstants.minioAccessKey,
      secretKey: ApiConstants.minioSecretKey,
      useSSL: false, // 开发环境使用HTTP
    );
  }

  /// 创建公开读取策略 - Map格式
  Map<String, dynamic> _createPublicReadPolicy() {
    return {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "*"
          },
          "Action": [
            "s3:GetObject"
          ],
          "Resource": [
            "arn:aws:s3:::${ApiConstants.minioBucketName}/*"
          ]
        }
      ]
    };
  }

  /// 初始化存储桶
  Future<void> initializeBucket() async {
    try {
      final bucketExists = await _minioClient.bucketExists(ApiConstants.minioBucketName);
      if (!bucketExists) {
        await _minioClient.makeBucket(ApiConstants.minioBucketName);
        
        
        // 设置桶策略为公开读取
                // 设置桶策略为公开读取 - Map格式
        final policyMap = _createPublicReadPolicy();
        
        await _minioClient.setBucketPolicy(ApiConstants.minioBucketName, policyMap);
      }
    } catch (e) {
      print('Initialize bucket error: $e');
      throw Exception('Failed to initialize MinIO bucket');
    }
  }

  /// 上传图片文件
  Future<String> uploadImage(File imageFile) async {
    try {
      await initializeBucket();
      
      final fileExtension = path.extension(imageFile.path);
      final fileName = '${_uuid.v4()}$fileExtension';
      final objectName = 'images/$fileName';
      
      final fileBytes = await imageFile.readAsBytes();
      final stream = Stream<Uint8List>.value(fileBytes);
      
      await _minioClient.putObject(
        ApiConstants.minioBucketName,
        objectName,
        stream,
        size: fileBytes.length,
        metadata: {
          'Content-Type': _getContentType(fileExtension),
        },
      );
      
      // 返回公开访问URL
      return 'http://${ApiConstants.minioEndpoint}:${ApiConstants.minioPort}/${ApiConstants.minioBucketName}/$objectName';
    } catch (e) {
      print('Upload image error: $e');
      throw Exception('Failed to upload image');
    }
  }

  /// 上传图片字节数据
  Future<String> uploadImageBytes(Uint8List imageBytes, String fileName) async {
    try {
      await initializeBucket();
      
      final objectName = 'images/$fileName';
      final stream = Stream<Uint8List>.value(imageBytes);
      
      await _minioClient.putObject(
        ApiConstants.minioBucketName,
        objectName,
        stream,
        size: imageBytes.length,
        metadata: {
          'Content-Type': _getContentType(path.extension(fileName)),
        },
      );
      
      return 'http://${ApiConstants.minioEndpoint}:${ApiConstants.minioPort}/${ApiConstants.minioBucketName}/$objectName';
    } catch (e) {
      print('Upload image bytes error: $e');
      throw Exception('Failed to upload image');
    }
  }

  /// 删除图片
  Future<void> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final objectName = uri.path.substring(1).replaceFirst('${ApiConstants.minioBucketName}/', '');
      
      await _minioClient.removeObject(ApiConstants.minioBucketName, objectName);
    } catch (e) {
      print('Delete image error: $e');
      throw Exception('Failed to delete image');
    }
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
