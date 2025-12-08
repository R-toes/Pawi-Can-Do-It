import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pawicandoit/models/player.dart';

abstract class Item extends PositionComponent with CollisionCallbacks {
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

  final double speed = 50.0;

  @override
  void update(double dt) {
    position += Vector2(0, 1 * speed) * dt;
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
    // TODO: implement eat
    super.eat(player);
  }
}

class Trash extends Item {
  Trash({
    required String name,
    required Sprite sprite,
    Vector2? position,
    Vector2? size,
  }) : super(name: name, sprite: sprite, position: position, size: size);

  @override
  void eat(Player player) {
    // TODO: implement eat
    super.eat(player);
  }
}
