import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:pawicandoit/components/ItemSpawnerComponent.dart';
import 'package:pawicandoit/models/player.dart';

class Game extends FlameGame with HasCollisionDetection {
  late Player player;
  late ItemSpawnerComponent itemSpawner = ItemSpawnerComponent();

  @override
  Future<void> onLoad() async {
    await Flame.images.load('player.png');
    await Flame.images.load('Seaweed.jpg');
    await Flame.images.load('trash.png');
    await Flame.images.load('Jellyfish.png');
    await Flame.images.load('Anchovies.png');

    final JoystickComponent joystick = createJoyStickComponent();

    player = Player(
      sprite: Sprite(Flame.images.fromCache('player.png')),
      position: Vector2(size.x / 2, size.y / 2),
      size: Vector2(64, 64),
      joystick: joystick,
    );

    // TODO: Implement adding background here

    add(itemSpawner);
    add(player);
    add(joystick);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  JoystickComponent createJoyStickComponent() {
    final knobPaint = Paint()..color = const Color.fromARGB(200, 0, 0, 255);
    final backgroundPaint = Paint()
      ..color = const Color.fromARGB(100, 0, 0, 255);

    final joystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: knobPaint),
      background: CircleComponent(radius: 60, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    return joystick;
  }
}
