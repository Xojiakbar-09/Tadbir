import 'dart:convert';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/offline_status.dart';
import '../../home/data/event_model.dart';

class EventDetail {
  final EventModel event;
  final String description;
  final DateTime? endDate;
  const EventDetail({
    required this.event,
    required this.description,
    this.endDate,
  });
}

class EventDetailRepository {
  final ApiClient api;
  const EventDetailRepository(this.api);

  Future<EventDetail> fetch(String documentId) async {
    final key = 'detail::$documentId';
    try {
      final response = await api.dio.get<dynamic>(
        '/api/events/${Uri.encodeComponent(documentId)}',
        queryParameters: {
          'populate[0]': 'coverImage',
          'populate[1]': 'category',
        },
      );
      OfflineStatus.online();
      final root = Map<String, dynamic>.from(response.data as Map);
      final json = Map<String, dynamic>.from(root['data'] as Map);
      final detail = EventDetail(
        event: EventModel.fromJson(json, api.dio.options.baseUrl),
        description: _description(json['description']),
        endDate: DateTime.tryParse(
          json['endDate']?.toString() ?? '',
        )?.toLocal(),
      );
      await Hive.box<dynamic>('event_cache').put(
        key,
        jsonEncode({
          'event': detail.event.toCacheJson(),
          'description': detail.description,
          'endDate': detail.endDate?.toIso8601String(),
        }),
      );
      return detail;
    } catch (error) {
      if (OfflineStatus.isConnectionFailure(error)) {
        OfflineStatus.connectionFailed();
        final cached = Hive.box<dynamic>('event_cache').get(key);
        if (cached is String) {
          final data = Map<String, dynamic>.from(jsonDecode(cached) as Map);
          return EventDetail(
            event: EventModel.fromCacheJson(
              Map<String, dynamic>.from(data['event'] as Map),
            ),
            description: data['description']?.toString() ?? '',
            endDate: DateTime.tryParse(
              data['endDate']?.toString() ?? '',
            )?.toLocal(),
          );
        }
      }
      rethrow;
    }
  }

  String _description(dynamic value) {
    if (value is String) return value;
    if (value is List) {
      final chunks = <String>[];
      void walk(dynamic node) {
        if (node is Map) {
          if (node['text'] is String) chunks.add(node['text'] as String);
          if (node['children'] is List) {
            for (final child in node['children'] as List) {
              walk(child);
            }
            chunks.add('\n');
          }
        } else if (node is List) {
          for (final child in node) {
            walk(child);
          }
        }
      }

      walk(value);
      return chunks.join(' ').replaceAll(RegExp(r'\s*\n\s*'), '\n').trim();
    }
    return '';
  }
}
