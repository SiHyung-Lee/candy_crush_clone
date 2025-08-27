import 'package:flutter/material.dart';

enum CandyType {
  red,
  blue,
  green,
  yellow,
  purple,
  orange,
}

class Candy {
  final CandyType type;
  final int id;
  int row;
  int col;
  bool isMarkedForRemoval;
  double animationValue;
  bool isNew;

  Candy({
    required this.type,
    required this.id,
    required this.row,
    required this.col,
    this.isMarkedForRemoval = false,
    this.animationValue = 1.0,
    this.isNew = false,
  });

  Color get color {
    switch (type) {
      case CandyType.red:
        return Colors.red;
      case CandyType.blue:
        return Colors.blue;
      case CandyType.green:
        return Colors.green;
      case CandyType.yellow:
        return Colors.yellow;
      case CandyType.purple:
        return Colors.purple;
      case CandyType.orange:
        return Colors.orange;
    }
  }

  IconData get icon {
    switch (type) {
      case CandyType.red:
        return Icons.favorite;
      case CandyType.blue:
        return Icons.water_drop;
      case CandyType.green:
        return Icons.eco;
      case CandyType.yellow:
        return Icons.star;
      case CandyType.purple:
        return Icons.diamond;
      case CandyType.orange:
        return Icons.hexagon;
    }
  }

  Candy copyWith({
    CandyType? type,
    int? id,
    int? row,
    int? col,
    bool? isMarkedForRemoval,
    double? animationValue,
    bool? isNew,
  }) {
    return Candy(
      type: type ?? this.type,
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      isMarkedForRemoval: isMarkedForRemoval ?? this.isMarkedForRemoval,
      animationValue: animationValue ?? this.animationValue,
      isNew: isNew ?? this.isNew,
    );
  }
}