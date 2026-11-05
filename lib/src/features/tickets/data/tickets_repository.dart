import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'ticket_model.dart';

class TicketsRepository {
  final ApiClient api;
  const TicketsRepository(this.api);

  Future<List<TicketModel>> fetchMine() async {
    final response = await api.dio.get<dynamic>('/api/tickets/mine');
    final body = Map<String, dynamic>.from(response.data as Map);
    final rows = (body['data'] as List? ?? const []);
    return rows
        .map(
          (row) => TicketModel.fromJson(
            Map<String, dynamic>.from(row as Map),
            api.dio.options.baseUrl,
          ),
        )
        .toList();
  }

  Future<TicketModel> reserve(String eventDocumentId) async {
    try {
      final response = await api.dio.post<dynamic>(
        '/api/tickets/reserve',
        data: {'eventDocumentId': eventDocumentId},
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      return TicketModel.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
        api.dio.options.baseUrl,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // 401: missing/expired JWT. 403: logged-in user may lack the
      // Authenticated role permission for the custom Strapi endpoint.
      if (status == 401) {
        throw const TicketException(
          'Sessiya tugagan yoki token yaroqsiz. Qayta tizimga kiring.',
        );
      }
      if (status == 403) {
        throw const TicketException(
          'Strapi ruxsati rad etildi (403). Authenticated rolida '
          'ticket.reserve huquqini tekshiring.',
        );
      }
      if (status == 400) {
        final data = e.response?.data;
        String? detail;
        if (data is Map && data['error'] is Map) {
          detail = (data['error'] as Map)['message']?.toString();
        }
        throw TicketException(detail ?? 'Bronlash so‘rovi noto‘g‘ri (400).');
      }
      if (status == 422) {
        throw const TicketException(
          'Hozircha faqat bepul tadbirlarga bron qilish mumkin.',
        );
      }
      if (status == 409) {
        throw const TicketException(
          'Bu tadbir uchun chipta allaqachon olingan.',
        );
      }
      if (status == 404) {
        throw const TicketException('Tadbir topilmadi.');
      }
      throw const TicketException(
        'Bronlash amalga oshmadi. Internet va serverni tekshiring.',
      );
    }
  }

  /// This endpoint permanently deletes the ticket and returns HTTP 204.
  Future<void> cancel(String documentId) async {
    if (documentId.trim().isEmpty) {
      throw const TicketException('Chipta identifikatori topilmadi.');
    }
    try {
      await api.dio.post<void>(
        '/api/tickets/${Uri.encodeComponent(documentId)}/cancel',
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final data = e.response?.data;
      String? detail;
      if (data is Map && data['error'] is Map) {
        detail = (data['error'] as Map)['message']?.toString();
      }
      if (code == 401) {
        throw const TicketException('Sessiya tugagan. Qayta kiring (401).');
      }
      if (code == 403) {
        throw const TicketException(
          'Strapi Authenticated roliga ticket.cancel ruxsatini bering (403).',
        );
      }
      if (code == 404) {
        throw const TicketException(
          'Chipta topilmadi yoki sizga tegishli emas (404).',
        );
      }
      throw TicketException(
        detail ?? 'Chiptani o‘chirib bo‘lmadi (${code ?? 'tarmoq'}).',
      );
    }
  }
}

class TicketException implements Exception {
  final String message;
  const TicketException(this.message);
  @override
  String toString() => message;
}
