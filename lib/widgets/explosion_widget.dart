import 'package:flutter/material.dart';
import '../models/candy.dart';

class ExplosionWidget extends StatefulWidget {
  final Candy candy;
  final VoidCallback onComplete;

  const ExplosionWidget({
    super.key,
    required this.candy,
    required this.onComplete,
  });

  @override
  State<ExplosionWidget> createState() => _ExplosionWidgetState();
}

class _ExplosionWidgetState extends State<ExplosionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 3.14159 * 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main explosion burst
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.candy.color.withOpacity(_opacityAnimation.value * 0.8),
                        widget.candy.color.withOpacity(_opacityAnimation.value * 0.4),
                        widget.candy.color.withOpacity(_opacityAnimation.value * 0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),
                // Rotating star particles
                for (int i = 0; i < 8; i++)
                  Transform.rotate(
                    angle: (i * 45 * 3.14159 / 180) + _rotationAnimation.value,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        -20 * _scaleAnimation.value,
                      ),
                      child: Icon(
                        Icons.star,
                        color: Colors.yellow.withOpacity(_opacityAnimation.value),
                        size: 12 * (2 - _controller.value),
                      ),
                    ),
                  ),
                // Center flash
                Container(
                  width: 30 * _scaleAnimation.value,
                  height: 30 * _scaleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(
                      _opacityAnimation.value * 0.9,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(
                          _opacityAnimation.value * 0.5,
                        ),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Sparkle particles
                for (int i = 0; i < 12; i++)
                  Transform.rotate(
                    angle: (i * 30 * 3.14159 / 180),
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        -35 * _scaleAnimation.value,
                      ),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(_opacityAnimation.value),
                        ),
                      ),
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