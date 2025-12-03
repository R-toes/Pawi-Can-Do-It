import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/painting.dart';

import 'package:pawicandoit/game/Game.dart' show Game;

class Player extends SpriteComponent with HasGameReference<Game> {
  Player({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    required JoystickComponent joystick,
  }) : joystick = joystick,
       super(
         sprite: sprite,
         position: position,
         size: size,
         anchor: Anchor.center,
       );

  final maxSpeed = 300.0; // pixels per second
  final JoystickComponent joystick;
  int score = 0;
  int combo = 0;
  bool _flippedNegative = false;

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    add(
      RectangleComponent(
        size: size,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()..color = const Color.fromARGB(100, 255, 0, 0),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (joystick.direction != JoystickDirection.idle) {
      position.add(joystick.relativeDelta * maxSpeed * dt);

      if (joystick.delta.x < 0 && !_flippedNegative) {
        flipHorizontally();
        _flippedNegative = true;
      } else if (joystick.delta.x > 0 && _flippedNegative) {
        flipHorizontally();
        _flippedNegative = false;
      }

      if (position.x <= size.x / 2) {
        position.x = size.x / 2;
      } else if (position.x > game.size.x - size.x / 2) {
        position.x = game.size.x - size.x / 2;
      }

      position.y = position.y.clamp(
        size.y / 2 + 50,
        game.size.y - (size.y / 2 + 200),
      );
    }
    super.update(dt);
  }

  void addScore(int i) {
    score += i * (1 + combo ~/ 10);
  }
}
