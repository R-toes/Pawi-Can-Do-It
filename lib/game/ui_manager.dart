import 'package:flame/components.dart';

import 'package:flame/game.dart';

/// A mixin that components can implement to receive arbitrary data from
/// `UIManager.setData`.
abstract class DataReceiver {
  void onData(dynamic data);
}

/// A simple TextComponent that accepts data via [onData]. Passing any value
/// will convert it to string and set the text.
class DataTextComponent extends TextComponent implements DataReceiver {
  DataTextComponent({
    required String text,
    Vector2? position,
    TextPaint? textPaint,
    Vector2? size,
  }) : super(text: text, textRenderer: textPaint) {
    if (position != null) this.position = position;
    if (size != null) this.size = size;
  }

  @override
  void onData(dynamic data) {
    text = data?.toString() ?? '';
  }
}

// Sprite support removed: UIManager handles in-game UI (text/data receivers)

/// Manages a set of UI components and provides an API to add/remove them and
/// to pass data to them by key.
class UIManager {
  final FlameGame game;
  final Map<String, Component> _components = {};

  UIManager(this.game);

  /// Add a generic component and register it with the game.
  void addComponent(String id, Component component) {
    if (_components.containsKey(id)) {
      removeComponent(id);
    }
    _components[id] = component;
    game.add(component);
  }

  /// Convenience: create and add a [DataTextComponent].
  void addTextComponent(
    String id, {
    required String text,
    Vector2? position,
    TextPaint? textPaint,
    Vector2? size,
  }) {
    final comp = DataTextComponent(
      text: text,
      position: position,
      textPaint: textPaint,
      size: size,
    );
    addComponent(id, comp);
  }

  /// Note: sprite convenience helpers removed — UIManager focuses on in-game
  /// UI (text and DataReceiver components). Add sprite components directly
  /// with `addComponent` if absolutely needed.

  /// Remove a component by id.
  void removeComponent(String id) {
    final c = _components.remove(id);
    if (c != null) {
      c.removeFromParent();
    }
  }

  /// Pass data to the component registered at [id]. Behavior depends on the
  /// component:
  /// - if it implements [DataReceiver], `onData` will be called.
  /// - if it's a [TextComponent], its `text` will be updated.
  /// - if it's a [TextComponent], its `text` will be updated.
  void setData(String id, dynamic data) {
    final comp = _components[id];
    if (comp == null) return;

    if (comp is DataReceiver) {
      (comp as DataReceiver).onData(data);
      return;
    }

    if (comp is TextComponent) {
      comp.text = data?.toString() ?? '';
      return;
    }
  }

  /// Retrieve the raw component by id.
  Component? get(String id) => _components[id];
}
