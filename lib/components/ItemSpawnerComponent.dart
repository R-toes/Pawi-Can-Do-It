import 'dart:async' as async;

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:pawicandoit/game/Game.dart';
import 'package:pawicandoit/models/Item.dart';
import 'package:pawicandoit/models/ItemFactory.dart';
import 'package:pawicandoit/models/player.dart';

class ItemSpawnerComponent extends PositionComponent
    with HasGameReference<Game> {
  List<Item> spawnedItems = [];

  // Probability to spawn an item on each update call (0.0 - 1.0).
  // Tune this value to change overall spawn frequency. Default is ~1/120.
  double spawnProbability = 1 / 60;

  // Category chance weights (food, trash). Default 50:50
  List<int> spawnChances = [50, 50];

  int bottomLimit = 600;

  late final ItemFactory itemFactory;

  ItemSpawnerComponent({double? spawnProbability, List<int>? spawnChances}) {
    this.spawnProbability = spawnProbability ?? this.spawnProbability;
    this.spawnChances = spawnChances ?? this.spawnChances;

    itemFactory = ItemFactory(
      weights: this.spawnChances,
      spawnProbability: this.spawnProbability,
    );

    // set position on top of the screen
    position = Vector2(0, 0);
    size = Vector2(700, 50); // assuming game width is 800
  }

  @override
  async.FutureOr<void> onLoad() {
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!game.isPlaying) return;
    // Ask the factory whether to spawn right now. It will return null when no spawn.
    final Item? item = itemFactory.maybeGenerateItem(
      fromX: 0,
      toX: game.size.x.toInt(),
    );

    if (item != null) {
      spawnedItems.add(item);
      game.add(item);
    }

    // Iterate backwards so we can remove items from the list safely.
    for (int i = spawnedItems.length - 1; i >= 0; i--) {
      final item = spawnedItems[i];
      if (item.position.y > bottomLimit) {
        // Decrement the bottom limit once for this item, remove it from
        // the game and from our spawned list so it doesn't trigger again.
        bottomLimit -= 1;
        item.removeFromParent();
        spawnedItems.removeAt(i);
        debugPrint('decrementing bottom limit to $bottomLimit');
      }
    }
    super.update(dt);
  }
}
