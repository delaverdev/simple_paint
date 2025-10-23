import 'dart:async';
import 'dart:typed_data';

import '../../domain/models/draw.dart';
import '../../domain/models/draw_stroke.dart';
import '../../domain/repositories/draws_repository.dart';
import '../sources/supabase_datasource.dart';

class DrawsRepositoryImpl implements DrawsRepository {
  final SupabaseDataSource _dataSource;
  final Map<String, StreamController<Draw>> _streamControllers = {};

  DrawsRepositoryImpl({required SupabaseDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<List<Draw>> getUserDraws(String userId) async {
    try {
      final response = await _dataSource.getDraws(userId);
      final draws = response.map((json) => Draw.fromJson(json)).toList();

      final drawsWithImages = <Draw>[];
      for (final draw in draws) {
        if (draw.backgroundImageUrl != null &&
            draw.backgroundImageUrl!.isNotEmpty) {
          try {
            final imageBytes = await _dataSource.downloadImageBytes(
              draw.backgroundImageUrl!,
            );
            if (imageBytes != null) {
              drawsWithImages.add(
                draw.copyWith(backgroundImageBytes: imageBytes),
              );
            } else {
              drawsWithImages.add(draw);
            }
          } catch (e) {
            drawsWithImages.add(draw);
          }
        } else {
          drawsWithImages.add(draw);
        }
      }

      return drawsWithImages;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Draw> createDraw(Draw draw) async {
    try {
      final drawData = draw.toJson();
      drawData.remove('id');
      final response = await _dataSource.createDraw(drawData);
      final result = Draw.fromJson(response);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<Draw> createDrawWithImage({
    required String userId,
    required List<DrawStroke> strokes,
    Uint8List? backgroundImageBytes,
  }) async {
    try {
      String? imageUrl;

      if (backgroundImageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await _dataSource.uploadImage(
          backgroundImageBytes,
          userId,
          fileName,
        );
      } 

      final draw = Draw(
        id: '',
        userId: userId,
        strokes: strokes,
        backgroundImageUrl: imageUrl,
        backgroundImageBytes: backgroundImageBytes,
      );

      final result = await createDraw(draw);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Draw> updateDrawWithImage({
    required String drawId,
    required String userId,
    required List<DrawStroke> strokes,
    Uint8List? backgroundImageBytes,
    String? currentImageUrl,
    Uint8List? currentImageBytes,
  }) async {
    try {
      final imageChanged = _hasImageChanged(
        backgroundImageBytes,
        currentImageBytes,
      );
      final imageUrl = await _handleImageUpdate(
        imageChanged,
        backgroundImageBytes,
        currentImageUrl,
        userId,
      );

      final draw = Draw(
        id: drawId,
        userId: userId,
        strokes: strokes,
        backgroundImageUrl: imageUrl,
        backgroundImageBytes: backgroundImageBytes ?? currentImageBytes,
      );

      final updatedDraw = await updateDraw(draw);
      return _finalizeDrawWithImage(
        updatedDraw,
        imageChanged,
        imageUrl,
        backgroundImageBytes,
      );
    } catch (e) {
      rethrow;
    }
  }

  bool _hasImageChanged(Uint8List? newBytes, Uint8List? currentBytes) {
    if (newBytes == null && currentBytes == null) return false;
    if (newBytes == null || currentBytes == null) return true;
    if (newBytes.length != currentBytes.length) return true;

    for (int i = 0; i < newBytes.length; i++) {
      if (newBytes[i] != currentBytes[i]) return true;
    }
    return false;
  }

  Future<String?> _handleImageUpdate(
    bool imageChanged,
    Uint8List? backgroundImageBytes,
    String? currentImageUrl,
    String userId,
  ) async {
    if (!imageChanged) return currentImageUrl;

    if (backgroundImageBytes != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newImageUrl = await _dataSource.uploadImage(
        backgroundImageBytes,
        userId,
        fileName,
      );
      await _deleteOldImage(currentImageUrl, userId);
      return newImageUrl;
    } else {
      await _deleteOldImage(currentImageUrl, userId);
      return null;
    }
  }

  Future<void> _deleteOldImage(String? imageUrl, String userId) async {
    if (imageUrl == null || imageUrl.isEmpty) return;

    try {
      final fileName = imageUrl.split('/').last;
      await _dataSource.deleteImage(userId, fileName);
    } catch (e) {
      // Ignore deletion errors
    }
  }

  Future<Draw> _finalizeDrawWithImage(
    Draw updatedDraw,
    bool imageChanged,
    String? imageUrl,
    Uint8List? backgroundImageBytes,
  ) async {
    if (imageChanged && imageUrl != null && imageUrl.isNotEmpty) {
      final imageBytes = await _dataSource.downloadImageBytes(imageUrl);
      return updatedDraw.copyWith(backgroundImageBytes: imageBytes);
    } else if (!imageChanged && backgroundImageBytes != null) {
      return updatedDraw.copyWith(backgroundImageBytes: backgroundImageBytes);
    }
    return updatedDraw;
  }

  @override
  Future<Draw> updateDraw(Draw draw) async {
    try {
      final drawData = draw.toJson();
      final response = await _dataSource.updateDraw(draw.id, drawData);
      return Draw.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteDraw(String drawId) async {
    try {
      await _dataSource.deleteDraw(drawId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<Draw> subscribeToUserDraws(String userId) {
    if (_streamControllers.containsKey(userId)) {
      return _streamControllers[userId]!.stream;
    }

    final controller = StreamController<Draw>.broadcast();
    _streamControllers[userId] = controller;

    final subscription = _dataSource.subscribeToDraws(userId, (data) {
      try {
        final draw = Draw.fromJson(data);
        controller.add(draw);
      } catch (e) {
        controller.addError(Exception('Adding/parsing draw err $e'));
      }
    });

    controller.onCancel = () {
      subscription.unsubscribe();
      _streamControllers.remove(userId);
    };

    return controller.stream;
  }

  @override
  Future<Uint8List?> downloadImageBytes(String imageUrl) async {
    return await _dataSource.downloadImageBytes(imageUrl);
  }

  void dispose() {
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }
}
