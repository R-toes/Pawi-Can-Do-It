import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';

class MainScene extends World with HasGameReference {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load your world components here
    // add white background
    add(
      RectangleComponent(
        size: Vector2(game.size.x, game.size.y),
        position: Vector2(0, 0),
        paint: Paint()..color = const Color(0xFFFFFFFF),
      ),
    );
  }

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);
  }
}
