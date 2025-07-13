import 'package:flutter/foundation.dart';
import '../../data/repositories/entry_repository.dart';
import '../../data/models/entry_model.dart';

class EntryProvider with ChangeNotifier {
  final EntryRepository _entryRepository = EntryRepository();

  List<EntryModel> _entries = [];
  List<EntryModel> _myEntries = [];
  EntryModel? _currentEntry;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // 分页相关
  int _currentPage = 1;
  bool _hasMore = true;
  static const int _pageSize = 20;

  // 搜索相关
  String _searchQuery = '';
  List<EntryModel> _searchResults = [];

  // 加载状态标记 - 避免重复加载
  bool _myEntriesLoaded = false;
  bool _entriesLoaded = false;

  // Getters
  List<EntryModel> get entries => _entries;
  List<EntryModel> get myEntries => _myEntries;
  EntryModel? get currentEntry => _currentEntry;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  List<EntryModel> get searchResults => _searchResults;
  bool get myEntriesLoaded => _myEntriesLoaded;
  bool get entriesLoaded => _entriesLoaded;

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  // 设置错误信息
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 创建图鉴条目
  Future<bool> createEntry({
    required String title,
    String? content,
    String contentType = 'text',
    String? locationName,
    String? geoCoordinates,
    DateTime? recordedAt,
    Map<String, dynamic>? weatherInfo,
    int? moodScore,
    String visibility = 'public',
    List<String> tags = const [],
    List<String> mediaUrls = const [],
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = CreateEntryRequest(
        title: title,
        content: content,
        contentType: contentType,
        locationName: locationName,
        geoCoordinates: geoCoordinates,
        recordedAt: recordedAt,
        weatherInfo: weatherInfo,
        moodScore: moodScore,
        visibility: visibility,
        tags: tags,
        mediaUrls: mediaUrls,
      );

      final newEntry = await _entryRepository.createEntry(request);

      // 添加到列表顶部
      _entries.insert(0, newEntry);
      _myEntries.insert(0, newEntry);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 获取图鉴列表 - 修复版j
  Future<void> loadEntries({
    String? userId,
    String? tagId,
    String? contentType,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    if (!_hasMore || _isLoadingMore || (_entriesLoaded && _entries.isEmpty)) {
      return;
    }
    _setLoadingMore(true);

    _setError(null);

    try {
      final entries = await _entryRepository.getEntries(
        page: _currentPage,
        perPage: _pageSize,
        userId: userId,
        tagId: tagId,
        contentType: contentType,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      _entries.addAll(entries);

      _hasMore = entries.length == _pageSize;
      _currentPage++;
      _entriesLoaded = true;

      _setLoadingMore(false);

      print('✅ 图鉴列表加载完成: ${entries.length} 条，总计: ${_entries.length} 条');
    } catch (e) {
      print('❌ 加载图鉴列表失败: $e');
      _setError(e.toString());
      _entriesLoaded = true;
      _setLoadingMore(false);
    }
  }

  // 获取我的图鉴 - 修复版本
  Future<void> loadMyEntries({
    String? contentType,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    print('🔄 开始加载我的图鉴...');

    _setLoading(true);
    _setError(null);

    try {
      print('开始调用接口');
      final entries = await _entryRepository.getMyEntries(
        page: 1,
        perPage: 100,
        contentType: contentType,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      print('调用接口结束');

      _myEntries = entries;
      _myEntriesLoaded = true;

      print('✅ 我的图鉴加载完成: ${entries.length} 条');
      _setLoading(false);
    } catch (e) {
      print('❌ 加载我的图鉴失败: $e');
      _setError(e.toString());
      _myEntriesLoaded = true; // 即使失败也标记为已加载，避免无限重试
      _setLoading(false);
    }
  }

  // 获取图鉴详情
  Future<void> loadEntryDetail(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final entry = await _entryRepository.getEntryById(id);
      _currentEntry = entry;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // 更新图鉴条目
  Future<bool> updateEntry({
    required String id,
    required String title,
    String? content,
    String contentType = 'text',
    String? locationName,
    String? geoCoordinates,
    DateTime? recordedAt,
    Map<String, dynamic>? weatherInfo,
    int? moodScore,
    String visibility = 'public',
    List<String> tags = const [],
    List<String> mediaUrls = const [],
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = CreateEntryRequest(
        title: title,
        content: content,
        contentType: contentType,
        locationName: locationName,
        geoCoordinates: geoCoordinates,
        recordedAt: recordedAt,
        weatherInfo: weatherInfo,
        moodScore: moodScore,
        visibility: visibility,
        tags: tags,
        mediaUrls: mediaUrls,
      );

      final updatedEntry = await _entryRepository.updateEntry(id, request);

      // 更新列表中的条目
      _updateEntryInLists(updatedEntry);
      _currentEntry = updatedEntry;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 删除图鉴条目
  Future<bool> deleteEntry(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      await _entryRepository.deleteEntry(id);

      // 从列表中移除
      _entries.removeWhere((entry) => entry.id == id);
      _myEntries.removeWhere((entry) => entry.id == id);

      if (_currentEntry?.id == id) {
        _currentEntry = null;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 搜索图鉴
  Future<void> searchEntries(String query) async {
    if (query.trim().isEmpty) {
      _searchQuery = '';
      _searchResults.clear();
      notifyListeners();
      return;
    }

    _setLoading(true);
    _setError(null);
    _searchQuery = query;

    try {
      final results = await _entryRepository.searchEntries(
        query: query,
        page: 1,
        perPage: 50,
      );

      _searchResults = results;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // 获取热门图鉴
  Future<void> loadHotEntries() async {
    _setLoading(true);
    _setError(null);

    try {
      final entries = await _entryRepository.getHotEntries(
        page: 1,
        perPage: 20,
      );

      _entries = entries;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // 辅助方法：更新列表中的条目
  void _updateEntryInLists(EntryModel updatedEntry) {
    final index = _entries.indexWhere((entry) => entry.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
    }

    final myIndex =
        _myEntries.indexWhere((entry) => entry.id == updatedEntry.id);
    if (myIndex != -1) {
      _myEntries[myIndex] = updatedEntry;
    }
  }

  // 清空搜索结果
  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    notifyListeners();
  }

  // 重置我的图鉴加载状态
  void resetMyEntriesState() {
    _myEntriesLoaded = false;
    _myEntries.clear();
    notifyListeners();
  }

  // 重置状态
  void reset() {
    _entries.clear();
    _myEntries.clear();
    _searchResults.clear();
    _currentEntry = null;
    _searchQuery = '';
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    _isLoadingMore = false;
    _error = null;
    _myEntriesLoaded = false;
    _entriesLoaded = false;
    notifyListeners();
  }
}
