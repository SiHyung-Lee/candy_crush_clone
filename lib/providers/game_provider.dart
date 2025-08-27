import 'dart:math';
import 'package:flutter/material.dart';
import '../models/candy.dart';

class GameProvider extends ChangeNotifier {
  static const int rows = 8;
  static const int cols = 8;
  static const int minMatchSize = 3;
  
  List<List<Candy?>> _board = [];
  int _score = 0;
  int _moves = 30;
  int _candyIdCounter = 0;
  bool _isProcessing = false;
  Candy? _selectedCandy;
  
  List<List<Candy?>> get board => _board;
  int get score => _score;
  int get moves => _moves;
  bool get isProcessing => _isProcessing;
  Candy? get selectedCandy => _selectedCandy;
  
  GameProvider() {
    initializeBoard();
  }
  
  void initializeBoard() {
    _board = List.generate(rows, (row) => 
      List.generate(cols, (col) => _generateRandomCandy(row, col))
    );
    _score = 0;
    _moves = 30;
    _selectedCandy = null;
    
    while (hasMatches()) {
      _removeMatches();
      _fillEmptySpaces();
    }
    
    notifyListeners();
  }
  
  Candy _generateRandomCandy(int row, int col, {bool isNew = false}) {
    final random = Random();
    final types = CandyType.values;
    final type = types[random.nextInt(types.length)];
    return Candy(
      type: type,
      id: _candyIdCounter++,
      row: row,
      col: col,
      isNew: isNew,
    );
  }
  
  void selectCandy(int row, int col) {
    if (_isProcessing || _moves <= 0) return;
    
    final candy = _board[row][col];
    if (candy == null) return;
    
    if (_selectedCandy == null) {
      _selectedCandy = candy;
      notifyListeners();
    } else {
      if (_isAdjacent(_selectedCandy!, candy)) {
        _swapCandies(_selectedCandy!, candy);
      } else {
        _selectedCandy = candy;
        notifyListeners();
      }
    }
  }
  
  bool _isAdjacent(Candy candy1, Candy candy2) {
    final rowDiff = (candy1.row - candy2.row).abs();
    final colDiff = (candy1.col - candy2.col).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }
  
  bool isAdjacent(int row1, int col1, int row2, int col2) {
    final rowDiff = (row1 - row2).abs();
    final colDiff = (col1 - col2).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }
  
  Matrix4 getTransformMatrix(int row, int col) {
    return Matrix4.identity();
  }
  
  Future<void> swapCandiesWithAnimation(int row1, int col1, int row2, int col2) async {
    if (_isProcessing || _moves <= 0) return;
    
    final candy1 = _board[row1][col1];
    final candy2 = _board[row2][col2];
    
    if (candy1 == null || candy2 == null) return;
    
    _isProcessing = true;
    _selectedCandy = null;
    
    // Swap positions with animation
    _board[row1][col1] = candy2;
    _board[row2][col2] = candy1;
    
    candy1.row = row2;
    candy1.col = col2;
    candy2.row = row1;
    candy2.col = col1;
    
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (!hasMatches()) {
      // Revert swap if no match
      _board[row1][col1] = candy1;
      _board[row2][col2] = candy2;
      
      candy1.row = row1;
      candy1.col = col1;
      candy2.row = row2;
      candy2.col = col2;
      
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    } else {
      _moves--;
      await _processMatchesWithAnimation();
    }
    
    _isProcessing = false;
    
    if (_moves <= 0) {
      _gameOver();
    }
    
    notifyListeners();
  }
  
  Future<void> _swapCandies(Candy candy1, Candy candy2) async {
    _isProcessing = true;
    _selectedCandy = null;
    
    final temp = _board[candy1.row][candy1.col];
    _board[candy1.row][candy1.col] = _board[candy2.row][candy2.col];
    _board[candy2.row][candy2.col] = temp;
    
    final tempRow = candy1.row;
    final tempCol = candy1.col;
    candy1.row = candy2.row;
    candy1.col = candy2.col;
    candy2.row = tempRow;
    candy2.col = tempCol;
    
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!hasMatches()) {
      final temp = _board[candy1.row][candy1.col];
      _board[candy1.row][candy1.col] = _board[candy2.row][candy2.col];
      _board[candy2.row][candy2.col] = temp;
      
      final tempRow = candy1.row;
      final tempCol = candy1.col;
      candy1.row = candy2.row;
      candy1.col = candy2.col;
      candy2.row = tempRow;
      candy2.col = tempCol;
      
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      _moves--;
      await _processMatchesWithAnimation();
    }
    
    _isProcessing = false;
    
    if (_moves <= 0) {
      _gameOver();
    }
    
    notifyListeners();
  }
  
  Future<void> _processMatches() async {
    while (hasMatches()) {
      _removeMatches();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));
      
      _dropCandies();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));
      
      _fillEmptySpaces();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }
  
  Future<void> _processMatchesWithAnimation() async {
    while (hasMatches()) {
      _markMatchesForRemoval();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
      
      _removeMarkedCandies();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 200));
      
      await _dropCandiesWithAnimation();
      
      _fillEmptySpaces();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }
  
  void _markMatchesForRemoval() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final candy = _board[row][col];
        if (candy == null) continue;
        
        final hMatch = _checkHorizontalMatch(row, col);
        if (hMatch >= minMatchSize) {
          for (int i = col; i < cols && _board[row][i]?.type == candy.type; i++) {
            if (_board[row][i] != null) {
              _board[row][i]!.isMarkedForRemoval = true;
            }
          }
          for (int i = col - 1; i >= 0 && _board[row][i]?.type == candy.type; i--) {
            if (_board[row][i] != null) {
              _board[row][i]!.isMarkedForRemoval = true;
            }
          }
        }
        
        final vMatch = _checkVerticalMatch(row, col);
        if (vMatch >= minMatchSize) {
          for (int i = row; i < rows && _board[i][col]?.type == candy.type; i++) {
            if (_board[i][col] != null) {
              _board[i][col]!.isMarkedForRemoval = true;
            }
          }
          for (int i = row - 1; i >= 0 && _board[i][col]?.type == candy.type; i--) {
            if (_board[i][col] != null) {
              _board[i][col]!.isMarkedForRemoval = true;
            }
          }
        }
      }
    }
  }
  
  void _removeMarkedCandies() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (_board[row][col]?.isMarkedForRemoval == true) {
          _board[row][col] = null;
          _score += 10;
        }
      }
    }
  }
  
  Future<void> _dropCandiesWithAnimation() async {
    bool dropped = false;
    for (int col = 0; col < cols; col++) {
      for (int row = rows - 1; row >= 0; row--) {
        if (_board[row][col] == null) {
          for (int above = row - 1; above >= 0; above--) {
            if (_board[above][col] != null) {
              _board[row][col] = _board[above][col];
              _board[row][col]!.row = row;
              _board[above][col] = null;
              dropped = true;
              break;
            }
          }
        }
      }
    }
    if (dropped) {
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }
  
  bool hasMatches() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (_board[row][col] != null) {
          if (_checkHorizontalMatch(row, col) >= minMatchSize ||
              _checkVerticalMatch(row, col) >= minMatchSize) {
            return true;
          }
        }
      }
    }
    return false;
  }
  
  int _checkHorizontalMatch(int row, int col) {
    final candy = _board[row][col];
    if (candy == null) return 0;
    
    int count = 1;
    
    for (int i = col + 1; i < cols; i++) {
      if (_board[row][i]?.type == candy.type) {
        count++;
      } else {
        break;
      }
    }
    
    for (int i = col - 1; i >= 0; i--) {
      if (_board[row][i]?.type == candy.type) {
        count++;
      } else {
        break;
      }
    }
    
    return count;
  }
  
  int _checkVerticalMatch(int row, int col) {
    final candy = _board[row][col];
    if (candy == null) return 0;
    
    int count = 1;
    
    for (int i = row + 1; i < rows; i++) {
      if (_board[i][col]?.type == candy.type) {
        count++;
      } else {
        break;
      }
    }
    
    for (int i = row - 1; i >= 0; i--) {
      if (_board[i][col]?.type == candy.type) {
        count++;
      } else {
        break;
      }
    }
    
    return count;
  }
  
  void _removeMatches() {
    final toRemove = <Candy>[];
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final candy = _board[row][col];
        if (candy == null) continue;
        
        final hMatch = _checkHorizontalMatch(row, col);
        if (hMatch >= minMatchSize) {
          for (int i = col; i < cols && _board[row][i]?.type == candy.type; i++) {
            if (_board[row][i] != null) {
              toRemove.add(_board[row][i]!);
            }
          }
          for (int i = col - 1; i >= 0 && _board[row][i]?.type == candy.type; i--) {
            if (_board[row][i] != null) {
              toRemove.add(_board[row][i]!);
            }
          }
        }
        
        final vMatch = _checkVerticalMatch(row, col);
        if (vMatch >= minMatchSize) {
          for (int i = row; i < rows && _board[i][col]?.type == candy.type; i++) {
            if (_board[i][col] != null) {
              toRemove.add(_board[i][col]!);
            }
          }
          for (int i = row - 1; i >= 0 && _board[i][col]?.type == candy.type; i--) {
            if (_board[i][col] != null) {
              toRemove.add(_board[i][col]!);
            }
          }
        }
      }
    }
    
    for (final candy in toRemove) {
      _board[candy.row][candy.col] = null;
      _score += 10;
    }
  }
  
  void _dropCandies() {
    for (int col = 0; col < cols; col++) {
      for (int row = rows - 1; row >= 0; row--) {
        if (_board[row][col] == null) {
          for (int above = row - 1; above >= 0; above--) {
            if (_board[above][col] != null) {
              _board[row][col] = _board[above][col];
              _board[row][col]!.row = row;
              _board[above][col] = null;
              break;
            }
          }
        }
      }
    }
  }
  
  void _fillEmptySpaces() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (_board[row][col] == null) {
          _board[row][col] = _generateRandomCandy(row, col, isNew: true);
        }
      }
    }
  }
  
  void _gameOver() {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text('Final Score: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              initializeBoard();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();