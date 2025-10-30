import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:simple_paint/data/repositories/repositories.dart';
import 'package:simple_paint/domain/models/draw.dart';
import 'package:simple_paint/domain/models/draw_stroke.dart';
import 'package:simple_paint/features/viewmodels/draws_state.dart';
import 'package:simple_paint/features/viewmodels/user.dart';

class DrawsModel extends StateNotifier<DrawsState> {
  DrawsModel(this._ref)
    : super(DrawsState(draws: [], loading: false, errored: false));

  final Ref _ref;
  StreamSubscription<Draw>? _drawsSubscription;

  late final _drawsRepo = _ref.read(drawsRepoProvider);

  bool _isSubscribed = false;

  @override
  void dispose() {
    _drawsSubscription?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    final user = _ref.read(userStateProvider);
    if (user == null) return;

    try {
      state = state.copyWith(loading: true, errored: false);
      final draws = await _drawsRepo.getUserDraws(user.id);
      print('[DRAWS] loaded: ${draws.length}');
      state = state.copyWith(draws: draws, loading: false, errored: false);
      subscribeToDraws();
    } catch (e) {
      print('[DRAWS] load err $e');
      state = state.copyWith(loading: false, errored: true);
    }
  }

  Future<void> unload() async {
    _drawsSubscription?.cancel();
    _isSubscribed = false;
    state = DrawsState(draws: [], loading: false, errored: false);
  }

  Future<Draw?> createDraw({
    required List<DrawStroke> strokes,
    Uint8List? backgroundImage,
  }) async {
    final user = _ref.read(userStateProvider);
    if (user == null) {
      return null;
    }

    try {
      state = state.copyWith(loading: true, errored: false);

      final createdDraw = await _drawsRepo.createDrawWithImage(
        userId: user.id,
        strokes: strokes,
        backgroundImageBytes: backgroundImage,
      );

      state = state.copyWith(loading: false, errored: false);

      return createdDraw;
    } catch (e) {
      state = state.copyWith(loading: false, errored: true);
      return null;
    }
  }

  Future<Draw?> updateDraw({
    required String drawId,
    required List<DrawStroke> strokes,
    Uint8List? backgroundImage,
  }) async {
    final user = _ref.read(userStateProvider);
    if (user == null) return null;

    try {
      final currentDrawIndex = state.draws.indexWhere(
        (draw) => draw.id == drawId,
      );
      if (currentDrawIndex == -1) {
        return null;
      }

      final currentDraw = state.draws[currentDrawIndex];

      final result = await _drawsRepo.updateDrawWithImage(
        drawId: drawId,
        userId: user.id,
        strokes: strokes,
        backgroundImageBytes: backgroundImage,
        currentImageUrl: currentDraw.backgroundImageUrl,
        currentImageBytes: currentDraw.backgroundImageBytes,
      );

      final updatedDraws = state.draws.map((draw) {
        if (draw.id == drawId) {
          return result;
        }
        return draw;
      }).toList();

      state = state.copyWith(
        draws: updatedDraws,
        loading: false,
        errored: false,
      );

      return result;
    } catch (e) {
      state = state.copyWith(loading: false, errored: true);
      return null;
    }
  }

  Future<bool> deleteDraw(String drawId) async {
    try {
      state = state.copyWith(loading: true, errored: false);

      await _drawsRepo.deleteDraw(drawId);

      final updatedDraws = state.draws
          .where((draw) => draw.id != drawId)
          .toList();

      state = state.copyWith(
        draws: updatedDraws,
        loading: false,
        errored: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(loading: false, errored: true);
      return false;
    }
  }

  void subscribeToDraws() {
    final user = _ref.read(userStateProvider);
    if (user == null) {
      return;
    }
    if (_isSubscribed) {
      return;
    }

    try {
      _drawsSubscription?.cancel();

      _drawsSubscription = _drawsRepo
          .subscribeToUserDraws(user.id)
          .listen(
            (updatedDraw) {
              print('[DRAWS STREAM] RECIEVED: ${updatedDraw.id}');
              _handleDrawUpdate(updatedDraw);
            },
            onError: (error) {
              print('[DRAWS STREAM] ERROR: $error');
              state = state.copyWith(errored: true);
            },
            onDone: () {},
          );
      _isSubscribed = true;
    } catch (e) {
      state = state.copyWith(errored: true);
    }
  }

  void _handleDrawUpdate(Draw updatedDraw) {
    if (updatedDraw.backgroundImageUrl != null &&
        updatedDraw.backgroundImageUrl!.isNotEmpty) {
      _loadImageForDraw(updatedDraw);
    } else {
      _updateDrawInList(updatedDraw);
    }
  }

  Future<void> _loadImageForDraw(Draw draw) async {
    try {
      final imageBytes = await _drawsRepo.downloadImageBytes(
        draw.backgroundImageUrl!,
      );
      if (imageBytes != null) {
        final drawWithImage = draw.copyWith(backgroundImageBytes: imageBytes);
        _updateDrawInList(drawWithImage);
      } else {
        _updateDrawInList(draw);
      }
    } catch (e) {
      _updateDrawInList(draw);
    }
  }

  void _updateDrawInList(Draw updatedDraw) {
    final currentDraws = List<Draw>.from(state.draws);

    final existingIndex = currentDraws.indexWhere(
      (draw) => draw.id == updatedDraw.id,
    );

    if (existingIndex != -1) {
      currentDraws[existingIndex] = updatedDraw;
    } else {
      currentDraws.insert(0, updatedDraw);
    }

    currentDraws.sort((a, b) {
      return b.id.compareTo(a.id);
    });

    state = state.copyWith(draws: currentDraws);
  }

  void updateDrawInList(Draw updatedDraw) {
    final updatedDraws = state.draws.map((draw) {
      return draw.id == updatedDraw.id ? updatedDraw : draw;
    }).toList();

    state = state.copyWith(draws: updatedDraws);
  }

  void addDrawToList(Draw newDraw) {
    final existingIndex = state.draws.indexWhere(
      (draw) => draw.id == newDraw.id,
    );
    if (existingIndex == -1) {
      final updatedDraws = [newDraw, ...state.draws];
      state = state.copyWith(draws: updatedDraws);
    }
  }

  void removeDrawFromList(String drawId) {
    final updatedDraws = state.draws
        .where((draw) => draw.id != drawId)
        .toList();
    state = state.copyWith(draws: updatedDraws);
  }
}

final drawsStateProvider = StateNotifierProvider<DrawsModel, DrawsState>((ref) {
  return DrawsModel(ref);
});

final drawsModelProvider = Provider<DrawsModel>(
  (ref) => ref.watch(drawsStateProvider.notifier),
);
