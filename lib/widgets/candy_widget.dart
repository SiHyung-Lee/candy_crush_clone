import 'package:flutter/material.dart';
import '../models/candy.dart';

class CandyWidget extends StatefulWidget {
  final Candy candy;

  const CandyWidget({
    super.key,
    required this.candy,
  });

  @override
  State<CandyWidget> createState() => _CandyWidgetState();
}

class _CandyWidgetState extends State<CandyWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
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
        return Transform.scale(
          scale: _scaleAnimation.value * widget.candy.animationValue,
          child: Transform.rotate(
            angle: widget.candy.isMarkedForRemoval ? _rotationAnimation.value : 0,
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.candy.color.withOpacity(0.8),
                    widget.candy.color,
                    widget.candy.color.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.candy.color.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.candy.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}