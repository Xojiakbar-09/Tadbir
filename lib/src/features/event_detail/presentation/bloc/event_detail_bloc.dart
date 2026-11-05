import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/event_detail_repository.dart';

sealed class EventDetailEvent {
  const EventDetailEvent();
}

class EventDetailRequested extends EventDetailEvent {
  final String documentId;
  const EventDetailRequested(this.documentId);
}

sealed class EventDetailState {
  const EventDetailState();
}

class EventDetailInitial extends EventDetailState {
  const EventDetailInitial();
}

class EventDetailLoading extends EventDetailState {
  const EventDetailLoading();
}

class EventDetailLoaded extends EventDetailState {
  final EventDetail detail;
  const EventDetailLoaded(this.detail);
}

class EventDetailFailure extends EventDetailState {
  final String message;
  const EventDetailFailure(this.message);
}

class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  final EventDetailRepository repository;
  EventDetailBloc(this.repository) : super(const EventDetailInitial()) {
    on<EventDetailRequested>((event, emit) async {
      emit(const EventDetailLoading());
      try {
        final detail = await repository.fetch(event.documentId);
        emit(EventDetailLoaded(detail));
      } catch (e) {
        emit(
          const EventDetailFailure(
            'Tadbir yuklanmadi. Internet va Strapi ruxsatlarini tekshiring.',
          ),
        );
      }
    });
  }
}
