import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat and Apple Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

enum Direction { up, down, left, right }

class _GameScreenState extends State<GameScreen> {
  static const int gridSize = 20;
  static const double cellSize = 20.0;

  Point<int> catPosition = const Point(10, 10);
  Point<int> applePosition = const Point(5, 5);
  Direction direction = Direction.right;
  int score = 0;
  bool gameStarted = false;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    setState(() {
      catPosition = Point(Random().nextInt(gridSize), Random().nextInt(gridSize));
      _generateApplePosition();
      direction = Direction.right;
      score = 0;
      gameStarted = true;
    });
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _updateGame();
    });
  }

  void _generateApplePosition() {
    setState(() {
      applePosition = Point(Random().nextInt(gridSize), Random().nextInt(gridSize));
      if (applePosition == catPosition) {
        _generateApplePosition();
      }
    });
  }

  void _updateGame() {
    if (!gameStarted) return;

    setState(() {
      switch (direction) {
        case Direction.up:
          catPosition = Point(catPosition.x, catPosition.y - 1);
          break;
        case Direction.down:
          catPosition = Point(catPosition.x, catPosition.y + 1);
          break;
        case Direction.left:
          catPosition = Point(catPosition.x - 1, catPosition.y);
          break;
        case Direction.right:
          catPosition = Point(catPosition.x + 1, catPosition.y);
          break;
      }

      // Check for wall collision
      if (catPosition.x < 0 ||
          catPosition.x >= gridSize ||
          catPosition.y < 0 ||
          catPosition.y >= gridSize) {
        _gameOver();
        return;
      }

      // Check for eating apple
      if (catPosition == applePosition) {
        score++;
        _generateApplePosition();
      }
    });
  }

  void _gameOver() {
    gameTimer?.cancel();
    setState(() {
      gameStarted = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your score: $score'),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat and Apple Game'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0 && direction != Direction.up) {
                  direction = Direction.down;
                } else if (details.delta.dy < 0 && direction != Direction.down) {
                  direction = Direction.up;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 && direction != Direction.left) {
                  direction = Direction.right;
                } else if (details.delta.dx < 0 && direction != Direction.right) {
                  direction = Direction.left;
                }
              },
              child: AspectRatio(
                aspectRatio: 1.0,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (BuildContext context, int index) {
                    final x = index % gridSize;
                    final y = index ~/ gridSize;
                    final position = Point(x, y);

                    if (position == catPosition) {
                      return const Center(child: Text('🐱'));
                    } else if (position == applePosition) {
                      return const Center(child: Text('🍎'));
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200, width: 0.5),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score', style: const TextStyle(fontSize: 24)),
                ElevatedButton(
                  onPressed: gameStarted ? null : startGame,
                  child: Text(gameStarted ? 'Game On!' : 'Start Game'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
