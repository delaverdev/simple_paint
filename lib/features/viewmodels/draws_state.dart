import 'package:simple_paint/domain/models/draw.dart';

class DrawsState {
  final List<Draw> draws;
  final bool loading;
  final bool errored;

  DrawsState({
    required this.draws,
    required this.loading,
    required this.errored,
  });

  DrawsState copyWith({List<Draw>? draws, bool? loading, bool? errored}) {
    return DrawsState(
      draws: draws ?? this.draws,
      loading: loading ?? this.loading,
      errored: errored ?? this.errored,
    );
  }
}
