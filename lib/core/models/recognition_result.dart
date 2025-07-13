class RecognitionResult {
  final List<RecognizedObject> objects;
  final Map<String, dynamic> scene;
  final List<String> colors;
  final List<String> suggestedTags;
  final String tagGenerationMessage;

  RecognitionResult({
    required this.objects,
    required this.scene,
    required this.colors,
    required this.suggestedTags,
    required this.tagGenerationMessage,
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    final objectsJson = json['recognition_result']['objects'] as List? ?? [];
    final sceneJson = json['recognition_result']['scene'] as Map<String, dynamic>? ?? {};
    final colorsJson = json['recognition_result']['colors'] as List? ?? [];
    final suggestedTagsJson = json['suggested_tags'] as List? ?? [];
    
    return RecognitionResult(
      objects: objectsJson.map((obj) => RecognizedObject.fromJson(obj)).toList(),
      scene: sceneJson,
      colors: colorsJson.cast<String>(),
      suggestedTags: suggestedTagsJson.cast<String>(),
      tagGenerationMessage: json['tag_generation_message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objects': objects.map((obj) => obj.toJson()).toList(),
      'scene': scene,
      'colors': colors,
      'suggested_tags': suggestedTags,
      'tag_generation_message': tagGenerationMessage,
    };
  }
}

class RecognizedObject {
  final String name;
  final double confidence;
  final String category;

  RecognizedObject({
    required this.name,
    required this.confidence,
    required this.category,
  });

  factory RecognizedObject.fromJson(Map<String, dynamic> json) {
    return RecognizedObject(
      name: json['name'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
      'category': category,
    };
  }
}

class RecognitionProvider {
  final String name;
  final bool enabled;
  final double confidenceThreshold;

  RecognitionProvider({
    required this.name,
    required this.enabled,
    required this.confidenceThreshold,
  });

  factory RecognitionProvider.fromJson(Map<String, dynamic> json) {
    return RecognitionProvider(
      name: json['name'] ?? '',
      enabled: json['enabled'] ?? false,
      confidenceThreshold: (json['confidence_threshold'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'enabled': enabled,
      'confidence_threshold': confidenceThreshold,
    };
  }
} 