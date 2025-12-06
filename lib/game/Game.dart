import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
// REMOVE: import 'package:flutter/painting.dart'; // This is redundant with material.dart
import 'package:get_it/get_it.dart'; // <-- 1. ADD THIS IMPORT
import 'package:pawicandoit/components/ItemSpawnerComponent.dart';
import 'package:pawicandoit/models/player.dart';
import 'package:pawicandoit/services/database_service.dart'; // <-- 2. ADD THIS IMPORT

class Game extends FlameGame with HasCollisionDetection {
  // --- 3. ADD NECESSARY VARIABLES ---
  final String userId;
  final DatabaseService _dbService = GetIt.instance<DatabaseService>();

  late TextComponent scoreText;
  int score = 0;
  int lives = 3;
  // --- END of new variables ---

  late Player player;
  late ItemSpawnerComponent itemSpawner = ItemSpawnerComponent();

  // --- 4. UPDATE THE CONSTRUCTOR ---
  Game({required this.userId}); // Constructor to accept userId

  @override
  Future<void> onLoad() async {
    // This is a more efficient way to load multiple images
    await Flame.images.loadAll(['player.png', 'Seaweed.jpg', 'trash.png']);

    _setupUI(); // <-- 5. CALL The NEW UI SETUP METHOD

    final JoystickComponent joystick = createJoyStickComponent();

    player = Player(
      sprite: Sprite(Flame.images.fromCache('player.png')),
      position: Vector2(size.x / 2, size.y / 2),
      size: Vector2(64, 64),
      joystick: joystick,
    );

    add(itemSpawner);
    add(player);
    add(joystick);
    return super.onLoad();
  }

  // --- 6. ADD NEW METHODS ---

  // This method sets up the score and lives display
  void _setupUI() {
    scoreText = TextComponent(
      text: 'Score: $score | Lives: $lives',
      position: Vector2(10, 10),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 3.0, color: Colors.black)]),
      ),
    );
    add(scoreText);
  }

  // This method will be called by the Player when it collects a good item
  void increaseScore() {
    score += 10;
    scoreText.text = 'Score: $score | Lives: $lives';
  }

  // This method will be called by the Player when it hits trash
  void playerHit() {
    lives--;
    scoreText.text = 'Score: $score | Lives: $lives';
    if (lives <= 0) {
      endGame();
    }
  }

  // This method handles the end of the game
  void endGame() {
    pauseEngine();
    _dbService.saveScore(userId, score);
    print('--- GAME OVER --- Final Score: $score for user $userId has been saved.');
    // Here you could add a game over overlay in the future
  }

  // --- END of new methods ---

  @override
  void update(double dt) {
    super.update(dt);
  }

  JoystickComponent createJoyStickComponent() {
    // Your existing joystick code is perfect and does not need changes
    final knobPaint = Paint()..color = const Color.fromARGB(200, 0, 0, 255);
    final backgroundPaint = Paint()..color = const Color.fromARGB(100, 0, 0, 255);
    final joystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: knobPaint),
      background: CircleComponent(radius: 60, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    return joystick;
  }
}
