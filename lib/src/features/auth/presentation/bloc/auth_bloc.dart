import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadbir_go/src/features/auth/data/auth_repository.dart';

sealed class AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email, password;
  SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String username, email, password;
  SignUpRequested(this.username, this.email, this.password);
}

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc(this.repository) : super(AuthInitial()) {
    on<SignInRequested>((e, emit) async {
      emit(AuthLoading());
      try {
        await repository.signIn(email: e.email, password: e.password);
        emit(AuthSuccess());
      } catch (error) {
        emit(AuthFailure(_message(error)));
      }
    });
    on<SignUpRequested>((e, emit) async {
      emit(AuthLoading());
      try {
        await repository.signUp(
          username: e.username,
          email: e.email,
          password: e.password,
        );
        emit(AuthSuccess());
      } catch (error) {
        emit(AuthFailure(_message(error)));
      }
    });
  }
  static String _message(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map &&
          data['error'] is Map &&
          data['error']['message'] is String) {
        return data['error']['message'] as String;
      }
      return e.response == null
          ? 'Internet yoki Strapi serverini tekshiring.'
          : 'So‘rov bajarilmadi. Qayta urinib ko‘ring.';
    }
    return e.toString().replaceFirst('Bad state: ', '');
  }
}
