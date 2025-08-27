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
  final Set<int> _animatedCandies = {};
  int _lastBoardHash = 0;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // Clear animated candies if board has been reset (new game)
        final currentBoardHash = gameProvider.board.hashCode;
        if (currentBoardHash != _lastBoardHash && gameProvider.moves == 30) {
          _animatedCandies.clear();
          _lastBoardHash = currentBoardHash;
        }
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
                  
                  // Create a list of all candies with their positions
                  final List<Widget> candyWidgets = [];
                  
                  // First, find the highest row with any new candy across all columns
                  int highestNewCandyRow = GameProvider.rows;
                  for (int row = 0; row < GameProvider.rows; row++) {
                    for (int col = 0; col < GameProvider.cols; col++) {
                      final candy = gameProvider.board[row][col];
                      if (candy != null && candy.isNew) {
                        highestNewCandyRow = row;
                        break;
                      }
                    }
                    if (highestNewCandyRow == row) break;
                  }
                  
                  // Calculate global fall distance based on highest new candy
                  final globalFallDistance = highestNewCandyRow < GameProvider.rows ? highestNewCandyRow + 4 : 0;
                  
                  for (int row = 0; row < GameProvider.rows; row++) {
                    for (int col = 0; col < GameProvider.cols; col++) {
                      final candy = gameProvider.board[row][col];
                      if (candy != null) {
                        // Check if this candy needs falling animation
                        final needsFallingAnimation = candy.isNew && !_animatedCandies.contains(candy.id);
                        
                        if (needsFallingAnimation) {
                          _animatedCandies.add(candy.id);
                          
                          // All new candies fall from the same height
                          final fallStartPosition = -(globalFallDistance * (cellSize + 4)) + (row * (cellSize + 4) + 4);
                          
                          candyWidgets.add(
                            TweenAnimationBuilder<double>(
                              key: ValueKey('candy_${candy.id}'),
                              tween: Tween<double>(
                                begin: fallStartPosition,
                                end: row * (cellSize + 4) + 4,
                              ),
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.decelerate,
                              onEnd: () {
                                candy.isNew = false;
                              },
                              builder: (context, topValue, child) {
                                return Positioned(
                                  left: col * (cellSize + 4) + 4,
                                  top: topValue,
                                  width: cellSize - 8,
                                  height: cellSize - 8,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (!gameProvider.isProcessing) {
                                        gameProvider.selectCandy(row, col);
                                      }
                                    },
                                    child: candy.isMarkedForRemoval
                                        ? _buildExplosionEffect(candy, cellSize - 8)
                                        : AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            transform: Matrix4.identity()
                                              ..scale(
                                                gameProvider.selectedCandy?.id == candy.id ? 1.15 : 1.0
                                              ),
                                            transformAlignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: gameProvider.selectedCandy?.id == candy.id
                                                    ? Colors.yellow.shade600
                                                    : Colors.transparent,
                                                width: gameProvider.selectedCandy?.id == candy.id ? 3 : 0,
                                              ),
                                              boxShadow: gameProvider.selectedCandy?.id == candy.id
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
                              },
                            ),
                          );
                        } else {
                          // Regular animated positioned for existing candies
                          candyWidgets.add(
                            AnimatedPositioned(
                              key: ValueKey('candy_${candy.id}'),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                              left: candy.col * (cellSize + 4) + 4,
                              top: candy.row * (cellSize + 4) + 4,
                              width: cellSize - 8,
                              height: cellSize - 8,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (!gameProvider.isProcessing) {
                                    gameProvider.selectCandy(row, col);
                                  }
                                },
                                child: candy.isMarkedForRemoval
                                    ? _buildExplosionEffect(candy, cellSize - 8)
                                    : AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        transform: Matrix4.identity()
                                          ..scale(
                                            gameProvider.selectedCandy?.id == candy.id ? 1.15 : 1.0
                                          ),
                                        transformAlignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: gameProvider.selectedCandy?.id == candy.id
                                                ? Colors.yellow.shade600
                                                : Colors.transparent,
                                            width: gameProvider.selectedCandy?.id == candy.id ? 3 : 0,
                                          ),
                                          boxShadow: gameProvider.selectedCandy?.id == candy.id
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
                            ),
                          );
                        }
                      }
                    }
                  }
                  
                  return Stack(
                    clipBehavior: Clip.none,
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
                      // All candy widgets
                      ...candyWidgets,
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
    return Container(
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
    );
  }

  Widget _buildExplosionEffect(Candy candy, double size) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('explosion_${candy.id}'),
      tween: Tween(begin: 1.0, end: 0.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      onEnd: () {
        // Animation completed
      },
      builder: (context, value, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: size,
            height: size,
            child: Transform.scale(
              scale: 1.0 + (0.3 * (1 - value)), // Slight expansion
              child: Opacity(
                opacity: value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background candy shrinking
                    Transform.scale(
                      scale: value * 0.8,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              candy.color.withOpacity(0.9 * value),
                              candy.color.withOpacity(value),
                              candy.color.withOpacity(0.7 * value),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            candy.icon,
                            color: Colors.white.withOpacity(value),
                            size: 32 * value,
                          ),
                        ),
                      ),
                    ),
                    // Explosion burst
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.8 * (1 - value)),
                            candy.color.withOpacity(0.6 * (1 - value)),
                            candy.color.withOpacity(0.3 * (1 - value)),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.2, 0.5, 1.0],
                        ),
                      ),
                    ),
                    // Star particles (smaller, contained)
                    for (int i = 0; i < 6; i++)
                      Transform.rotate(
                        angle: (i * 60 * 3.14159 / 180) + ((1 - value) * 3.14159),
                        child: Transform.translate(
                          offset: Offset(0, -size * 0.25 * (1 - value)),
                          child: Icon(
                            Icons.star,
                            color: Colors.yellow.withOpacity(value * 0.8),
                            size: 8 * value,
                          ),
                        ),
                      ),
                    // Sparkles (smaller)
                    for (int i = 0; i < 8; i++)
                      Transform.rotate(
                        angle: (i * 45 * 3.14159 / 180),
                        child: Transform.translate(
                          offset: Offset(0, -size * 0.2 * (1 - value)),
                          child: Container(
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(value),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}