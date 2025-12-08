import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame/extensions.dart';
import 'package:pawicandoit/game/ui_manager.dart';

/// Displays the current combo multiplier (e.g. `3 x`) and animates when the
/// combo increases. Implements [DataReceiver] so `UIManager.setData('combo', '3 x')`
/// will update it.
class ComboDisplay extends PositionComponent implements DataReceiver {
  final TextPaint _textPaint;
  late TextComponent _textComp;
  int _lastCombo = 1;

  ComboDisplay({Vector2? position, TextPaint? textPaint})
    : _textPaint =
          textPaint ??
          TextPaint(style: const TextStyle(color: Colors.white, fontSize: 16)),
      super(position: position ?? Vector2.zero());

  @override
  Future<void> onLoad() async {
    anchor = Anchor.bottomLeft;
    _textComp = TextComponent(
      text: '1 x',
      textRenderer: _textPaint,
      anchor: Anchor.bottomLeft,
    );
    add(_textComp);
    return super.onLoad();
  }

  @override
  void onData(dynamic data) {
    final text = data?.toString() ?? '';
    _textComp.text = text;

    // parse numeric combo and pulse the display when it increases
    final match = RegExp(r"(\d+)").firstMatch(text);
    if (match != null) {
      final newCombo = int.tryParse(match.group(0) ?? '0') ?? 0;
      if (newCombo > _lastCombo) {
        _lastCombo = newCombo;
        add(
          ScaleEffect.by(
            Vector2.all(0.2),
            EffectController(
              duration: 0.12,
              reverseDuration: 0.12,
              curve: Curves.easeOut,
            ),
          ),
        );
      } else {
        _lastCombo = newCombo;
      }
    }
  }
}
