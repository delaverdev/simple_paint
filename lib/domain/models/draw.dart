import 'dart:typed_data';

import 'draw_stroke.dart';

class Draw {
  final String id;
  final String userId;
  final List<DrawStroke> strokes;
  final String? backgroundImageUrl;
  final Uint8List? backgroundImageBytes;

  Draw({
    required this.id,
    required this.userId,
    required this.strokes,
    this.backgroundImageUrl,
    this.backgroundImageBytes,
  });

  factory Draw.fromJson(Map<String, dynamic> json) {
    return Draw(
      id: json['id'].toString(),
      userId: json['user_id'] as String,
      strokes: (json['strokes'] as List<dynamic>)
          .map((strokeJson) => DrawStroke.fromJson(strokeJson))
          .toList(),
      backgroundImageUrl: json['background_image_url'] as String?,
      backgroundImageBytes: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'strokes': strokes.map((stroke) => stroke.toJson()).toList(),
      'background_image_url': backgroundImageUrl ?? '',
    };
  }

  Draw copyWith({
    String? id,
    String? userId,
    List<DrawStroke>? strokes,
    String? backgroundImageUrl,
    Uint8List? backgroundImageBytes,
  }) {
    return Draw(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      strokes: strokes ?? this.strokes,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      backgroundImageBytes: backgroundImageBytes ?? this.backgroundImageBytes,
    );
  }
}
