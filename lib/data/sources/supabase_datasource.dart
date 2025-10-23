import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<List<Map<String, dynamic>>> getDraws(String userId) async {
    final response = await _client.from('draws').select().eq('user_id', userId);
    print('GET DRAWS: ${response.length}');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createDraw(Map<String, dynamic> drawData) async {
    final response = await _client
        .from('draws')
        .insert(drawData)
        .select()
        .single();

    print('CREATE DRAW RESP: $response');
    return response;
  }

  Future<Map<String, dynamic>> updateDraw(
    String drawId,
    Map<String, dynamic> drawData,
  ) async {
    final response = await _client
        .from('draws')
        .update(drawData)
        .eq('id', drawId)
        .select();

    print('UPDATE DRAW RESP: $response');

    if (response.isEmpty) {
      throw Exception('DRAW UPDATE Returns empty draw $drawId');
    }

    return response.first;
  }

  Future<void> deleteDraw(String drawId) async {
    await _client.from('draws').delete().eq('id', drawId);
  }

  Future<String> uploadImage(
    Uint8List imageBytes,
    String userId,
    String fileName,
  ) async {
    //Кидаем в CDN в папку юзера(прописано в rules sb)
    final filePath = '$userId/$fileName';

    try {
      await _client.storage.from('pictures').uploadBinary(filePath, imageBytes);
      final publicUrl = _client.storage.from('pictures').getPublicUrl(filePath);
      print('UPLOADED IMAGE: $publicUrl');

      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteImage(String userId, String fileName) async {
    final filePath = '$userId/$fileName';
    await _client.storage.from('pictures').remove([filePath]);
  }

  Future<Uint8List?> downloadImageBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  RealtimeChannel subscribeToDraws(
    String userId,
    Function(Map<String, dynamic>) onUpdate,
  ) {
    return _client
        .channel('draws_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'draws',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }
}
