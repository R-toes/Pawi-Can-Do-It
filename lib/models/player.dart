import 'dart:async';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';

import 'package:pawicandoit/game/Game.dart' show Game;
import 'package:pawicandoit/models/Item.dart';
// Seaweed import removed (not used here)

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

  late double maxSpeed = 300.0; // pixels per second
  final JoystickComponent joystick;
  int score = 0;
  int combo = 1;
  // hunger value ranges from 0..100
  double hunger = 100.0;
  // hunger loss in units per second (2.5 units == 2.5% of 100 per second)
  final double hungerDecayPerSecond = 2.5;
  bool ignoreTrash = false;
  bool _flippedNegative = false;
  bool _controlsInverted = false;
  double? _originalMaxSpeed;
  bool _speedModified = false;
  double? _originalMaxSpeedForModifier;
  // Tilt/angle behavior
  final double _maxTilt = math.pi / 4; // 45 degrees
  final double _tiltSmoothing = 8.0;

  @override
  FutureOr<void> onLoad() {
    add(CircleHitbox());
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
    // Tilt the sprite based on vertical input (smoothly lerped).
    // Take horizontal flip into account so the visual "nose" always
    // tilts in the expected direction when the sprite is mirrored.
    try {
      final inputY = (joystick.direction == JoystickDirection.idle)
          ? 0.0
          : joystick.relativeDelta.y.clamp(-1.0, 1.0);

      // Determine horizontal flip sign. Prefer the actual horizontal scale
      // sign (works even if flipping is done by changing `scale.x`). If
      // scale.x is 0 for some reason, fall back to the existing boolean.
      final flipSign = (scale.x != 0)
          ? (scale.x < 0 ? -1.0 : 1.0)
          : (_flippedNegative ? -1.0 : 1.0);

      // Invert so that upward input tilts the nose up visually, taking
      // horizontal mirroring into account.
      final desired = inputY * _maxTilt * flipSign;
      angle += (desired - angle) * (_tiltSmoothing * dt);
    } catch (_) {}
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
      game.uiManager.setData('score', '$score');
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

      // Delegate trash-specific effects and penalties to the item itself.
      try {
        item.eat(this);
      } catch (_) {}
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

  /// Invert player controls (by negating `maxSpeed`) for [seconds].
  /// Uses a pause-aware component timer when possible so it respects game pause.
  void invertControls(double seconds) {
    if (_controlsInverted) return;
    _controlsInverted = true;
    _originalMaxSpeed = maxSpeed;
    maxSpeed = -maxSpeed;
    debugPrint('Controls inverted for $seconds seconds');
    try {
      game.add(_InvertControlsTimer(this, seconds));
    } catch (_) {
      Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()), () {
        _restoreControls();
      });
    }
  }

  void _restoreControls() {
    if (!_controlsInverted) return;
    if (_originalMaxSpeed != null) {
      maxSpeed = _originalMaxSpeed!;
    }
    _controlsInverted = false;
    _originalMaxSpeed = null;
    debugPrint('Controls restored');
  }

  /// Temporarily apply a speed multiplier to the player for [seconds].
  /// Example: `applySpeedMultiplier(5.0, 0.5)` halves the speed for 5 seconds.
  void applySpeedMultiplier(double seconds, double multiplier) {
    if (_speedModified) return;
    _speedModified = true;
    _originalMaxSpeedForModifier = maxSpeed;
    maxSpeed = maxSpeed * multiplier;
    debugPrint('Speed modified (x$multiplier) for $seconds seconds');
    try {
      game.add(_SpeedModifierTimer(this, seconds));
    } catch (_) {
      Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()), () {
        _restoreSpeedModifier();
      });
    }
  }

  void _restoreSpeedModifier() {
    if (!_speedModified) return;
    if (_originalMaxSpeedForModifier != null) {
      maxSpeed = _originalMaxSpeedForModifier!;
    }
    _speedModified = false;
    _originalMaxSpeedForModifier = null;
    debugPrint('Speed restored');
  }
}

class _InvulnerabilityTimer extends Component with HasGameReference<Game> {
  final Player player;
  double remaining;

  _InvulnerabilityTimer(this.player, double seconds) : remaining = seconds;

  @override
  void onMount() {
    super.onMount();
    // Add a subtle golden glow child to the player while invulnerable
    try {
      player.add(_InvulnerabilityGlow(player.size));
    } catch (_) {}
  }

  @override
  void update(double dt) {
    if (!game.isPlaying) return;
    remaining -= dt;
    if (remaining <= 0) {
      player.ignoreTrash = false;
      debugPrint('Invulnerability ended');
      // remove any glow children added earlier
      try {
        player.children
            .where((c) => c.runtimeType.toString() == '_InvulnerabilityGlow')
            .toList()
            .forEach((c) {
              c.removeFromParent();
            });
      } catch (_) {}
      removeFromParent();
    }
  }
}

class _InvulnerabilityGlow extends RectangleComponent {
  _InvulnerabilityGlow(Vector2 size)
    : super(
        size: size * 1.2,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()..color = const Color(0xFFFFD54F).withOpacity(0.35),
      );
}

class _InvertControlsTimer extends Component with HasGameReference<Game> {
  final Player player;
  double remaining;

  _InvertControlsTimer(this.player, double seconds) : remaining = seconds;

  @override
  void onMount() {
    super.onMount();
    // Optionally add a visual indicator while controls are inverted
    try {
      player.add(_InvertControlsGlow(player.size));
    } catch (_) {}
  }

  @override
  void update(double dt) {
    if (!game.isPlaying) return;
    remaining -= dt;
    if (remaining <= 0) {
      player._restoreControls();
      // remove any glow children added earlier
      try {
        player.children
            .where((c) => c.runtimeType.toString() == '_InvertControlsGlow')
            .toList()
            .forEach((c) => c.removeFromParent());
      } catch (_) {}
      removeFromParent();
    }
  }
}

class _InvertControlsGlow extends RectangleComponent {
  _InvertControlsGlow(Vector2 size)
    : super(
        size: size * 1.1,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()..color = const Color(0xFF90CAF9).withOpacity(0.18),
      );
}

class _SpeedModifierTimer extends Component with HasGameReference<Game> {
  final Player player;
  double remaining;

  _SpeedModifierTimer(this.player, double seconds) : remaining = seconds;

  @override
  void onMount() {
    super.onMount();
    try {
      player.add(_SpeedModifierGlow(player.size));
    } catch (_) {}
  }

  @override
  void update(double dt) {
    if (!game.isPlaying) return;
    remaining -= dt;
    if (remaining <= 0) {
      player._restoreSpeedModifier();
      try {
        player.children
            .where((c) => c.runtimeType.toString() == '_SpeedModifierGlow')
            .toList()
            .forEach((c) => c.removeFromParent());
      } catch (_) {}
      removeFromParent();
    }
  }
}

class _SpeedModifierGlow extends RectangleComponent {
  _SpeedModifierGlow(Vector2 size)
    : super(
        size: size * 1.1,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()..color = const Color(0xFFB39DDB).withOpacity(0.16),
      );
}
