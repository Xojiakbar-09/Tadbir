class EventFilters {
  final String search;
  final String? categorySlug;
  final String? city;
  final DateTime? from;
  final DateTime? to;
  final bool? isFree;

  const EventFilters({
    this.search = '',
    this.categorySlug,
    this.city,
    this.from,
    this.to,
    this.isFree,
  });

  EventFilters copyWith({
    String? search,
    String? categorySlug,
    String? city,
    DateTime? from,
    DateTime? to,
    bool? isFree,
    bool clearCategory = false,
    bool clearCity = false,
    bool clearDates = false,
    bool clearPrice = false,
  }) => EventFilters(
    search: search ?? this.search,
    categorySlug: clearCategory ? null : categorySlug ?? this.categorySlug,
    city: clearCity ? null : city ?? this.city,
    from: clearDates ? null : from ?? this.from,
    to: clearDates ? null : to ?? this.to,
    isFree: clearPrice ? null : isFree ?? this.isFree,
  );

  bool get isFiltered =>
      search.trim().isNotEmpty ||
      categorySlug != null ||
      city != null ||
      from != null ||
      to != null ||
      isFree != null;
}
