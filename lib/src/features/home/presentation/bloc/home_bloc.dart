import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/event_model.dart';
import '../../data/event_repository.dart';

abstract class HomeEvent {}

class HomeStarted extends HomeEvent {}

class HomeRefreshed extends HomeEvent {}

class HomeLoadMore extends HomeEvent {}

class HomeQueryChanged extends HomeEvent {
  final String search;
  final String? categorySlug;
  HomeQueryChanged(this.search, this.categorySlug);
}

abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeLoaded extends HomeState {
  final List<EventModel> events;
  final List<CategoryModel> categories;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final String? loadMoreError;
  HomeLoaded({
    required this.events,
    required this.categories,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
    this.loadMoreError,
  });
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final EventRepository repository;
  String search = '';
  String? categorySlug;
  List<CategoryModel> _categories = [];
  int _generation = 0;
  bool _loadingNext = false;

  HomeBloc(this.repository) : super(HomeLoading()) {
    on<HomeStarted>((event, emit) => _load(emit, includeCategories: true));
    on<HomeRefreshed>((event, emit) => _load(emit, includeCategories: true));
    on<HomeQueryChanged>((event, emit) async {
      search = event.search;
      categorySlug = event.categorySlug;
      await _load(emit);
    });
    on<HomeLoadMore>((event, emit) async {
      final current = state;
      if (_loadingNext ||
          current is! HomeLoaded ||
          !current.hasMore ||
          current.loadingMore) {
        return;
      }
      final generation = _generation;
      _loadingNext = true;
      emit(
        HomeLoaded(
          events: current.events,
          categories: current.categories,
          page: current.page,
          hasMore: current.hasMore,
          loadingMore: true,
        ),
      );
      try {
        final next = await repository.fetchEvents(
          page: current.page + 1,
          search: search,
          categorySlug: categorySlug,
        );
        if (emit.isDone || generation != _generation) return;
        emit(
          HomeLoaded(
            events: [...current.events, ...next.events],
            categories: current.categories,
            page: current.page + 1,
            hasMore: next.hasMore,
          ),
        );
      } catch (error) {
        if (emit.isDone || generation != _generation) return;
        emit(
          HomeLoaded(
            events: current.events,
            categories: current.categories,
            page: current.page,
            hasMore: current.hasMore,
            loadMoreError: describeApiError(error),
          ),
        );
      } finally {
        _loadingNext = false;
      }
    });
  }

  Future<void> _load(
    Emitter<HomeState> emit, {
    bool includeCategories = false,
  }) async {
    final generation = ++_generation;
    emit(HomeLoading());
    try {
      if (includeCategories || _categories.isEmpty) {
        try {
          final categories = await repository.fetchCategories();
          if (emit.isDone || generation != _generation) return;
          _categories = categories;
        } catch (_) {
          // Kategoriya keshi bo'lmasa ham tadbirlar keshini ko'rsatamiz.
        }
      }
      final data = await repository.fetchEvents(
        search: search,
        categorySlug: categorySlug,
      );
      if (emit.isDone || generation != _generation) return;
      emit(
        HomeLoaded(
          events: data.events,
          categories: _categories,
          page: 1,
          hasMore: data.hasMore,
        ),
      );
    } catch (error) {
      if (emit.isDone || generation != _generation) return;
      emit(HomeError(describeApiError(error)));
    }
  }
}
