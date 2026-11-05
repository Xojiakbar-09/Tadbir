import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/offline_status.dart';
import 'event_filters.dart';
import 'event_model.dart';

class EventPage {
  final List<EventModel> events;
  final bool hasMore;
  const EventPage(this.events, this.hasMore);
}

class EventRepository {
  final ApiClient api;
  static const _boxName = 'event_cache';
  static const _categoriesKey = 'categories';
  const EventRepository(this.api);

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  Future<EventPage> fetchEvents({
    int page = 1,
    String search = '',
    String? categorySlug,
    EventFilters? filters,
  }) async {
    final active =
        filters ?? EventFilters(search: search, categorySlug: categorySlug);
    final cacheKey = _eventsKey(page: page, filters: active);
    final query = <String, dynamic>{
      'populate[0]': 'coverImage',
      'populate[1]': 'category',
      'sort': 'startDate:asc',
      'pagination[page]': page,
      'pagination[pageSize]': 10,
    };
    if (active.search.trim().isNotEmpty) {
      query['filters[title][\$containsi]'] = active.search.trim();
    }
    if (active.categorySlug != null && active.categorySlug!.isNotEmpty) {
      query['filters[category][slug][\$eq]'] = active.categorySlug;
    }
    if (active.city != null && active.city!.isNotEmpty) {
      query['filters[city][\$eqi]'] = active.city;
    }
    if (active.isFree != null) {
      query['filters[isFree][\$eq]'] = active.isFree;
    }
    final now = DateTime.now().toUtc();
    final requestedFrom = active.from?.toUtc();
    final earliest = requestedFrom != null && requestedFrom.isAfter(now)
        ? requestedFrom
        : now;
    query['filters[startDate][\$gte]'] = earliest.toIso8601String();
    if (active.to != null) {
      query['filters[startDate][\$lte]'] = active.to!.toUtc().toIso8601String();
    }

    try {
      final response = await api.dio.get<dynamic>(
        '/api/events',
        queryParameters: query,
      );
      OfflineStatus.online();
      final body = Map<String, dynamic>.from(response.data as Map);
      final entries = (body['data'] as List? ?? []);
      final events = entries
          .map(
            (item) => EventModel.fromJson(
              Map<String, dynamic>.from(item as Map),
              api.dio.options.baseUrl,
            ),
          )
          .where((event) => !event.isPast)
          .toList();
      final meta = body['meta'] is Map
          ? body['meta'] as Map
          : <String, dynamic>{};
      final pagination = meta['pagination'] is Map
          ? meta['pagination'] as Map
          : <String, dynamic>{};
      final pageCount = (pagination['pageCount'] as num?)?.toInt() ?? page;
      final hasMore = page < pageCount;
      await _cacheEvents(cacheKey, events, hasMore: hasMore);
      return EventPage(events, hasMore);
    } catch (error) {
      if (OfflineStatus.isConnectionFailure(error)) {
        OfflineStatus.connectionFailed();
        final cached = _readCachedEvents(cacheKey);
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await api.dio.get<dynamic>(
        '/api/categories',
        queryParameters: {'sort': 'name:asc', 'pagination[pageSize]': 100},
      );
      OfflineStatus.online();
      final data = (response.data as Map)['data'] as List? ?? [];
      final categories = data
          .map(
            (e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      await _box.put(
        _categoriesKey,
        jsonEncode(categories.map((e) => e.toCacheJson()).toList()),
      );
      return categories;
    } catch (error) {
      if (OfflineStatus.isConnectionFailure(error)) {
        OfflineStatus.connectionFailed();
        final raw = _box.get(_categoriesKey);
        if (raw is String && raw.isNotEmpty) {
          final decoded = jsonDecode(raw) as List<dynamic>;
          return decoded
              .map(
                (e) => CategoryModel.fromCacheJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        }
      }
      rethrow;
    }
  }

  String _eventsKey({required int page, required EventFilters filters}) =>
      'events::p=$page::q=${filters.search}::c=${filters.categorySlug ?? ''}::city=${filters.city ?? ''}::free=${filters.isFree?.toString() ?? ''}::from=${filters.from?.toIso8601String() ?? ''}::to=${filters.to?.toIso8601String() ?? ''}';

  Future<void> _cacheEvents(
    String key,
    List<EventModel> events, {
    required bool hasMore,
  }) async {
    await _box.put(
      key,
      jsonEncode({
        'hasMore': hasMore,
        'events': events.map((e) => e.toCacheJson()).toList(),
      }),
    );
  }

  EventPage? _readCachedEvents(String key) {
    final raw = _box.get(key);
    if (raw is! String || raw.isEmpty) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final items = (decoded['events'] as List? ?? const [])
        .map(
          (e) => EventModel.fromCacheJson(Map<String, dynamic>.from(e as Map)),
        )
        .where((event) => !event.isPast)
        .toList();
    return EventPage(items, decoded['hasMore'] == true);
  }
}

String describeApiError(Object error) {
  if (error is DioException) {
    final code = error.response?.statusCode;
    if (code == 401) {
      return 'Sessiya tugagan. Qayta kirib ko‘ring.';
    }
    if (code == 403) {
      return 'Strapi: Event yoki Category uchun find ruxsati yo‘q.';
    }
    if (code == 404) {
      return 'Strapi’da Event yoki Category collection yaratilmagan.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Serverga ulanib bo‘lmadi. IP va Strapi serverini tekshiring.';
    }
    return 'Server xatosi${code == null ? '' : ' ($code)'}. Qayta urinib ko‘ring.';
  }
  return 'Ma’lumotlarni yuklab bo‘lmadi.';
}
