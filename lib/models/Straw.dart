import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:pawicandoit/models/Item.dart';
import 'package:pawicandoit/models/player.dart';

class Straw extends Trash {
  Straw({position, size})
    : super(
        name: "Straw",
        sprite: Sprite(Flame.images.fromCache('Straw.png')),
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
    debugPrint('Straw eaten by player, -50 points and combo reset');
    super.eat(player);
  }
}
