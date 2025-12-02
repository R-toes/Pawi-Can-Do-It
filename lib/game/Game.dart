import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:pawicandoit/models/player.dart';

class Game extends FlameGame {
  late Player player;

  @override
  Future<void> onLoad() async {
    await Flame.images.load('player.png');

    final JoystickComponent joystick = JoystickComponent(
      // bottom middle
      position: Vector2(0, 0),
      knob: CircleComponent(
        radius: 15,
        paint: Paint()..color = const Color(0xFF00FF00),
      ),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = const Color(0x7700FF00),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    player = Player(
      sprite: Sprite(Flame.images.fromCache('player.png')),
      position: Vector2(size.x / 2, size.y / 2),
      size: Vector2(64, 64),
      joystick: joystick,
    );

    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color.fromARGB(255, 255, 255, 255),
      ),
    );

    add(player);
    add(joystick);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
