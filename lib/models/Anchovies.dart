import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:pawicandoit/models/Item.dart';
import 'package:pawicandoit/models/player.dart';

class Anchovies extends Food {
  Anchovies({position, size})
    : super(
        name: "Anchovies",
        sprite: Sprite(Flame.images.fromCache('Anchovies.png')),
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
    debugPrint(
      'Anchovies eaten by player, +200 points and slow items by 20% for 2.5s',
    );
    player.addScore(200);
    _applyTemporarySlowdown(0.8, 2.5);
  }

  void _applyTemporarySlowdown(double factor, double seconds) {
    debugPrint(
      'Applying slowdown factor $factor to Item.speed for $seconds seconds',
    );
    Item.speed *= factor;
    Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()), () {
      // Revert by multiplying by the inverse factor. This allows multiple
      // overlapping slowdowns to stack multiplicatively and revert correctly.
      Item.speed /= factor;
      debugPrint('Slowdown ended, Item.speed restored');
    });
  }
}
