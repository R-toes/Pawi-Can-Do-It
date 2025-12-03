import 'dart:async' as async;

import 'package:flame/components.dart';
import 'package:pawicandoit/models/Item.dart';
import 'package:pawicandoit/models/ItemFactory.dart';

class ItemSpawnerComponent extends PositionComponent {
  List<Item> spawnedItems = [];

  final int foodSpawnRate = 70; // 70% chance to spawn food
  final int trashSpawnRate = 30; // 30% chance to spawn trash

  late final ItemFactory itemFactory;

  ItemSpawnerComponent() {
    // set position on top of the screen
    itemFactory = ItemFactory(weights: [foodSpawnRate, trashSpawnRate]);

    // set position on top of the screen
    position = Vector2(0, 0);
    size = Vector2(800, 50); // assuming game width is 800
  }

  @override
  async.FutureOr<void> onLoad() {
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Example: spawn an item every 2 seconds
    async.Timer.periodic(Duration(seconds: 2), (timer) {
      final newItem = itemFactory.generateRandomItem();
      spawnedItems.add(newItem);
      add(newItem);
    });

    for (final item in spawnedItems) {
      if (item.position.y > 600) {
        item.removeFromParent();
      }
    }
    super.update(dt);
  }
}
