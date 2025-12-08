import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:pawicandoit/models/Anchovies.dart';
import 'package:pawicandoit/models/Item.dart';
import 'package:flame/flame.dart';
import 'package:pawicandoit/models/Jellyfish.dart';
import 'package:pawicandoit/models/Seaweed.dart';
import 'package:flame/extensions.dart';

class ItemFactory {
  int seed;
  final List<int> weights;
  final Random _rng;

  ItemFactory({required this.weights, int? seed})
    : seed = seed ?? DateTime.now().millisecondsSinceEpoch,
      _rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

  Item generateRandomItem({int fromX = 0, int toX = 700}) {
    // keep seed updated for debugging/bookkeeping
    seed = DateTime.now().millisecondsSinceEpoch;

    // Ensure a positive range to avoid modulo by zero
    final int range = (toX - fromX) > 0 ? (toX - fromX) : 1;

    // Use Random for uniformly distributed randomness
    final double randomValue = _rng.nextDouble(); // in [0, 1)
    final Vector2 position = Vector2(fromX + _rng.nextInt(range).toDouble(), 0);

    // Primary category selection using weights (assumes weights length >= 2)
    if (randomValue < (weights[0] / 100.0)) {
      debugPrint('Spawning Food Item');
      // Use a fresh random draw to pick a species within food category
      final double speciesRand = _rng.nextDouble();
      if (speciesRand < 0.40) {
        return Seaweed(position: position);
      } else if (speciesRand < 0.70) {
        return Jellyfish(position: position);
      } else {
        return Anchovies(position: position);
      }
    } else if (randomValue < ((weights[0] + weights[1]) / 100.0)) {
      debugPrint('Spawning Trash Item');
      return Trash(
        name: "Trash",
        sprite: Sprite(Flame.images.fromCache('trash.png')),
        position: position,
      );
    }

    // Fallback: ensure an Item is always returned to satisfy non-nullable return type.
    debugPrint('Spawning Default Trash Item (fallback)');
    return Trash(
      name: "Trash",
      sprite: Sprite(Flame.images.fromCache('trash.png')),
      position: position,
    );
  }
}
