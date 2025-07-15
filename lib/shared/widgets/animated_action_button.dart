/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Animated action button that adapts to light/dark theme with smooth animations
class AnimatedActionButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final ButtonType type;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const AnimatedActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.type = ButtonType.primary,
    this.width,
    this.padding,
  });

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

enum ButtonType {
  primary,
  secondary,
  success,
  warning,
  error,
}

class _AnimatedActionButtonState extends State<AnimatedActionButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pressController;
  late AnimationController _loadingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pressAnimation;
  late Animation<double> _loadingRotation;
  late Animation<Color?> _backgroundAnimation;
  late Animation<Color?> _borderAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Main animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Press animation controller
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Scale animation for hover effect
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Press animation
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    // Loading rotation
    _loadingRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_loadingController);

    // Background color animation
    _backgroundAnimation = ColorTween(
      begin: _getButtonColor(),
      end: _getHoverColor(),
    ).animate(_controller);

    // Border animation
    _borderAnimation = ColorTween(
      begin: _getBorderColor(),
      end: _getHoverBorderColor(),
    ).animate(_controller);

    // Shimmer animation for loading state
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    // Start loading animation if needed
    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle loading state changes
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
        _loadingController.reset();
      }
    }

    // Update color animations if type changed
    if (widget.type != oldWidget.type) {
      _backgroundAnimation = ColorTween(
        begin: _getButtonColor(),
        end: _getHoverColor(),
      ).animate(_controller);
      
      _borderAnimation = ColorTween(
        begin: _getBorderColor(),
        end: _getHoverBorderColor(),
      ).animate(_controller);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pressController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Color _getButtonColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (widget.type) {
      case ButtonType.primary:
        return isDark ? AppColors.lightBackground : AppColors.primary;
      case ButtonType.secondary:
        return isDark ? AppColors.darkSurface : AppColors.lightSurface;
      case ButtonType.success:
        return AppColors.success;
      case ButtonType.warning:
        return AppColors.warning;
      case ButtonType.error:
        return AppColors.error;
    }
  }

  Color _getHoverColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (widget.type) {
      case ButtonType.primary:
        return isDark ? AppColors.lightHover : AppColors.primaryDark;
      case ButtonType.secondary:
        return isDark ? AppColors.darkHover : AppColors.lightHover;
      case ButtonType.success:
        return AppColors.success.withOpacity(0.8);
      case ButtonType.warning:
        return AppColors.warning.withOpacity(0.8);
      case ButtonType.error:
        return AppColors.error.withOpacity(0.8);
    }
  }

  Color _getBorderColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (widget.type) {
      case ButtonType.primary:
        return isDark ? AppColors.lightBorder : AppColors.primary;
      case ButtonType.secondary:
        return isDark ? AppColors.darkBorder : AppColors.lightBorder;
      case ButtonType.success:
        return AppColors.success;
      case ButtonType.warning:
        return AppColors.warning;
      case ButtonType.error:
        return AppColors.error;
    }
  }

  Color _getHoverBorderColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (widget.type) {
      case ButtonType.primary:
        return isDark ? AppColors.lightTextSecondary : AppColors.primaryDark;
      case ButtonType.secondary:
        return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
      case ButtonType.success:
        return AppColors.success.withOpacity(0.8);
      case ButtonType.warning:
        return AppColors.warning.withOpacity(0.8);
      case ButtonType.error:
        return AppColors.error.withOpacity(0.8);
    }
  }

  Color _getTextColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (widget.type) {
      case ButtonType.primary:
        return isDark ? AppColors.darkTextPrimary : Colors.white;
      case ButtonType.secondary:
        return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      case ButtonType.success:
      case ButtonType.warning:
      case ButtonType.error:
        return Colors.white;
    }
  }

  void _onPointerEnter() {
    if (!widget.isEnabled || widget.isLoading) return;
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onPointerExit() {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  void _onTapDown() {
    if (!widget.isEnabled || widget.isLoading) return;
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.isEnabled || widget.isLoading;
    
    return MouseRegion(
      onEnter: (_) => _onPointerEnter(),
      onExit: (_) => _onPointerExit(),
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        onTapCancel: _onTapCancel,
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _controller,
            _pressController,
            _loadingController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value * _pressAnimation.value,
              child: Container(
                width: widget.width,
                padding: widget.padding ?? const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDisabled 
                      ? _getButtonColor().withOpacity(0.5)
                      : _backgroundAnimation.value,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDisabled
                        ? _getBorderColor().withOpacity(0.3)
                        : _borderAnimation.value ?? _getBorderColor(),
                    width: 2,
                  ),
                  boxShadow: _isHovered && !isDisabled
                      ? [
                          BoxShadow(
                            color: _getButtonColor().withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Shimmer effect for loading
                    if (widget.isLoading)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: AnimatedBuilder(
                            animation: _shimmerAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  _shimmerAnimation.value * 200,
                                  0,
                                ),
                                child: Container(
                                  width: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    
                    // Button content
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading) ...[
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: RotationTransition(
                              turns: _loadingRotation,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _getTextColor(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ] else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 16,
                            color: isDisabled
                                ? _getTextColor().withOpacity(0.5)
                                : _getTextColor(),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: isDisabled
                                ? _getTextColor().withOpacity(0.5)
                                : _getTextColor(),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}