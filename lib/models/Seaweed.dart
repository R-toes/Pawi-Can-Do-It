import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:pawicandoit/models/Item.dart';
import 'package:pawicandoit/models/player.dart';

class Seaweed extends Food {
  Seaweed({position, size})
    : super(
        name: "Seaweed",
        sprite: Sprite(Flame.images.fromCache('Seaweed.jpg')),
        position: position,
        size: size,
      );

  @override
  Future<void> onLoad() {
    // TODO: implement onLoad
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Implement seaweed-specific behavior here
    super.update(dt);
  }
}
