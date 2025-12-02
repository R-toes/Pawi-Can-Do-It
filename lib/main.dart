import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Game;
import 'package:pawicandoit/game/Game.dart';

void main() {
  runApp(GameWidget(game: Game()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
