import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame/extensions.dart';
import 'package:pawicandoit/game/ui_manager.dart';

/// A small HUD component that displays the score and pulses when the score
/// increases. Implements [DataReceiver] so it can be updated via
/// `UIManager.setData('score', '...')`.
class ScoreDisplay extends PositionComponent implements DataReceiver {
  final TextPaint _textPaint;
  late TextComponent _textComp;
  int _lastScore = 0;

  ScoreDisplay({Vector2? position, TextPaint? textPaint})
    : _textPaint =
          textPaint ??
          TextPaint(style: const TextStyle(color: Colors.white, fontSize: 18)),
      super(position: position ?? Vector2(10, 10));

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    _textComp = TextComponent(
      text: '0',
      textRenderer: _textPaint,
      anchor: Anchor.topLeft,
    );
    add(_textComp);
    return super.onLoad();
  }

  @override
  void onData(dynamic data) {
    // Accept either an int, or a string like 'Score: 10'
    final text = data?.toString() ?? '';
    _textComp.text = text;

    // Try to parse a numeric score and pulse when it increases
    final match = RegExp(r"(\d+)").firstMatch(text);
    if (match != null) {
      final newScore = int.tryParse(match.group(0) ?? '0') ?? 0;
      if (newScore > _lastScore) {
        _lastScore = newScore;
        // pulse effect: scale up then back down
        add(
          ScaleEffect.by(
            Vector2.all(0.15),
            EffectController(
              duration: 0.12,
              reverseDuration: 0.12,
              curve: Curves.easeOut,
            ),
          ),
        );
      } else {
        _lastScore = newScore;
      }
    }
  }
}
