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

  @override
  void eat(Player player) {
    // Seaweed-specific behavior when eaten by player
    debugPrint('Seaweed eaten by player, increasing score by 5');
    player.score += 5;
  }
}
