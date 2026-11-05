import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient api;
  AuthRepository({
    required this.api,
    required Dio dio,
    required FlutterSecureStorage storage,
  });

  Future<void> signIn({required String email, required String password}) async {
    final result = await api.dio.post<dynamic>(
      '/api/auth/local',
      data: {'identifier': email.trim(), 'password': password},
      options: Options(extra: {'public': true}),
    );
    await _save(result.data);
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final result = await api.dio.post<dynamic>(
      '/api/auth/local/register',
      data: {
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
      },
      options: Options(extra: {'public': true}),
    );
    await _save(result.data);
  }

  Future<void> _save(dynamic data) async {
    await api.saveTokens(data);
    if (data is Map && data['user'] is Map && data['user']['id'] != null) {
      await api.storage.write(key: 'userId', value: '${data['user']['id']}');
    }
  }

  Future<void> forgotPassword(String email) async {
    await api.dio.post<dynamic>(
      '/api/auth/forgot-password',
      data: {'email': email.trim()},
      options: Options(extra: {'public': true}),
    );
  }

  Future<bool> isLoggedIn() async {
    final access = await api.storage.read(key: 'accessToken');

    final refresh = await api.storage.read(key: 'refreshToken');

    debugPrint('ACCESS EXISTS: ${access?.isNotEmpty == true}');
    debugPrint('REFRESH EXISTS: ${refresh?.isNotEmpty == true}');

    if ((access == null || access.isEmpty) &&
        (refresh == null || refresh.isEmpty)) {
      debugPrint('NO TOKENS FOUND');
      return false;
    }

    try {
      final response = await api.dio.get<dynamic>('/api/users/me');

      debugPrint('SESSION STATUS: ${response.statusCode}');
      return true;
    } on DioException catch (e) {
      debugPrint('SESSION ERROR STATUS: ${e.response?.statusCode}');
      debugPrint('SESSION ERROR TYPE: ${e.type}');

      return false;
    } catch (e) {
      debugPrint('UNEXPECTED SESSION ERROR: ${e.runtimeType}');
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await api.storage.read(key: 'refreshToken');
    try {
      // JWT-only Strapi installations typically have no logout endpoint.
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await api.dio.post<dynamic>(
          '/api/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      }
    } finally {
      await api.clearTokens();
    }
  }
}
