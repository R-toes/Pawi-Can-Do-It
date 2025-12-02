import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Game extends FlameGame {
  @override
  FutureOr<void> onLoad() {
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color.fromARGB(255, 255, 255, 255),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
