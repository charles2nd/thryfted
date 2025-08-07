import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => AppLogger.d(object.toString()),
    ));
  }

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Try to get Clerk token from context (if available)
    String? token;
    
    // For now, fallback to legacy JWT token during migration
    token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      options.headers['X-Auth-Provider'] = 'legacy'; // Will be updated for Clerk
    }

    AppLogger.d('Request: ${options.method} ${options.uri}');
    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.d('Response: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    AppLogger.e('API Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
    AppLogger.e('Error message: ${error.message}');
    
    // Handle token refresh for 401 errors
    if (error.response?.statusCode == 401) {
      bool refreshed = false;
      
      // For now, just use legacy token refresh during migration
      refreshed = await _refreshToken();
      
      if (refreshed) {
        // Retry the request with new token
        final clonedRequest = await _dio.request(
          error.requestOptions.path,
          options: Options(
            method: error.requestOptions.method,
            headers: error.requestOptions.headers,
          ),
          data: error.requestOptions.data,
          queryParameters: error.requestOptions.queryParameters,
        );
        return handler.resolve(clonedRequest);
      }
    }

    handler.next(error);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        Endpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}), // Don't include auth header
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        await _secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: data['accessToken'],
        );
        await _secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: data['refreshToken'],
        );
        return true;
      }
    } catch (e) {
      AppLogger.e('Token refresh failed: $e');
      // Clear tokens if refresh fails
      await _secureStorage.delete(key: AppConstants.accessTokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    }
    return false;
  }

  // Generic HTTP methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // File upload
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData();
    
    if (data != null) {
      formData.fields.addAll(data.entries.map((e) => MapEntry(e.key, e.value.toString())));
    }
    
    formData.files.add(MapEntry(
      'file',
      await MultipartFile.fromFile(filePath, filename: fileName),
    ));

    return await _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
    );
  }

  void dispose() {
    _dio.close();
  }
}