import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(Supabase.instance.client);
}

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception("Login failed: User is null");
      }
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserRole> getUserRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return UserRole.unknown;

    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      final roleStr = response['role'] as String?;

      switch (roleStr) {
        case 'syndic': return UserRole.syndic;
        case 'adjoint': return UserRole.adjoint;
        case 'resident': return UserRole.resident;
        case 'concierge': return UserRole.concierge;
        default: return UserRole.unknown;
      }
    } catch (e) {
      return UserRole.unknown;
    }
  }

  User? get currentUser => _client.auth.currentUser;
}
