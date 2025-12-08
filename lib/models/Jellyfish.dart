import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:pawicandoit/models/Item.dart';
import 'package:pawicandoit/models/player.dart';

class Jellyfish extends Food {
  Jellyfish({position, size})
    : super(
        name: "Jellyfish",
        sprite: Sprite(Flame.images.fromCache('Jellyfish.png')),
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
    debugPrint('Jellyfish eaten by player, +150 points and invulnerability');
    player.addScore(150);
    player.applyInvulnerability(2.5);
  }
}
