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
                  
                  // Create a list of all candies with their positions
                  final List<Widget> candyWidgets = [];
                  
                  // Build all candy widgets
                  for (int row = 0; row < GameProvider.rows; row++) {
                    for (int col = 0; col < GameProvider.cols; col++) {
                      final candy = gameProvider.board[row][col];
                      if (candy != null) {
                        // Calculate positions
                        final leftPosition = candy.col * (cellSize + 4) + 4;
                        final topPosition = candy.row * (cellSize + 4) + 4;
                        
                        // Check if this is a new candy that needs falling animation
                        final shouldFall = candy.isNew && !_animatedCandies.contains(candy.id);
                        
                        if (shouldFall) {
                          _animatedCandies.add(candy.id);
                          // Add falling animation
                          candyWidgets.add(
                            TweenAnimationBuilder<double>(
                              key: ValueKey('candy_${candy.id}'),
                              tween: Tween<double>(
                                begin: -200.0, // Start from above
                                end: topPosition,
                              ),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOut,
                              onEnd: () {
                                candy.isNew = false;
                              },
                              builder: (context, animatedTop, _) {
                                return Positioned(
                                  left: leftPosition,
                                  top: animatedTop,
                                  width: cellSize - 8,
                                  height: cellSize - 8,
                                  child: _buildCandyWidget(candy, gameProvider, row, col),
                                );
                              },
                            ),
                          );
                        } else {
                          // Regular candies with movement animation
                          candyWidgets.add(
                            AnimatedPositioned(
                              key: ValueKey('candy_${candy.id}'),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeInOut,
                              left: leftPosition,
                              top: topPosition,
                              width: cellSize - 8,
                              height: cellSize - 8,
                              child: _buildCandyWidget(candy, gameProvider, row, col),
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

  Widget _buildCandyWidget(Candy candy, GameProvider gameProvider, int row, int col) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!gameProvider.isProcessing) {
          gameProvider.selectCandy(row, col);
        }
      },
      child: candy.isMarkedForRemoval
          ? Container()
          : Container(
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
              child: Transform.scale(
                scale: gameProvider.selectedCandy?.id == candy.id ? 1.15 : 1.0,
                child: _buildCandyContent(candy),
              ),
            ),
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
}