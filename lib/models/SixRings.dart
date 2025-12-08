import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:pawicandoit/models/Item.dart';
import 'package:pawicandoit/models/player.dart';

class Sixrings extends Trash {
  Sixrings({position, size})
    : super(
        name: "Six Rings",
        sprite: Sprite(Flame.images.fromCache('SixRings.png')),
        position: position,
        size: size,
      );

  @override
  Future<void> onLoad() {
    super.hungerPenalty = 50.0;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void eat(Player player) {
    debugPrint('Six Rings eaten by player, -40 points and combo reset');
    super.eat(player);
    // immobilizes for 3 seconds
    player.applySpeedMultiplier(3.0, 0.0);
  }
}
