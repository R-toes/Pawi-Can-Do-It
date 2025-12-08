import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:pawicandoit/models/player.dart';
import 'package:pawicandoit/game/Game.dart' show Game;
import 'package:pawicandoit/game/hunger_bar.dart';

abstract class Item extends PositionComponent
    with CollisionCallbacks, HasGameReference<Game> {
  final String name;
  final Sprite sprite;

  Item({
    required this.name,
    required this.sprite,
    Vector2? position,
    Vector2? size,
  }) : super(
         position: position ?? Vector2.zero(),
         size: size ?? Vector2.all(32),
       );

  @override
  Future<void> onLoad() async {
    final spriteComponent = SpriteComponent(sprite: sprite, size: size);
    add(spriteComponent);
    // Add a collision hitbox so items register collisions with the player
    add(RectangleHitbox());
    return super.onLoad();
  }

  static double speed = 100.0;

  @override
  void update(double dt) {
    if (!game.isPlaying) return;
    position += Vector2(0, 1 * Item.speed) * dt;
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      debugPrint('collision with player detected');
      other.eat(this);
      removeFromParent();
    }
  }

  void eat(Player player) {
    // Default behavior when eaten by player
    debugPrint('$name eaten by player');
  }
}

class Food extends Item {
  Food({
    required String name,
    required Sprite sprite,
    Vector2? position,
    Vector2? size,
  }) : super(name: name, sprite: sprite, position: position, size: size);

  @override
  void eat(Player player) {
    // Default food behavior when eaten by player
    debugPrint('Food $name eaten by player, increasing score by 10');
    player.addCombo(1);
  }
}

class Trash extends Item {
  Trash({
    required String name,
    required Sprite sprite,
    Vector2? position,
    Vector2? size,
  }) : super(name: name, sprite: sprite, position: position, size: size);

  double hungerPenalty = 40.0;

  @override
  void eat(Player player) {
    // Reset combo and apply trash penalties/effects on the player.
    player.resetCombo();
    debugPrint(
      'Ate trash! Score: ${player.score}, Combo reset to ${player.combo}',
    );
    // Penalize hunger
    player.changeHunger(-hungerPenalty);
    // Visual feedback and UI shake handled by helper methods.
    _flashPlayer(player);
    _shakeHungerBar(player);
  }

  void _flashPlayer(Player player) {
    try {
      final flash = RectangleComponent(
        size: player.size,
        anchor: Anchor.center,
        position: player.size / 2,
        paint: Paint()..color = const Color.fromARGB(180, 255, 0, 0),
      );
      player.add(flash);
      try {
        flash.add(
          OpacityEffect.to(
            0.0,
            EffectController(
              duration: 0.1,
              reverseDuration: 0.1,
              repeatCount: 3,
              curve: Curves.easeInOut,
            ),
          ),
        );
      } catch (_) {}
      Future.delayed(const Duration(milliseconds: 650), () {
        try {
          flash.removeFromParent();
        } catch (_) {}
      });
    } catch (_) {}
  }

  void _shakeHungerBar(Player player) {
    try {
      final c = player.game.uiManager.get('hunger');
      if (c is HungerBarComponent) {
        c.shake();
      } else if (c is PositionComponent) {
        c.add(
          MoveEffect.by(
            Vector2(6, 0),
            EffectController(
              duration: 0.05,
              reverseDuration: 0.05,
              repeatCount: 6,
              curve: Curves.easeInOut,
            ),
          ),
        );
      }
    } catch (_) {}
  }
}
