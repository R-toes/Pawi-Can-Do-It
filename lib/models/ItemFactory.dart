import 'package:flame/components.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:pawicandoit/models/Item.dart';
import 'package:flame/flame.dart';
import 'package:pawicandoit/models/Seaweed.dart';
import 'package:flame/extensions.dart';

class ItemFactory {
  int seed;
  final List<int> weights;
  ItemFactory({required this.weights})
    : seed = DateTime.now().millisecondsSinceEpoch;

  Item generateRandomItem({int fromX = 0, int toX = 750}) {
    seed = DateTime.now().millisecondsSinceEpoch;
    final randomValue = (seed % 100) / 100.0;
    Vector2 position = Vector2(fromX + (seed % (toX - fromX)).toDouble(), 0);
    if (randomValue < weights[0] / 100.0) {
      debugPrint('Spawning Food Item');
      if (randomValue < 0.40) {
        return Seaweed(position: position);
      } else {
        return Seaweed(position: position);
      }
    } else {
      debugPrint('Spawning Trash Item');
      return Trash(
        name: "Trash",
        sprite: Sprite(Flame.images.fromCache('trash.png')),
        position: position,
      );
    }
  }
}
