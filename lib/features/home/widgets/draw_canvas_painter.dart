import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../domain/models/draw_stroke.dart';

class DrawCanvasPainter extends CustomPainter {
  DrawCanvasPainter({required this.bgImage, required this.strokes});

  final ui.Image? bgImage;
  final List<DrawStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    if (bgImage != null) {
      final img = bgImage!;
      final inputSize = Size(img.width.toDouble(), img.height.toDouble());
      final fitted = applyBoxFit(BoxFit.cover, inputSize, size);
      final renderRect = Alignment.center.inscribe(
        fitted.destination,
        Offset.zero & size,
      );
      final cropRect = Alignment.center.inscribe(
        fitted.source,
        Offset.zero & inputSize,
      );
      canvas.drawImageRect(img, cropRect, renderRect, Paint());
    } else {
      canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    }

    canvas.saveLayer(Offset.zero & size, Paint());

    for (final s in strokes) {
      canvas.drawPath(s.path, s.paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrawCanvasPainter oldDelegate) => true;
}
