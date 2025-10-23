import 'dart:typed_data';

import '../models/draw.dart';
import '../models/draw_stroke.dart';

abstract class DrawsRepository {
  Future<List<Draw>> getUserDraws(String userId);

  Future<Draw> createDraw(Draw draw);

  Future<Draw> updateDraw(Draw draw);

  Future<void> deleteDraw(String drawId);

  Stream<Draw> subscribeToUserDraws(String userId);

  Future<Draw> createDrawWithImage({
    required String userId,
    required List<DrawStroke> strokes,
    Uint8List? backgroundImageBytes,
  });

  Future<Draw> updateDrawWithImage({
    required String drawId,
    required String userId,
    required List<DrawStroke> strokes,
    Uint8List? backgroundImageBytes,
    String? currentImageUrl,
    Uint8List? currentImageBytes,
  });
}
