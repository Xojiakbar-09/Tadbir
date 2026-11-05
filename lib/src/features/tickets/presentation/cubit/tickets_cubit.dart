import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/ticket_model.dart';
import '../../data/tickets_repository.dart';

class TicketsState {
  final bool loading;
  final List<TicketModel> tickets;
  final String? error;
  const TicketsState({
    this.loading = false,
    this.tickets = const [],
    this.error,
  });
}

class TicketsCubit extends Cubit<TicketsState> {
  final TicketsRepository repository;
  TicketsCubit(this.repository) : super(const TicketsState());

  Future<void> cancel(String documentId) async {
    await repository.cancel(documentId);
    // Remove immediately after successful server deletion.
    emit(
      TicketsState(
        tickets: state.tickets
            .where((item) => item.documentId != documentId)
            .toList(),
      ),
    );
  }

  Future<void> refresh() async {
    emit(TicketsState(loading: true, tickets: state.tickets));
    try {
      final items = await repository.fetchMine();
      emit(TicketsState(tickets: items));
    } catch (_) {
      emit(
        TicketsState(
          tickets: state.tickets,
          error: 'Chiptalarni yuklab bo‘lmadi. Qayta urinib ko‘ring.',
        ),
      );
    }
  }
}
