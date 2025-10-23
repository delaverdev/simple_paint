import 'dart:ui';

import 'draw_tool.dart';

class DrawStroke {
  DrawStroke({required this.tool, required this.color, required this.width})
    : paint = Paint()
        ..color = color
        ..strokeWidth = width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true
        ..blendMode = (tool == DrawTool.eraser)
            ? BlendMode.clear
            : BlendMode.srcOver;

  final DrawTool tool;
  final Color color;
  final double width;
  final Paint paint;
  final Path path = Path();

  factory DrawStroke.fromJson(Map<String, dynamic> json) {
    final stroke = DrawStroke(
      tool: DrawTool.values.firstWhere(
        (e) => e.name == json['tool'],
        orElse: () => DrawTool.pen,
      ),
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
    );

    final points = (json['points'] as List<dynamic>)
        .map(
          (point) => Offset(
            (point['x'] as num).toDouble(),
            (point['y'] as num).toDouble(),
          ),
        )
        .toList();

    if (points.isNotEmpty) {
      stroke.path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        stroke.path.lineTo(points[i].dx, points[i].dy);
      }
    }

    return stroke;
  }

  Map<String, dynamic> toJson() {
    final points = <Map<String, double>>[];
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final tangent = pathMetric.getTangentForOffset(distance);
        if (tangent != null) {
          points.add({'x': tangent.position.dx, 'y': tangent.position.dy});
        }
        distance += 1.0;
      }
    }

    return {
      'tool': tool.name,
      'color': color.value,
      'width': width,
      'points': points,
    };
  }
}
