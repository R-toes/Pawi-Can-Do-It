import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'package:pawicandoit/game/Game.dart' show Game;
import 'package:pawicandoit/models/Item.dart';
import 'package:pawicandoit/models/Seaweed.dart';

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
  // hunger value ranges from 0..100
  double hunger = 100.0;
  // hunger loss in units per second (2.5 units == 2.5% of 100 per second)
  final double hungerDecayPerSecond = 2.5;
  bool ignoreTrash = false;
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
    if (!game.isPlaying) return;
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
    // Hunger decays over time regardless of movement
    changeHunger(-hungerDecayPerSecond * dt);

    super.update(dt);
  }

  /// Adjust hunger by [delta] (positive or negative) and notify UI.
  void changeHunger(double delta) {
    hunger = (hunger + delta).clamp(0.0, 100.0);
    try {
      game.uiManager.setData('hunger', hunger);
    } catch (_) {
      // uiManager might not be available yet — ignore silently
    }
    if (hunger <= 0) {
      try {
        game.gameOver();
      } catch (_) {}
    }
  }

  void addScore(int i) {
    score += i * combo;
    // Update UI via the game's UIManager if available
    try {
      game.uiManager.setData('score', 'Score: $score');
    } catch (_) {
      // game or uiManager might not be available yet; ignore silently
    }
  }

  void addCombo(int i) {
    combo += i;
    // Update combo UI via the game's UIManager if available
    try {
      game.uiManager.setData('combo', '$combo x');
    } catch (_) {
      // game or uiManager might not be available yet; ignore silently
    }
  }

  void resetCombo() {
    combo = 1;
    // Update combo UI when reset
    try {
      game.uiManager.setData('combo', '$combo x');
    } catch (_) {
      // ignore if uiManager isn't ready
    }
  }

  void eat(Item item) {
    if (item is Food) {
      item.eat(this);
      // restore some hunger when eating food
      changeHunger(20.0);
    } else if (item is Trash) {
      if (ignoreTrash) {
        debugPrint('Ignored trash while invulnerable');
        return;
      }

      resetCombo();
      debugPrint('Ate trash! Score: $score, Combo reset to $combo');
      changeHunger(-40.0);
    }
  }

  void applyInvulnerability(double seconds) {
    ignoreTrash = true;
    debugPrint('Invulnerability started for $seconds seconds');
    // Use a pause-aware timer component instead of Future.delayed so the effect
    // respects pause/resume.
    try {
      game.add(_InvulnerabilityTimer(this, seconds));
    } catch (_) {
      // Fallback to Future.delayed if adding component fails for some reason
      Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()), () {
        ignoreTrash = false;
        debugPrint('Invulnerability ended');
      });
    }
  }
}

class _InvulnerabilityTimer extends Component with HasGameReference<Game> {
  final Player player;
  double remaining;

  _InvulnerabilityTimer(this.player, double seconds) : remaining = seconds;

  @override
  void update(double dt) {
    if (!game.isPlaying) return;
    remaining -= dt;
    if (remaining <= 0) {
      player.ignoreTrash = false;
      debugPrint('Invulnerability ended');
      removeFromParent();
    }
  }
}
