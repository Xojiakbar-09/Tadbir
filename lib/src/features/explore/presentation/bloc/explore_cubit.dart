import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/data/event_filters.dart';
import '../../../home/data/event_model.dart';
import '../../../home/data/event_repository.dart';

class ExploreState {
  final EventFilters filters;
  final List<EventModel> events;
  final List<CategoryModel> categories;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final String? error;

  const ExploreState({
    this.filters = const EventFilters(),
    this.events = const [],
    this.categories = const [],
    this.page = 1,
    this.hasMore = false,
    this.loading = false,
    this.loadingMore = false,
    this.error,
  });

  ExploreState copyWith({
    EventFilters? filters,
    List<EventModel>? events,
    List<CategoryModel>? categories,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    String? error,
  }) => ExploreState(
    filters: filters ?? this.filters,
    events: events ?? this.events,
    categories: categories ?? this.categories,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: error,
  );
}

class ExploreCubit extends Cubit<ExploreState> {
  final EventRepository repository;
  int _requestId = 0;
  ExploreCubit(this.repository) : super(const ExploreState());

  Future<void> start() async {
    try {
      final categories = await repository.fetchCategories();
      if (!isClosed) emit(state.copyWith(categories: categories));
    } catch (_) {
      // Tadbirlar kategoriyalarsiz ham ko'rsatiladi.
    }
    await apply(state.filters);
  }

  Future<void> apply(EventFilters filters) async {
    final requestId = ++_requestId;
    emit(
      state.copyWith(
        filters: filters,
        loading: true,
        events: [],
        hasMore: false,
      ),
    );
    try {
      final data = await repository.fetchEvents(filters: filters);
      if (isClosed || requestId != _requestId) return;
      emit(
        state.copyWith(
          events: data.events,
          page: 1,
          hasMore: data.hasMore,
          loading: false,
        ),
      );
    } catch (error) {
      if (isClosed || requestId != _requestId) return;
      emit(state.copyWith(loading: false, error: describeApiError(error)));
    }
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    final requestId = _requestId;
    final current = state;
    emit(state.copyWith(loadingMore: true));
    try {
      final data = await repository.fetchEvents(
        page: current.page + 1,
        filters: current.filters,
      );
      if (isClosed || requestId != _requestId) return;
      emit(
        state.copyWith(
          events: [...current.events, ...data.events],
          page: current.page + 1,
          hasMore: data.hasMore,
          loadingMore: false,
        ),
      );
    } catch (error) {
      if (isClosed || requestId != _requestId) return;
      emit(state.copyWith(loadingMore: false, error: describeApiError(error)));
    }
  }
}
