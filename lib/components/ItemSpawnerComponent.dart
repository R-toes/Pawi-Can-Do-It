import 'dart:async' as async;

import 'package:flame/components.dart';
import 'package:pawicandoit/game/Game.dart';
import 'package:pawicandoit/models/Item.dart';
import 'package:pawicandoit/models/ItemFactory.dart';

class ItemSpawnerComponent extends PositionComponent
    with HasGameReference<Game> {
  List<Item> spawnedItems = [];

  final int foodSpawnRate = 50;
  final int trashSpawnRate = 50;

  late final ItemFactory itemFactory;

  ItemSpawnerComponent() {
    // set position on top of the screen
    itemFactory = ItemFactory(weights: [foodSpawnRate, trashSpawnRate]);

    // set position on top of the screen
    position = Vector2(0, 0);
    size = Vector2(800, 50); // assuming game width is 800
  }

  int counter = 0;

  @override
  async.FutureOr<void> onLoad() {
    return super.onLoad();
  }

  @override
  void update(double dt) {
    counter++;
    if (counter >= 120) {
      counter = 0;
      // spawn an item
      final item = itemFactory.generateRandomItem(
        fromX: 0,
        toX: game.size.x.toInt(),
      );
      spawnedItems.add(item);
      game.add(item);
    }
    for (final item in spawnedItems) {
      if (item.position.y > 600) {
        item.removeFromParent();
      }
    }
    super.update(dt);
  }
}
