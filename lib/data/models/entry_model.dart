import 'user_model.dart';

class EntryModel {
  final String id;
  final String userId;
  final String title;
  final String? content;
  final String contentType;
  final String? locationName;
  final String? geoCoordinates;
  final DateTime recordedAt;
  final Map<String, dynamic>? weatherInfo;
  final int? moodScore;
  final String visibility;
  final int viewCount;
  final int likeCount;
  final List<String> tags;
  final int mediaCount;
  final UserModel? author;
  final DateTime createdAt;
  final DateTime updatedAt;

  EntryModel({
    required this.id,
    required this.userId,
    required this.title,
    this.content,
    required this.contentType,
    this.locationName,
    this.geoCoordinates,
    required this.recordedAt,
    this.weatherInfo,
    this.moodScore,
    required this.visibility,
    required this.viewCount,
    required this.likeCount,
    required this.tags,
    required this.mediaCount,
    this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    return EntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      contentType: json['content_type'] as String? ?? 'mixed',
      locationName: json['location_name'] as String?,
      geoCoordinates: json['geo_coordinates'] as String?,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      weatherInfo: json['weather_info'] as Map<String, dynamic>?,
      moodScore: json['mood_score'] as int?,
      visibility: json['visibility'] as String? ?? 'public',
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List? ?? []),
      mediaCount: json['media_count'] as int? ?? 0,
      author: json['author'] != null
          ? UserModel.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'content_type': contentType,
      'location_name': locationName,
      'geo_coordinates': geoCoordinates,
      'recorded_at': recordedAt.toIso8601String(),
      'weather_info': weatherInfo,
      'mood_score': moodScore,
      'visibility': visibility,
      'view_count': viewCount,
      'like_count': likeCount,
      'tags': tags,
      'media_count': mediaCount,
      'author': author?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  EntryModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? contentType,
    String? locationName,
    String? geoCoordinates,
    DateTime? recordedAt,
    Map<String, dynamic>? weatherInfo,
    int? moodScore,
    String? visibility,
    int? viewCount,
    int? likeCount,
    List<String>? tags,
    int? mediaCount,
    UserModel? author,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      locationName: locationName ?? this.locationName,
      geoCoordinates: geoCoordinates ?? this.geoCoordinates,
      recordedAt: recordedAt ?? this.recordedAt,
      weatherInfo: weatherInfo ?? this.weatherInfo,
      moodScore: moodScore ?? this.moodScore,
      visibility: visibility ?? this.visibility,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      tags: tags ?? this.tags,
      mediaCount: mediaCount ?? this.mediaCount,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// 图鉴创建/更新请求模型
class CreateEntryRequest {
  final String title;
  final String? content;
  final String contentType;
  final String? locationName;
  final String? geoCoordinates;
  final DateTime? recordedAt;
  final Map<String, dynamic>? weatherInfo;
  final int? moodScore;
  final String visibility;
  final List<String> tags;

  CreateEntryRequest({
    required this.title,
    this.content,
    this.contentType = 'text',
    this.locationName,
    this.geoCoordinates,
    this.recordedAt,
    this.weatherInfo,
    this.moodScore,
    this.visibility = 'public',
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'content_type': contentType,
      'location_name': locationName,
      'geo_coordinates': geoCoordinates,
      'recorded_at': recordedAt?.toIso8601String(),
      'weather_info': weatherInfo,
      'mood_score': moodScore,
      'visibility': visibility,
      'tags': tags,
    };
  }
}
