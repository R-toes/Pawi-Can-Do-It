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
  final List<int> weights; // category weights, e.g. [foodWeight, trashWeight]
  final Random _rng;
  final double
  spawnProbability; // probability to spawn an item on each attempt (0..1)

  ItemFactory({
    required this.weights,
    this.spawnProbability = 0.00833,
    int? seed,
  }) : seed = seed ?? DateTime.now().millisecondsSinceEpoch,
       _rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

  // Attempt to generate an item. Returns null when no item should spawn.
  Item? maybeGenerateItem({int fromX = 0, int toX = 700}) {
    // keep seed updated for debugging/bookkeeping
    seed = DateTime.now().millisecondsSinceEpoch;

    // Ensure a positive range to avoid modulo by zero
    final int range = (toX - fromX) > 0 ? (toX - fromX) : 1;

    // First, check spawn probability
    if (_rng.nextDouble() >= spawnProbability) {
      return null;
    }

    final Vector2 position = Vector2(fromX + _rng.nextInt(range).toDouble(), 0);

    // Select category using integer weights for clarity
    final int totalWeight = weights.fold(0, (prev, w) => prev + w);
    final int pick = _rng.nextInt(totalWeight);

    if (pick < weights[0]) {
      // Food category
      debugPrint('Spawning Food Item');
      final double speciesRand = _rng.nextDouble();
      // Desired raw chances: seaweed=75, anchovies=10, jellyfish=5 (sum=90).
      // Normalize so probabilities sum to 1.0.
      const double seaweedProb = 75.0 / 90.0; // ~0.8333333
      const double anchoviesProb = 10.0 / 90.0; // ~0.1111111
      // jellyfishProb = 1.0 - seaweedProb - anchoviesProb (~0.0555556)

      if (speciesRand < seaweedProb) {
        return Seaweed(position: position);
      } else if (speciesRand < seaweedProb + anchoviesProb) {
        return Anchovies(position: position);
      } else {
        return Jellyfish(position: position);
      }
    } else {
      // Trash category
      debugPrint('Spawning Trash Item');
      return Trash(
        name: "Trash",
        sprite: Sprite(Flame.images.fromCache('trash.png')),
        position: position,
      );
    }
  }
}
