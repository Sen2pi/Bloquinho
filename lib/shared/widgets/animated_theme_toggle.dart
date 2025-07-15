/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';

/// Animated day/night theme toggle widget inspired by CSS design
class AnimatedThemeToggle extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onToggle;
  final double? width;
  final double? height;

  const AnimatedThemeToggle({
    super.key,
    required this.isDarkMode,
    this.onToggle,
    this.width,
    this.height,
  });

  @override
  State<AnimatedThemeToggle> createState() => _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends State<AnimatedThemeToggle>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<Color?> _borderColorAnimation;

  // Colors based on CSS variables
  static const Color blueBackground = Color(0xFFC2E9F6);
  static const Color blueBorder = Color(0xFF72CCE3);
  static const Color blueColor = Color(0xFF96DCEE);
  static const Color yellowBackground = Color(0xFFFFFAA8);
  static const Color yellowBorder = Color(0xFFF5EB71);
  static const Color indigoBackground = Color(0xFF808FC7);
  static const Color indigoBorder = Color(0xFF5D6BAA);
  static const Color indigoColor = Color(0xFF6B7ABB);
  static const Color grayBorder = Color(0xFFE8E8EA);
  static const Color white = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    // Position animation for the sun/moon
    _positionAnimation = Tween<double>(
      begin: 4.0,
      end: 104.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Scale animation for the stretching effect
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.37),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.37, end: 1.0),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Background color animation
    _backgroundColorAnimation = ColorTween(
      begin: blueColor,
      end: indigoColor,
    ).animate(_controller);

    // Border color animation
    _borderColorAnimation = ColorTween(
      begin: blueBorder,
      end: indigoBorder,
    ).animate(_controller);

    // Set initial state
    if (widget.isDarkMode) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedThemeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDarkMode != oldWidget.isDarkMode) {
      if (widget.isDarkMode) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? 200.0;
    final height = widget.height ?? 100.0;
    final scale = width / 200.0; // Scale factor based on default width

    return GestureDetector(
      onTap: () {
        widget.onToggle?.call();
      },
      child: SizedBox(
        width: width,
        height: height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Main toggle container
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: _backgroundColorAnimation.value,
                    borderRadius: BorderRadius.circular(height / 2),
                    border: Border.all(
                      color: _borderColorAnimation.value ?? blueBorder,
                      width: 5 * scale,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Clouds/Stars background
                      _buildCloudsOrStars(scale),
                      
                      // Sun/Moon
                      Positioned(
                        left: _positionAnimation.value * scale,
                        top: 4 * scale,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 82 * scale,
                            height: 82 * scale,
                            decoration: BoxDecoration(
                              color: widget.isDarkMode ? white : yellowBackground,
                              borderRadius: BorderRadius.circular(41 * scale),
                              border: Border.all(
                                color: widget.isDarkMode ? grayBorder : yellowBorder,
                                width: 5 * scale,
                              ),
                            ),
                            child: widget.isDarkMode ? _buildMoonDots(scale) : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCloudsOrStars(double scale) {
    if (widget.isDarkMode) {
      // Stars
      return Positioned(
        right: 60 * scale,
        top: 45 * scale,
        child: AnimatedOpacity(
          opacity: _controller.value,
          duration: const Duration(milliseconds: 150),
          child: Row(
            children: [
              Container(
                width: 5 * scale,
                height: 5 * scale,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(2.5 * scale),
                ),
              ),
              SizedBox(width: 15 * scale),
              Container(
                width: 3 * scale,
                height: 3 * scale,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(1.5 * scale),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Clouds
      return Positioned(
        right: 135 * scale,
        top: 45 * scale,
        child: AnimatedOpacity(
          opacity: 1.0 - _controller.value,
          duration: const Duration(milliseconds: 150),
          child: Column(
            children: [
              Container(
                width: 40 * scale,
                height: 5 * scale,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(2.5 * scale),
                ),
              ),
              SizedBox(height: 5 * scale),
              Container(
                width: 30 * scale,
                height: 5 * scale,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(2.5 * scale),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildMoonDots(double scale) {
    return Stack(
      children: [
        Positioned(
          left: 28 * scale,
          top: 23 * scale,
          child: Container(
            width: 10 * scale,
            height: 10 * scale,
            decoration: BoxDecoration(
              color: grayBorder,
              borderRadius: BorderRadius.circular(5 * scale),
            ),
          ),
        ),
        Positioned(
          left: 13 * scale,
          top: 37 * scale,
          child: Container(
            width: 6 * scale,
            height: 6 * scale,
            decoration: BoxDecoration(
              color: grayBorder,
              borderRadius: BorderRadius.circular(3 * scale),
            ),
          ),
        ),
      ],
    );
  }
}