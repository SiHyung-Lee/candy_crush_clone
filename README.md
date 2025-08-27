# Candy Crush Clone

A match-3 puzzle game built with Flutter, inspired by Candy Crush.

## Features

- 8x8 game board with colorful candies
- Match 3 or more candies to score points
- Smooth animations for candy swapping and removal
- Score tracking and move counter
- Responsive design for mobile devices
- Beautiful gradient UI

## How to Run

1. Ensure Flutter is installed on your system
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to launch the app

## Game Rules

- Tap to select a candy, then tap an adjacent candy to swap them
- Match 3 or more candies of the same type horizontally or vertically
- Each successful match earns 10 points per candy
- You have 30 moves to score as many points as possible
- Game ends when you run out of moves

## Project Structure

```
lib/
├── main.dart           # App entry point
├── models/
│   └── candy.dart      # Candy data model
├── providers/
│   └── game_provider.dart  # Game state management
├── screens/
│   ├── home_screen.dart    # Main menu screen
│   └── game_screen.dart    # Game play screen
└── widgets/
    ├── game_board.dart     # Game board grid
    ├── candy_widget.dart   # Individual candy widget
    └── score_board.dart    # Score and moves display
```