import '../../../core/network/api_client.dart';

class UserProfile {
  final String username;
  final String email;
  const UserProfile({required this.username, required this.email});
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    username: json['username']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
  );
}

class ProfileRepository {
  final ApiClient api;
  const ProfileRepository(this.api);
  Future<UserProfile> fetchProfile() async {
    final result = await api.dio.get<dynamic>('/api/users/me');
    if (result.data is! Map) {
      throw const FormatException('Profil javobi noto‘g‘ri');
    }
    return UserProfile.fromJson(Map<String, dynamic>.from(result.data as Map));
  }
}
