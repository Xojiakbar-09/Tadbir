import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Tracks network availability and last API connection failure separately.
/// Connectivity != internet access: a Wi-Fi router may have no Internet, and
/// Strapi may be unreachable even with a working Internet connection.
class OfflineStatus {
  OfflineStatus._();

  static final ValueNotifier<bool> offline = ValueNotifier<bool>(false);
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static bool _noNetwork = false;
  static bool _apiConnectionFailed = false;

  static bool get hasNetwork => !_noNetwork;

  static Future<void> initialize() async {
    _subscription ??= _connectivity.onConnectivityChanged.listen(_update);
    try {
      _update(await _connectivity.checkConnectivity());
    } catch (_) {
      // Do not misreport the user as offline if platform check fails.
    }
  }

  static void _update(List<ConnectivityResult> results) {
    final noNetwork = results.isEmpty ||
        (results.length == 1 && results.contains(ConnectivityResult.none));
    if (_noNetwork && !noNetwork) {
      // A new connection warrants another API attempt. The API's result will
      // subsequently determine whether the server is really accessible.
      _apiConnectionFailed = false;
    }
    _noNetwork = noNetwork;
    _notify();
  }

  static bool isConnectionFailure(Object error) {
    if (error is! DioException) return false;
    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => true,
      _ => false,
    };
  }

  static void online() {
    _apiConnectionFailed = false;
    _notify();
  }

  static void connectionFailed() {
    _apiConnectionFailed = true;
    _notify();
  }

  static void _notify() => offline.value = _noNetwork || _apiConnectionFailed;

  static Future<void> refresh() async {
    try {
      _update(await _connectivity.checkConnectivity());
    } catch (_) {}
  }

  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
