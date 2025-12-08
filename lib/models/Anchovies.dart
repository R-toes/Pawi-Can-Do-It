import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:pawicandoit/models/Item.dart';
import 'package:pawicandoit/models/player.dart';
import 'package:pawicandoit/game/Game.dart' show Game;

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
    // Add a pause-aware timer component that decrements only while the game
    // is running. This avoids using Future.delayed which would continue
    // during a paused state.
    try {
      game.add(_AnchoviesSlowdownTimer(factor, seconds));
    } catch (_) {
      // Fallback to non-paused Future.delayed if we cannot add a component
      Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()), () {
        Item.speed /= factor;
        debugPrint('Slowdown ended, Item.speed restored');
      });
    }
  }
}

class _AnchoviesSlowdownTimer extends Component with HasGameReference<Game> {
  final double factor;
  double remaining;

  _AnchoviesSlowdownTimer(this.factor, double seconds) : remaining = seconds;

  @override
  void update(double dt) {
    if (!game.isPlaying) return;
    remaining -= dt;
    if (remaining <= 0) {
      Item.speed /= factor;
      debugPrint('Slowdown ended, Item.speed restored');
      removeFromParent();
    }
  }
}
