import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:pawicandoit/components/ItemSpawnerComponent.dart';
import 'package:pawicandoit/game/ui_manager.dart';
import 'package:pawicandoit/models/player.dart';

class Game extends FlameGame with HasCollisionDetection {
  late Player player;
  late ItemSpawnerComponent itemSpawner = ItemSpawnerComponent();
  late UIManager uiManager;

  @override
  Future<void> onLoad() async {
    await Flame.images.load('player.png');
    await Flame.images.load('Seaweed.jpg');
    await Flame.images.load('trash.png');
    await Flame.images.load('Jellyfish.png');
    await Flame.images.load('Anchovies.png');

    final JoystickComponent joystick = createJoyStickComponent();

    // Position joystick at the bottom center of the screen
    joystick.anchor = Anchor.bottomCenter;
    joystick.position = Vector2(size.x / 2, size.y - 40);

    player = Player(
      sprite: Sprite(Flame.images.fromCache('player.png')),
      position: Vector2(size.x / 2, size.y / 2),
      size: Vector2(64, 64),
      joystick: joystick,
    );

    // Create UI manager and add some example UI components
    uiManager = UIManager(this);
    final textPaint = TextPaint(
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );
    uiManager.addTextComponent(
      'score',
      text: 'Score: 0',
      position: Vector2(10, 30),
      textPaint: textPaint,
    );

    // Add combo UI positioned above the joystick on the left side
    uiManager.addTextComponent(
      'combo',
      text: '0 x',
      // place near left edge; vertical position will be above joystick
      position: Vector2(size.x - 50, joystick.position.y - 150),
      textPaint: textPaint,
    );

    // Ensure the combo text is anchored bottom-left so it sits above joystick
    final comboComp = uiManager.get('combo');
    if (comboComp is TextComponent) {
      comboComp.anchor = Anchor.bottomLeft;
    }

    // Note: avatar sprite removed from UIManager — UI is focused on in-game UI

    // TODO: Implement adding background here

    add(itemSpawner);
    add(player);
    add(joystick);
    // Score UI will be updated automatically when player.addScore is called
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
    );

    return joystick;
  }
}
