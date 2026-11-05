class EventModel {
  final String documentId;
  final String title;
  final String city;
  final String location;
  final String? imageUrl;
  final DateTime? startDate;
  final double price;
  final bool isFree;
  final bool isFeatured;
  final String category;
  final double? latitude;
  final double? longitude;

  const EventModel({
    required this.documentId,
    required this.title,
    required this.city,
    required this.location,
    this.imageUrl,
    this.startDate,
    required this.price,
    required this.isFree,
    required this.isFeatured,
    required this.category,
    this.latitude,
    this.longitude,
  });

  factory EventModel.fromJson(Map<String, dynamic> json, String baseUrl) {
    final category = json['category'];
    final media = json['coverImage'];
    String? rawImage;
    if (media is Map) rawImage = media['url']?.toString();
    Uri? imageUri;
    if (rawImage != null && rawImage.isNotEmpty) {
      imageUri = Uri.tryParse(rawImage);
      if (imageUri != null && !imageUri.hasScheme) {
        imageUri = Uri.parse(baseUrl).resolveUri(imageUri);
      }
    }
    return EventModel(
      latitude: _coordinate(json['latitude']),
      longitude: _coordinate(json['longitude']),
      documentId: json['documentId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Nomsiz tadbir',
      city: json['city']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      imageUrl: imageUri?.toString(),
      startDate: DateTime.tryParse(
        json['startDate']?.toString() ?? '',
      )?.toLocal(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isFree: json['isFree'] == true,
      isFeatured: json['isFeatured'] == true,
      category: category is Map
          ? (category['name']?.toString() ?? 'Boshqa')
          : 'Boshqa',
    );
  }

  factory EventModel.fromCacheJson(Map<String, dynamic> json) => EventModel(
    documentId: json['documentId']?.toString() ?? '',
    title: json['title']?.toString() ?? 'Nomsiz tadbir',
    city: json['city']?.toString() ?? '',
    location: json['location']?.toString() ?? '',
    imageUrl: json['imageUrl']?.toString(),
    startDate: DateTime.tryParse(
      json['startDate']?.toString() ?? '',
    )?.toLocal(),
    price: (json['price'] as num?)?.toDouble() ?? 0,
    isFree: json['isFree'] == true,
    isFeatured: json['isFeatured'] == true,
    category: json['category']?.toString() ?? 'Boshqa',
    latitude: _coordinate(json['latitude']),
    longitude: _coordinate(json['longitude']),
  );

  Map<String, dynamic> toCacheJson() => {
    'documentId': documentId,
    'title': title,
    'city': city,
    'location': location,
    'imageUrl': imageUrl,
    'startDate': startDate?.toIso8601String(),
    'price': price,
    'isFree': isFree,
    'isFeatured': isFeatured,
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
  };

  bool get isPast => startDate != null && !startDate!.isAfter(DateTime.now());

  static double? _coordinate(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');
}

class CategoryModel {
  final String documentId;
  final String name;
  final String slug;
  const CategoryModel({
    required this.documentId,
    required this.name,
    required this.slug,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> data) => CategoryModel(
    documentId: data['documentId']?.toString() ?? '',
    name: data['name']?.toString() ?? '',
    slug: data['slug']?.toString() ?? '',
  );

  factory CategoryModel.fromCacheJson(Map<String, dynamic> data) =>
      CategoryModel(
        documentId: data['documentId']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        slug: data['slug']?.toString() ?? '',
      );

  Map<String, dynamic> toCacheJson() => {
    'documentId': documentId,
    'name': name,
    'slug': slug,
  };
}
