import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'package:pawicandoit/game/Game.dart' show Game;
import 'package:pawicandoit/models/Item.dart';

class Player extends SpriteComponent
    with HasGameReference<Game>, CollisionCallbacks {
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
  int combo = 1;
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

    add(RectangleHitbox());
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
    // score = score + i * (combo/10 + 1)
    score += i * combo;
  }

  void addCombo(int i) {
    combo += i;
  }

  void resetCombo() {
    combo = 1;
  }

  void eat(Item item) {
    if (item is Food) {
      // 1. Call the main Game's score method
      game.increaseScore();

      // 2. Keep your original combo logic
      addCombo(1);
      debugPrint('Called game.increaseScore(). Player combo is now: $combo');

    } else if (item is Trash) {
      // 1. Call the main Game's hit method
      game.playerHit();

      // 2. Keep your original combo logic
      resetCombo();
      debugPrint('Called game.playerHit(). Player combo reset.');
    }
  }
}
