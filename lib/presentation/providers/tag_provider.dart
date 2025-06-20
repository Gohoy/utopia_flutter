import 'package:flutter/foundation.dart';
import '../../data/repositories/tag_repository.dart';
import '../../data/models/tag_model.dart';

class TagProvider with ChangeNotifier {
  final TagRepository _tagRepository = TagRepository();

  List<TagModel> _allTags = [];
  List<TagModel> _popularTags = [];
  List<TagModel> _searchResults = [];
  List<TagModel> _selectedTags = [];
  List<TagModel> _recommendedTags = [];
  List<Map<String, dynamic>> _categories = [];
  
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<TagModel> get allTags => _allTags;
  List<TagModel> get popularTags => _popularTags;
  List<TagModel> get searchResults => _searchResults;
  List<TagModel> get selectedTags => _selectedTags;
  List<TagModel> get recommendedTags => _recommendedTags;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
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

  // 初始化 - 加载基础数据
  Future<void> initialize() async {
    await Future.wait([
      loadPopularTags(),
      loadCategories(),
    ]);
  }

  // 创建标签
  Future<bool> createTag({
    required String name,
    String? description,
    String category = 'user_defined',
    String? parentId,
    String? nameEn,
    List<String> aliases = const [],
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = CreateTagRequest(
        name: name,
        description: description,
        category: category,
        parentId: parentId,
        nameEn: nameEn,
        aliases: aliases,
      );

      final newTag = await _tagRepository.createTag(request);
      
      // 添加到列表
      _allTags.insert(0, newTag);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 搜索标签
  Future<void> searchTags(String query, {String? category}) async {
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
      final result = await _tagRepository.searchTags(
        query: query,
        category: category,
        page: 1,
        perPage: 50,
      );

      _searchResults = result.tags;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // 获取热门标签
  Future<void> loadPopularTags({String? category}) async {
    _setLoading(true);
    _setError(null);

    try {
      final tags = await _tagRepository.getPopularTags(
        category: category,
        limit: 30,
      );

      _popularTags = tags;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // 获取推荐标签
  Future<void> loadRecommendedTags(List<String> baseTags) async {
    if (baseTags.isEmpty) {
      _recommendedTags.clear();
      notifyListeners();
      return;
    }

    try {
      final tags = await _tagRepository.getRecommendedTags(
        baseTags: baseTags,
        limit: 10,
      );

      _recommendedTags = tags;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // 获取标签分类
  Future<void> loadCategories() async {
    try {
      final categories = await _tagRepository.getTagCategories();
      _categories = categories;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // 验证标签
  Future<List<String>> validateTags(List<String> tagIds) async {
    try {
      return await _tagRepository.validateTags(tagIds);
    } catch (e) {
      _setError(e.toString());
      return tagIds; // 返回原始列表作为fallback
    }
  }

  // 选择标签
  void selectTag(TagModel tag) {
    if (!isTagSelected(tag)) {
      _selectedTags.add(tag);
      notifyListeners();
      
      // 加载推荐标签
      _loadRecommendedBasedOnSelected();
    }
  }

  // 取消选择标签
  void unselectTag(TagModel tag) {
    _selectedTags.removeWhere((t) => t.id == tag.id);
    notifyListeners();
    
    // 更新推荐标签
    _loadRecommendedBasedOnSelected();
  }

  // 检查标签是否已选择
  bool isTagSelected(TagModel tag) {
    return _selectedTags.any((t) => t.id == tag.id);
  }

  // 切换标签选择状态
  void toggleTag(TagModel tag) {
    if (isTagSelected(tag)) {
      unselectTag(tag);
    } else {
      selectTag(tag);
    }
  }

  // 通过名称添加标签（用于输入新标签）
  void addTagByName(String tagName) {
    // 检查是否已存在
    final existingTag = _selectedTags.firstWhere(
      (tag) => tag.name.toLowerCase() == tagName.toLowerCase(),
      orElse: () => TagModel(
        id: tagName.toLowerCase().replaceAll(' ', '_'),
        name: tagName,
        category: 'user_defined',
        level: 0,
        usageCount: 0,
        qualityScore: 0.0,
        aliases: [],
        status: 'active',
        createdAt: DateTime.now(),
      ),
    );

    if (!isTagSelected(existingTag)) {
      selectTag(existingTag);
    }
  }

  // 清空选择的标签
  void clearSelectedTags() {
    _selectedTags.clear();
    _recommendedTags.clear();
    notifyListeners();
  }

  // 设置选择的标签
  void setSelectedTags(List<String> tagNames) {
    _selectedTags.clear();
    
    for (final tagName in tagNames) {
      // 尝试从现有标签中查找
      TagModel? foundTag;
      
      // 在热门标签中查找
      for (final tag in _popularTags) {
        if (tag.name == tagName || tag.aliases.contains(tagName)) {
          foundTag = tag;
          break;
        }
      }
      
      // 在搜索结果中查找
      if (foundTag == null) {
        for (final tag in _searchResults) {
          if (tag.name == tagName || tag.aliases.contains(tagName)) {
            foundTag = tag;
            break;
          }
        }
      }
      
      // 如果找不到，创建一个临时标签
      foundTag ??= TagModel(
        id: tagName.toLowerCase().replaceAll(' ', '_'),
        name: tagName,
        category: 'user_defined',
        level: 0,
        usageCount: 0,
        qualityScore: 0.0,
        aliases: [],
        status: 'active',
        createdAt: DateTime.now(),
      );
      
      _selectedTags.add(foundTag);
    }
    
    notifyListeners();
    _loadRecommendedBasedOnSelected();
  }

  // 获取选择的标签名称列表
  List<String> getSelectedTagNames() {
    return _selectedTags.map((tag) => tag.name).toList();
  }

  // 获取选择的标签ID列表
  List<String> getSelectedTagIds() {
    return _selectedTags.map((tag) => tag.id).toList();
  }

  // 基于已选择标签加载推荐
  void _loadRecommendedBasedOnSelected() {
    if (_selectedTags.isNotEmpty) {
      final selectedIds = _selectedTags.map((tag) => tag.id).toList();
      loadRecommendedTags(selectedIds);
    } else {
      _recommendedTags.clear();
      notifyListeners();
    }
  }

  // 清空搜索结果
  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    notifyListeners();
  }

  // 重置所有状态
  void reset() {
    _allTags.clear();
    _popularTags.clear();
    _searchResults.clear();
    _selectedTags.clear();
    _recommendedTags.clear();
    _categories.clear();
    _searchQuery = '';
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
