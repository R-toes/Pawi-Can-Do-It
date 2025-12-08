import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Game;
import 'package:pawicandoit/game/Game.dart';

void main() {
  final myGame = Game();
  runApp(
    GameWidget(
      game: myGame,
      overlayBuilderMap: {
        'PauseButton': (context, game) {
          final g = game as Game;
          return Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  if (g.isPlaying) {
                    g.pauseGame();
                  } else {
                    g.resumeGame();
                  }
                },
                child: Icon(g.isPlaying ? Icons.pause : Icons.play_arrow),
              ),
            ),
          );
        },
        'GameOver': (context, game) {
          final g = game as Game;
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Game Over',
                    style: TextStyle(color: Colors.white, fontSize: 36),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      g.resetGame();
                    },
                    child: const Text('Restart'),
                  ),
                ],
              ),
            ),
          );
        },
      },
      initialActiveOverlays: const ['PauseButton'],
    ),
  );
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
