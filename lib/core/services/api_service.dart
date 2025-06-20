import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  final StorageService _storage = StorageService();

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加认证token
        final token = await _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        if (kDebugMode) {
          print('请求: ${options.method} ${options.path}');
          print('参数: ${options.data}');
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('响应: ${response.statusCode} ${response.requestOptions.path}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('错误: ${error.message}');
        }
        handler.next(error);
      },
    ));
  }

  // GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 错误处理
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('网络连接超时，请检查网络设置');
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
      case DioExceptionType.cancel:
        return Exception('请求已取消');
      case DioExceptionType.unknown:
        return Exception('网络连接失败，请检查网络设置');
      default:
        return Exception('未知错误：${error.message}');
    }
  }

  // 响应错误处理
  Exception _handleResponseError(DioException error) {
    final response = error.response;
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      final message = data['message'] as String?;
      
      switch (response.statusCode) {
        case 400:
          return Exception(message ?? '请求参数错误');
        case 401:
          return Exception(message ?? '未授权访问，请重新登录');
        case 403:
          return Exception(message ?? '权限不足');
        case 404:
          return Exception(message ?? '请求的资源不存在');
        case 429:
          return Exception(message ?? '请求过于频繁，请稍后再试');
        case 500:
          return Exception(message ?? '服务器内部错误');
        case 503:
          return Exception(message ?? '服务暂时不可用');
        default:
          return Exception(message ?? '服务器错误(${response.statusCode})');
      }
    }
    return Exception('服务器错误(${response?.statusCode ?? 'Unknown'})');
  }
}
