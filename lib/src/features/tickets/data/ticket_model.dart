class TicketModel {
  final String documentId;
  final String ticketCode;
  final String eventDocumentId;
  final String title;
  final String location;
  final String? imageUrl;
  final DateTime? startDate;
  final String status;
  final bool isDemo;

  const TicketModel({
    required this.documentId,
    required this.ticketCode,
    required this.eventDocumentId,
    required this.title,
    required this.location,
    this.imageUrl,
    this.startDate,
    required this.status,
    this.isDemo = false,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json, String baseUrl) {
    final rawImage = json['imageUrl']?.toString();
    final parsed = rawImage == null ? null : Uri.tryParse(rawImage);
    final fullImage = parsed == null || rawImage!.isEmpty
        ? null
        : parsed.hasScheme
        ? parsed.toString()
        : Uri.parse(baseUrl).resolveUri(parsed).toString();
    return TicketModel(
      documentId: json['documentId']?.toString() ?? '',
      ticketCode: json['ticketCode']?.toString() ?? '',
      eventDocumentId: json['eventDocumentId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      imageUrl: fullImage,
      startDate: DateTime.tryParse(
        json['startDate']?.toString() ?? '',
      )?.toLocal(),
      status: json['status']?.toString() ?? 'reserved',
      isDemo: json['isDemo'] == true,
    );
  }

  bool get isPast =>
      status == 'cancelled' ||
      (startDate != null && startDate!.isBefore(DateTime.now()));
}
