import 'package:flame/components.dart';
import 'package:pawicandoit/models/player.dart';

abstract class Item extends PositionComponent {
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
    return super.onLoad();
  }

  final double speed = 50.0;

  @override
  void update(double dt) {
    position += Vector2(0, 1 * speed) * dt;
    super.update(dt);
  }

  void eat(Player player) {}
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
    // Implement food-specific eating behavior here
    print('$name has been eaten!');
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
    // Implement trash-specific eating behavior here
    print('$name is trash and should not be eaten!');
  }
}
