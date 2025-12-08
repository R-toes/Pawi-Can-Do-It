import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:pawicandoit/components/ItemSpawnerComponent.dart';
import 'package:pawicandoit/game/ui_manager.dart';
import 'package:pawicandoit/game/score_display.dart';
import 'package:pawicandoit/game/combo_display.dart';
import 'package:pawicandoit/game/hunger_bar.dart';
import 'package:pawicandoit/models/player.dart';

enum GameState { playing, paused, gameover }

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

    // Create UI manager and add HUD components
    uiManager = UIManager(this);
    final textPaint = TextPaint(
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );

    // Score display (custom DataReceiver that pulses on increases)
    final scoreDisplay = ScoreDisplay(
      position: Vector2(10, 30),
      textPaint: textPaint,
    );
    uiManager.addComponent('score', scoreDisplay);

    // Combo display (custom DataReceiver) positioned above the joystick
    final comboDisplay = ComboDisplay(
      position: Vector2(size.x - 50, joystick.position.y - 150),
      textPaint: textPaint,
    );
    uiManager.addComponent('combo', comboDisplay);

    // Add hunger bar positioned above the joystick at the right side
    final double hungerBarWidth = 140;
    final double hungerBarHeight = 14;
    final hungerBar = HungerBarComponent(
      position: Vector2(hungerBarWidth, joystick.position.y - 150),
      size: Vector2(hungerBarWidth, hungerBarHeight),
      anchor: Anchor.bottomRight,
    );
    uiManager.addComponent('hunger', hungerBar);
    uiManager.setData('hunger', 100.0);

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

  // Game state management
  GameState _gameState = GameState.playing;

  bool get isPlaying => _gameState == GameState.playing;

  void pauseGame() {
    if (_gameState == GameState.paused) return;
    _gameState = GameState.paused;
    pauseEngine();
  }

  void resumeGame() {
    if (_gameState == GameState.playing) return;
    _gameState = GameState.playing;
    resumeEngine();
  }

  void gameOver() {
    if (_gameState == GameState.gameover) return;
    _gameState = GameState.gameover;
    pauseEngine();
    overlays.add('GameOver');
    overlays.remove('PauseButton');
  }

  /// Basic reset: restore player hunger/position and remove items.
  /// This is intentionally simple; further reset logic can be added.
  void resetGame() {
    // Try to reset player directly if available
    Component? p;
    try {
      p = children.firstWhere((c) => c.runtimeType.toString() == 'Player');
    } catch (_) {
      p = null;
    }
    if (p != null) {
      try {
        final player = p as dynamic;
        player.hunger = 100.0;
        player.position = Vector2(size.x / 2, size.y / 2);
        uiManager.setData('hunger', player.hunger);
      } catch (_) {}
    }
    overlays.remove('GameOver');
    resumeGame();
    if (!overlays.isActive('PauseButton')) overlays.add('PauseButton');
  }
}
