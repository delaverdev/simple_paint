import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/auth_repository.dart';
import '../sources/supabase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseDataSource _dataSource;

  AuthRepositoryImpl({required SupabaseDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _dataSource.signUp(email: email, password: password);
    } catch (e) {
     rethrow;
    }
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _dataSource.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  User? get currentUser => _dataSource.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _dataSource.authStateChanges;

  @override
  bool get isSignedIn => currentUser != null;
}
