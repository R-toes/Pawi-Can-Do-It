import 'package:flame/components.dart';

class MainScene extends World with HasGameReference {
  // 1. Declare the background component as a late final variable.
  late final SpriteComponent _background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 2. Load the sprite and create the component WITHOUT setting the size yet.
    _background = SpriteComponent(
      sprite: await game.loadSprite('tortol_bg.png'),
    );

    // 3. Add the component to the world. It might be invisible initially if its size is zero.
    add(_background);
  }

  // 4. Use onGameResize to set the size correctly.
  // This method is guaranteed to run once the game has a valid size.
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Set the background's size to the new game size.
    _background.size = size;
  }
}
