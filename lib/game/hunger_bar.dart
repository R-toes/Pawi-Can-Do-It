import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'ui_manager.dart';

/// A simple hunger bar component that listens for numeric data (0..100)
/// and renders a maroon fill whose width corresponds to the current value.
class HungerBarComponent extends PositionComponent implements DataReceiver {
  HungerBarComponent({
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.topLeft,
  }) : super(
         position: position ?? Vector2.zero(),
         size: size ?? Vector2(120, 12),
         anchor: anchor,
       );

  // hunger value in 0..100
  double _value = 100.0;

  final Paint _bgPaint = Paint()..color = const Color(0xFF333333);
  final Paint _fillPaint = Paint()..color = const Color(0xFF800000); // maroon
  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0xFFFFFFFF).withOpacity(0.25);

  @override
  void onData(dynamic data) {
    if (data == null) return;
    try {
      final v = (data is num) ? data.toDouble() : double.parse(data.toString());
      _value = v.clamp(0.0, 100.0);
    } catch (_) {
      // ignore malformed data
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // draw background
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, _bgPaint);

    // draw fill according to _value
    final fillWidth = size.x * (_value / 100.0);
    final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.y);
    canvas.drawRect(fillRect, _fillPaint);

    // draw border
    canvas.drawRect(rect, _borderPaint);
  }
}
