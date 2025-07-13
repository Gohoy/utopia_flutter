class ApiConstants {
  ApiConstants._();

  // 基础配置
  static const String baseUrl = 'http://localhost:15000';
  static const String apiVersion = '/api';
  
  // 超时时间
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 认证相关
  static const String authPath = '$apiVersion/auth';
  static const String loginPath = '$authPath/login';
  static const String registerPath = '$authPath/register';
  static const String profilePath = '$authPath/profile';
  static const String changePasswordPath = '$authPath/change-password';
  static const String verifyTokenPath = '$authPath/verify-token';

  // 图鉴相关
  static const String entriesPath = '$apiVersion/entries';
  static const String myEntriesPath = '$entriesPath/my';
  static const String hotEntriesPath = '$entriesPath/hot';
  static const String searchEntriesPath = '$entriesPath/search';
  static const String myStatsPath = '$myEntriesPath/stats';

  // 标签相关
  static const String tagsPath = '$apiVersion/tags';
  static const String searchTagsPath = '$tagsPath/search';
  static const String popularTagsPath = '$tagsPath/popular';
  static const String recommendTagsPath = '$tagsPath/recommend';
  static const String validateTagsPath = '$tagsPath/validate';
  static const String tagCategoriesPath = '$tagsPath/categories';
  static const String tagTreePath = '$tagsPath/tree';

  // AI识别相关
  static const String aiPath = '$apiVersion/ai';
  static const String aiRecognizePath = '$aiPath/recognize';
  static const String aiAutoTagPath = '$aiPath/auto-tag';
  static const String aiGenerateTagsPath = '$aiPath/generate-tags';
  static const String aiProvidersPath = '$aiPath/providers';

  // 本地存储键
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_info';
  static const String settingsKey = 'app_settings';
    // MinIO 配置
  static const String minioEndpoint = 'localhost';
  static const int minioPort = 9000;
  static const String minioAccessKey = 'utopia_minio_user';
  static const String minioSecretKey = 'utopia_minio_password';
  static const String minioBucketName = 'utopia-images';
  
  // AI 识图 API (使用通用的识图API，如百度、腾讯等)
  static const String aiRecognitionUrl = 'YOUR_AI_RECOGNITION_API_URL';
  static const String aiApiKey = 'YOUR_AI_API_KEY';
}
