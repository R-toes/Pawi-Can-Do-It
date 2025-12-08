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
    // TODO: implement any additional effects specific to Six Rings here
  }
}
