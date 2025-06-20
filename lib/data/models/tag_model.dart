class TagModel {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String category;
  final int level;
  final String? parentId;
  final int usageCount;
  final double qualityScore;
  final List<String> aliases;
  final String status;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? childCount;
  final bool? hasParent;

  TagModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    required this.category,
    required this.level,
    this.parentId,
    required this.usageCount,
    required this.qualityScore,
    required this.aliases,
    required this.status,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.childCount,
    this.hasParent,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'general',
      level: json['level'] as int? ?? 0,
      parentId: json['parent_id'] as String?,
      usageCount: json['usage_count'] as int? ?? 0,
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 0.0,
      aliases: List<String>.from(json['aliases'] as List? ?? []),
      status: json['status'] as String? ?? 'active',
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      childCount: json['child_count'] as int?,
      hasParent: json['has_parent'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'description': description,
      'category': category,
      'level': level,
      'parent_id': parentId,
      'usage_count': usageCount,
      'quality_score': qualityScore,
      'aliases': aliases,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'child_count': childCount,
      'has_parent': hasParent,
    };
  }

  TagModel copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? description,
    String? category,
    int? level,
    String? parentId,
    int? usageCount,
    double? qualityScore,
    List<String>? aliases,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? childCount,
    bool? hasParent,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      category: category ?? this.category,
      level: level ?? this.level,
      parentId: parentId ?? this.parentId,
      usageCount: usageCount ?? this.usageCount,
      qualityScore: qualityScore ?? this.qualityScore,
      aliases: aliases ?? this.aliases,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      childCount: childCount ?? this.childCount,
      hasParent: hasParent ?? this.hasParent,
    );
  }
}

// 标签创建请求模型
class CreateTagRequest {
  final String name;
  final String? description;
  final String category;
  final String? parentId;
  final String? nameEn;
  final List<String> aliases;

  CreateTagRequest({
    required this.name,
    this.description,
    this.category = 'user_defined',
    this.parentId,
    this.nameEn,
    this.aliases = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'parent_id': parentId,
      'name_en': nameEn,
      'aliases': aliases,
    };
  }
}

// 标签搜索结果模型
class TagSearchResult {
  final List<TagModel> tags;
  final int total;
  final int page;
  final int perPage;
  final bool hasNext;
  final bool hasPrev;

  TagSearchResult({
    required this.tags,
    required this.total,
    required this.page,
    required this.perPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory TagSearchResult.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return TagSearchResult(
      tags: (json['tags'] as List<dynamic>)
          .map((tag) => TagModel.fromJson(tag as Map<String, dynamic>))
          .toList(),
      total: pagination['total'] as int? ?? 0,
      page: pagination['page'] as int? ?? 1,
      perPage: pagination['per_page'] as int? ?? 20,
      hasNext: pagination['has_next'] as bool? ?? false,
      hasPrev: pagination['has_prev'] as bool? ?? false,
    );
  }
}
