import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:loan_app/core/config/app_config.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/utils/local_storage.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await LocalStorage.getStringValue(
            key: LocalStorage.accessTokenKey,
          );
          if (accessToken.isNotEmpty &&
              options.extra['skipAuthorization'] != true) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;
          final canRefresh =
              error.response?.statusCode == 401 &&
              requestOptions.extra['skipTokenRefresh'] != true &&
              requestOptions.extra['retriedAfterRefresh'] != true;
          if (canRefresh) {
            final accessToken = await _refreshAccessToken();
            if (accessToken != null) {
              requestOptions.extra['retriedAfterRefresh'] = true;
              requestOptions.headers['Authorization'] = 'Bearer $accessToken';
              try {
                final response = await _dio.fetch<dynamic>(requestOptions);
                handler.resolve(response);
                return;
              } on DioException catch (retryError) {
                handler.next(retryError);
                return;
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  Future<String?>? _pendingRefresh;
  bool _signingOut = false;
  int _sessionVersion = 0;

  void beginSignOut() {
    _signingOut = true;
    _sessionVersion++;
  }

  void endSignOut() {
    _signingOut = false;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return _asMap(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return _asMap(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {Object? data}) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(path, data: data);
      return _asMap(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Uint8List> getBytes(String path) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data ?? const []);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete<void>(path);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> patchEmpty(String path, {Object? data}) async {
    try {
      await _dio.patch<void>(path, data: data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> postMultipart(String path, FormData data) async {
    try {
      await _dio.post<void>(
        path,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> postEmpty(
    String path, {
    Object? data,
    bool skipAuthorization = false,
    bool skipTokenRefresh = false,
  }) async {
    try {
      await _dio.post<void>(
        path,
        data: data,
        options: Options(
          extra: {
            if (skipAuthorization) 'skipAuthorization': true,
            if (skipTokenRefresh) 'skipTokenRefresh': true,
          },
        ),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw const ApiException(
      message: 'The server returned an invalid response.',
    );
  }

  Future<String?> _refreshAccessToken() {
    if (_signingOut) {
      return Future<String?>.value(null);
    }
    final existingRefresh = _pendingRefresh;
    if (existingRefresh != null) {
      return existingRefresh;
    }

    final refresh = _requestAccessTokenRefresh();
    _pendingRefresh = refresh;
    return refresh.whenComplete(() => _pendingRefresh = null);
  }

  Future<String?> _requestAccessTokenRefresh() async {
    final sessionVersion = _sessionVersion;
    final refreshToken = await LocalStorage.getStringValue(
      key: LocalStorage.refreshTokenKey,
    );
    if (refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          extra: const {'skipAuthorization': true, 'skipTokenRefresh': true},
        ),
      );
      final session = _asMap(response.data);
      final nextAccessToken = session['accessToken'] as String?;
      final nextRefreshToken = session['refreshToken'] as String?;
      if (nextAccessToken == null || nextRefreshToken == null) {
        return null;
      }
      if (_signingOut || sessionVersion != _sessionVersion) {
        return null;
      }
      await LocalStorage.storeData(
        key: LocalStorage.accessTokenKey,
        value: nextAccessToken,
      );
      await LocalStorage.storeData(
        key: LocalStorage.refreshTokenKey,
        value: nextRefreshToken,
      );
      return nextAccessToken;
    } on DioException {
      await LocalStorage.clearSession();
      return null;
    }
  }
}
