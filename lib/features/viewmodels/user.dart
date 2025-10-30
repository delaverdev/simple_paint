import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_paint/data/repositories/repositories.dart';
import 'package:simple_paint/domain/models/user.dart';
import 'package:simple_paint/features/viewmodels/draws.dart';
import 'package:simple_paint/navigation/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../domain/errors/auth_errors.dart';

class UserModel extends StateNotifier<User?> {
  UserModel(this._ref) : super(null);

  final Ref _ref;

  late final _authRepo = _ref.read(authRepoProvider);
  late final _drawsModel = _ref.read(drawsModelProvider);

  Future<void> checkAuthAndNavigate() async {
    final sbUser = _authRepo.currentUser;

    if (sbUser != null) {
      state = User.fromSupabaseUser(sbUser);
      _drawsModel.load();
      router.replace('/home');
    } else {
      router.replace('/login');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _authRepo.signUp(email: email, password: password);

      if (response.user != null) {
        final user = User.fromSupabaseUser(response.user!);
        state = user;

        _drawsModel.load();
        router.go('/home');
      } else {
        state = null;
      }
    } on AuthException catch (e) {
      throw SupabaseAuthErrorMapper.mapAuthException(e);
    } catch (e) {
      throw SupabaseAuthErrorMapper.mapException(e as Exception);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await _authRepo.signIn(email: email, password: password);

      if (response.user != null) {
        final user = User.fromSupabaseUser(response.user!);
        state = user;

        _drawsModel.load();
        router.go('/home');
      } else {
        state = null;
      }
    } on AuthException catch (e) {
      throw SupabaseAuthErrorMapper.mapAuthException(e);
    } catch (e) {
      throw SupabaseAuthErrorMapper.mapException(e as Exception);
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepo.signOut();

      _drawsModel.unload();
      router.go('/login');
    } on AuthException catch (e) {
      throw SupabaseAuthErrorMapper.mapAuthException(e);
    } catch (e) {
      throw SupabaseAuthErrorMapper.mapException(e as Exception);
    }
  }
}

final userStateProvider = StateNotifierProvider<UserModel, User?>((ref) {
  return UserModel(ref);
});

final userModelProvider = Provider<UserModel>(
  (ref) => ref.watch(userStateProvider.notifier),
);
