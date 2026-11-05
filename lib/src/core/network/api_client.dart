import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final Dio _refreshDio;
  final FlutterSecureStorage storage;

  Future<String?>? _refreshing;

  ApiClient({required String baseUrl, required this.storage, required this.dio})
    : _refreshDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    dio.options.baseUrl = baseUrl;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            if (options.extra['public'] != true) {
              final token = await storage.read(key: 'accessToken');

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } else {
              options.headers.remove('Authorization');
            }

            handler.next(options);
          } catch (e) {
            handler.reject(DioException(requestOptions: options, error: e));
          }
        },

        onError: (error, handler) async {
          final request = error.requestOptions;

          if (error.response?.statusCode != 401 ||
              request.extra['public'] == true ||
              request.extra['retried'] == true) {
            return handler.next(error);
          }

          try {
            final token = await refresh();

            if (token == null) {
              return handler.next(error);
            }

            final response = await dio.fetch<dynamic>(
              request.copyWith(
                headers: {...request.headers, 'Authorization': 'Bearer $token'},
                extra: {...request.extra, 'retried': true},
              ),
            );

            return handler.resolve(response);
          } on DioException catch (e) {
            return handler.next(e);
          } catch (_) {
            return handler.next(error);
          }
        },
      ),
    );
  }

  // LOGIN VA REGISTER TOKENLARINI SAQLASH

  Future<void> saveTokens(dynamic data) async {
    // Strapi JWT mode may return only a JWT, without refreshToken.
    if (data is! Map ||
        data['jwt'] is! String ||
        (data['jwt'] as String).trim().isEmpty) {
      throw StateError('Strapi javobida JWT token topilmadi.');
    }

    await storage.write(key: 'accessToken', value: data['jwt'] as String);

    final refreshToken = data['refreshToken'];
    if (refreshToken is String && refreshToken.isNotEmpty) {
      await storage.write(key: 'refreshToken', value: refreshToken);
    } else {
      // Prevent a previous account's refresh token being reused.
      await storage.delete(key: 'refreshToken');
    }
  }

  // BIR VAQTDA BITTA REFRESH

  Future<String?> refresh() {
    if (_refreshing != null) {
      return _refreshing!;
    }

    final future = _performRefresh();
    _refreshing = future;

    return future.whenComplete(() {
      _refreshing = null;
    });
  }

  // REFRESH TOKEN ORQALI YANGILASH

  Future<String?> _performRefresh() async {
    final oldRefreshToken = await storage.read(key: 'refreshToken');

    if (oldRefreshToken == null || oldRefreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post<dynamic>(
        '/api/auth/refresh',
        data: {'refreshToken': oldRefreshToken},
      );

      await saveTokens(response.data);

      return await storage.read(key: 'accessToken');
    } on DioException catch (e) {
      if ([400, 401, 403].contains(e.response?.statusCode)) {
        await clearTokens();
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // TOKENLARNI O'CHIRISH

  Future<void> clearTokens() async {
    await storage.delete(key: 'accessToken');

    await storage.delete(key: 'refreshToken');

    await storage.delete(key: 'userId');
  }
}
