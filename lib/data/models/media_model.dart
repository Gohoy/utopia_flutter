/// 媒体类型枚举
enum MediaType {
  image,
  video,
  audio,
  file,
}

/// 媒体模型
class MediaModel {
  final String id;
  final String entryId;
  final String fileName;
  final String originalFileName;
  final String url;
  final String? thumbnailUrl;
  final MediaType type;
  final String mimeType;
  final int fileSize;
  final int? width;
  final int? height;
  final int? duration; // 音频/视频时长(秒)
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaModel({
    required this.id,
    required this.entryId,
    required this.fileName,
    required this.originalFileName,
    required this.url,
    this.thumbnailUrl,
    required this.type,
    required this.mimeType,
    required this.fileSize,
    this.width,
    this.height,
    this.duration,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as String,
      entryId: json['entry_id'] as String,
      fileName: json['file_name'] as String,
      originalFileName: json['original_file_name'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.image,
      ),
      mimeType: json['mime_type'] as String,
      fileSize: json['file_size'] as int,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entry_id': entryId,
      'file_name': fileName,
      'original_file_name': originalFileName,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'type': type.name,
      'mime_type': mimeType,
      'file_size': fileSize,
      'width': width,
      'height': height,
      'duration': duration,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MediaModel copyWith({
    String? id,
    String? entryId,
    String? fileName,
    String? originalFileName,
    String? url,
    String? thumbnailUrl,
    MediaType? type,
    String? mimeType,
    int? fileSize,
    int? width,
    int? height,
    int? duration,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaModel(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      fileName: fileName ?? this.fileName,
      originalFileName: originalFileName ?? this.originalFileName,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 媒体上传请求模型
class MediaUploadRequest {
  final String entryId;
  final String fileName;
  final String filePath;
  final MediaType type;
  final Map<String, dynamic>? metadata;

  MediaUploadRequest({
    required this.entryId,
    required this.fileName,
    required this.filePath,
    required this.type,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      'file_name': fileName,
      'file_path': filePath,
      'type': type.name,
      'metadata': metadata,
    };
  }
}

/// 媒体扩展方法
extension MediaModelExtensions on MediaModel {
  /// 是否为图片
  bool get isImage => type == MediaType.image;

  /// 是否为视频
  bool get isVideo => type == MediaType.video;

  /// 是否为音频
  bool get isAudio => type == MediaType.audio;

  /// 格式化文件大小
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  /// 获取显示URL（优先使用缩略图）
  String get displayUrl => thumbnailUrl ?? url;
} 