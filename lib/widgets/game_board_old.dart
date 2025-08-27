import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/candy.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  final Map<int, AnimationController> _animationControllers = {};
  final Map<int, Animation<Offset>> _positionAnimations = {};

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Center(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellSize = constraints.maxWidth / GameProvider.cols;
                  
                  return Stack(
                    children: [
                      // Grid background
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: GameProvider.cols,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: GameProvider.rows * GameProvider.cols,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        },
                      ),
                      // Candies layer
                      ...List.generate(GameProvider.rows * GameProvider.cols, (index) {
                        final row = index ~/ GameProvider.cols;
                        final col = index % GameProvider.cols;
                        final candy = gameProvider.board[row][col];
                        
                        if (candy == null) return const SizedBox.shrink();
                        
                        return AnimatedPositioned(
                          key: ValueKey('candy_${candy.id}'),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutQuart,
                          left: col * (cellSize + 4) + 4,
                          top: row * (cellSize + 4) + 4,
                          width: cellSize - 8,
                          height: cellSize - 8,
                          child: GestureDetector(
                            onTap: () {
                              gameProvider.selectCandy(row, col);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              transform: Matrix4.identity()
                                ..scale(
                                  gameProvider.selectedCandy == candy ? 1.15 : 1.0
                                ),
                              transformAlignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: gameProvider.selectedCandy == candy
                                      ? Colors.yellow.shade600
                                      : Colors.transparent,
                                  width: gameProvider.selectedCandy == candy ? 3 : 0,
                                ),
                                boxShadow: gameProvider.selectedCandy == candy
                                    ? [
                                        BoxShadow(
                                          color: Colors.yellow.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: _buildCandyContent(candy),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCandyContent(Candy candy) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(candy.id),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  candy.color.withOpacity(0.9),
                  candy.color,
                  candy.color.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: candy.color.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                candy.icon,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExplosionEffect(Candy candy) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Explosion burst
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        candy.color.withOpacity(0.8 * value),
                        candy.color.withOpacity(0.4 * value),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Star particles
                for (int i = 0; i < 6; i++)
                  Transform.rotate(
                    angle: (i * 60 * 3.14159 / 180) + ((1 - value) * 3.14159),
                    child: Transform.translate(
                      offset: Offset(0, -30 * (1 - value)),
                      child: Icon(
                        Icons.star,
                        color: Colors.yellow.withOpacity(value),
                        size: 20 * value,
                      ),
                    ),
                  ),
                // Center flash
                Container(
                  width: 40 * (2 - value),
                  height: 40 * (2 - value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(value * 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}