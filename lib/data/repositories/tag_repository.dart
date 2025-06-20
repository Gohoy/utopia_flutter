import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/tag_model.dart';

class TagRepository {
  final ApiService _apiService = ApiService();

  // 创建标签
  Future<TagModel> createTag(CreateTagRequest request) async {
    final response = await _apiService.post(
      ApiConstants.tagsPath,
      data: request.toJson(),
    );

    if (response.data['success'] == true) {
      final tagData = response.data['data']['tag'] as Map<String, dynamic>;
      return TagModel.fromJson(tagData);
    } else {
      throw Exception(response.data['message'] ?? '创建标签失败');
    }
  }

  // 搜索标签
  Future<TagSearchResult> searchTags({
    required String query,
    String? category,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query,
      'page': page,
      'per_page': perPage,
    };

    if (category != null) queryParams['category'] = category;

    final response = await _apiService.get(
      ApiConstants.searchTagsPath,
      queryParameters: queryParams,
    );

    if (response.data['success'] == true) {
      return TagSearchResult.fromJson(response.data['data'] as Map<String, dynamic>);
    } else {
      throw Exception(response.data['message'] ?? '搜索标签失败');
    }
  }

  // 获取热门标签
  Future<List<TagModel>> getPopularTags({
    String? category,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };

    if (category != null) queryParams['category'] = category;

    final response = await _apiService.get(
      ApiConstants.popularTagsPath,
      queryParameters: queryParams,
    );

    if (response.data['success'] == true) {
      final tags = response.data['data']['tags'] as List<dynamic>;
      return tags
          .map((tag) => TagModel.fromJson(tag as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? '获取热门标签失败');
    }
  }

  // 获取推荐标签
  Future<List<TagModel>> getRecommendedTags({
    required List<String> baseTags,
    int limit = 10,
  }) async {
    final response = await _apiService.post(
      ApiConstants.recommendTagsPath,
      data: {'tags': baseTags},
      queryParameters: {'limit': limit},
    );

    if (response.data['success'] == true) {
      final tags = response.data['data']['recommended_tags'] as List<dynamic>;
      return tags
          .map((tag) => TagModel.fromJson(tag as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? '获取推荐标签失败');
    }
  }

  // 验证标签
  Future<List<String>> validateTags(List<String> tagIds) async {
    final response = await _apiService.post(
      ApiConstants.validateTagsPath,
      data: {'tag_ids': tagIds},
    );

    if (response.data['success'] == true) {
      final validTags = response.data['data']['valid_tags'] as List<dynamic>;
      return validTags.map((tag) => tag.toString()).toList();
    } else {
      throw Exception(response.data['message'] ?? '验证标签失败');
    }
  }

  // 获取标签分类
  Future<List<Map<String, dynamic>>> getTagCategories() async {
    final response = await _apiService.get(ApiConstants.tagCategoriesPath);

    if (response.data['success'] == true) {
      final categories = response.data['data']['categories'] as List<dynamic>;
      return categories
          .map((category) => category as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception(response.data['message'] ?? '获取标签分类失败');
    }
  }

  // 获取标签详情
  Future<TagModel> getTagById(String id) async {
    final response = await _apiService.get('${ApiConstants.tagsPath}/$id');

    if (response.data['success'] == true) {
      final tagData = response.data['data']['tag'] as Map<String, dynamic>;
      return TagModel.fromJson(tagData);
    } else {
      throw Exception(response.data['message'] ?? '获取标签详情失败');
    }
  }

  // 获取标签树
  Future<Map<String, dynamic>> getTagTree({String? rootId}) async {
    final queryParams = <String, dynamic>{};
    if (rootId != null) queryParams['root_id'] = rootId;

    final response = await _apiService.get(
      ApiConstants.tagTreePath,
      queryParameters: queryParams,
    );

    if (response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw Exception(response.data['message'] ?? '获取标签树失败');
    }
  }
}
