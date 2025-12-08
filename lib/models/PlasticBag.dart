import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:pawicandoit/models/Item.dart';
import 'package:pawicandoit/models/player.dart';

class PlasticBag extends Trash {
  PlasticBag({position, size})
    : super(
        name: "Plastic Bag",
        sprite: Sprite(Flame.images.fromCache('PlasticBag.png')),
        position: position,
        size: size,
      );

  @override
  Future<void> onLoad() {
    super.hungerPenalty = 30.0;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void eat(Player player) {
    debugPrint('Plastic Bag eaten by player, -30 points and combo reset');
    super.eat(player);
    // inverts for 5 seconds
    player.invertControls(5.0);
  }
}
