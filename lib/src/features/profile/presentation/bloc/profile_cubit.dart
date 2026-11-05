import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/profile_repository.dart';

class ProfileState {
  final UserProfile? profile;
  final bool loading;
  final String? error;
  const ProfileState({this.profile, this.loading = false, this.error});
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  ProfileCubit(this.repository) : super(const ProfileState());

  Future<void> load() async {
    emit(ProfileState(profile: state.profile, loading: true));
    try {
      final profile = await repository.fetchProfile();
      if (!isClosed) {
        emit(ProfileState(profile: profile));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          ProfileState(
            profile: state.profile,
            error:
                'Profilni yuklab bo‘lmadi. Internet va login holatini tekshiring.',
          ),
        );
      }
    }
  }
}
