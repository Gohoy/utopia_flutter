import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/entry_model.dart';

class EntryRepository {
  final ApiService _apiService = ApiService();

  // 创建图鉴条目
  Future<EntryModel> createEntry(CreateEntryRequest request) async {
    final response = await _apiService.post(
      ApiConstants.entriesPath,
      data: request.toJson(),
    );

    if (response.data['success'] == true) {
      final entryData = response.data['data']['entry'] as Map<String, dynamic>;
      return EntryModel.fromJson(entryData);
    } else {
      throw Exception(response.data['message'] ?? '创建图鉴失败');
    }
  }

  // 获取图鉴列表
  Future<List<EntryModel>> getEntries({
    int page = 1,
    int perPage = 20,
    String? userId,
    String? tagId,
    String? search,
    String? contentType,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    if (userId != null) queryParams['user_id'] = userId;
    if (tagId != null) queryParams['tag_id'] = tagId;
    if (search != null) queryParams['search'] = search;
    if (contentType != null) queryParams['content_type'] = contentType;

    final response = await _apiService.get(
      ApiConstants.entriesPath,
      queryParameters: queryParams,
    );

    if (response.data['success'] == true) {
      final entries = response.data['data']['entries'] as List<dynamic>;
      return entries
          .map((entry) => EntryModel.fromJson(entry as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? '获取图鉴列表失败');
    }
  }

  // 获取我的图鉴
  Future<List<EntryModel>> getMyEntries({
    int page = 1,
    int perPage = 20,
    String? contentType,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    if (contentType != null) queryParams['content_type'] = contentType;

    final response = await _apiService.get(
      ApiConstants.myEntriesPath,
      queryParameters: queryParams,
    );

    if (response.data['success'] == true) {
      final entries = response.data['data']['entries'] as List<dynamic>;
      return entries
          .map((entry) => EntryModel.fromJson(entry as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? '获取我的图鉴失败');
    }
  }

  // 获取单个图鉴详情
  Future<EntryModel> getEntryById(String id) async {
    final response = await _apiService.get('${ApiConstants.entriesPath}/$id');

    if (response.data['success'] == true) {
      final entryData = response.data['data']['entry'] as Map<String, dynamic>;
      return EntryModel.fromJson(entryData);
    } else {
      throw Exception(response.data['message'] ?? '获取图鉴详情失败');
    }
  }

  // 更新图鉴条目
  Future<EntryModel> updateEntry(String id, CreateEntryRequest request) async {
    final response = await _apiService.put(
      '${ApiConstants.entriesPath}/$id',
      data: request.toJson(),
    );

    if (response.data['success'] == true) {
      final entryData = response.data['data']['entry'] as Map<String, dynamic>;
      return EntryModel.fromJson(entryData);
    } else {
      throw Exception(response.data['message'] ?? '更新图鉴失败');
    }
  }

  // 删除图鉴条目
  Future<void> deleteEntry(String id) async {
    final response =
        await _apiService.delete('${ApiConstants.entriesPath}/$id');

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? '删除图鉴失败');
    }
  }

  // 搜索图鉴
  Future<List<EntryModel>> searchEntries({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiService.get(
      ApiConstants.searchEntriesPath,
      queryParameters: {
        'q': query,
        'page': page,
        'per_page': perPage,
      },
    );

    if (response.data['success'] == true) {
      final entries = response.data['data']['entries'] as List<dynamic>;
      return entries
          .map((entry) => EntryModel.fromJson(entry as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? '搜索图鉴失败');
    }
  }

  // 获取热门图鉴
  Future<List<EntryModel>> getHotEntries({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiService.get(
      ApiConstants.hotEntriesPath,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );

    if (response.data['success'] == true) {
      final entries = response.data['data']['entries'] as List<dynamic>;
      return entries
          .map((entry) => EntryModel.fromJson(entry as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? '获取热门图鉴失败');
    }
  }

  // 获取用户统计
  Future<Map<String, dynamic>> getMyStats() async {
    final response = await _apiService.get(ApiConstants.myStatsPath);

    if (response.data['success'] == true) {
      return response.data['data']['stats'] as Map<String, dynamic>;
    } else {
      throw Exception(response.data['message'] ?? '获取统计信息失败');
    }
  }
}
