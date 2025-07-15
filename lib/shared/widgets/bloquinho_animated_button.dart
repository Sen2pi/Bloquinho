import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BloquinhoAnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final Widget? icon;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final TextStyle? textStyle;

  const BloquinhoAnimatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.icon,
    this.height = 56,
    this.borderRadius = 12,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.shadowColor,
    this.textStyle,
  });

  @override
  State<BloquinhoAnimatedButton> createState() =>
      _BloquinhoAnimatedButtonState();
}

class _BloquinhoAnimatedButtonState extends State<BloquinhoAnimatedButton> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = widget.backgroundColor ??
        (isDark ? AppColors.darkSurface : const Color(0xFFF3E7D8));
    final fg = widget.foregroundColor ??
        (isDark ? AppColors.lightTextPrimary : const Color(0xFF7C5A2A));
    final border = widget.borderColor ??
        (isDark ? AppColors.primary : const Color(0xFF7C5A2A));
    final shadow = widget.shadowColor ??
        (isDark ? Colors.black26 : const Color(0xFFE2D2B6A0));
    final style = widget.textStyle ??
        Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 1.1,
            );

    // Animações de escala
    double scale = 1.0;
    if (_hovering && !_pressed) {
      scale = 1.035;
    } else if (_pressed) {
      scale = 0.97;
    }

    // Sombra animada
    final boxShadow = [
      if (!_pressed)
        BoxShadow(
          color: shadow,
          blurRadius: _hovering ? 16 : 8,
          offset: const Offset(0, 4),
        ),
      if (_pressed)
        BoxShadow(
          color: shadow.withOpacity(0.18),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
    ];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: !_hovering && !_pressed
                  ? bg
                  : (_pressed
                      ? (isDark
                          ? AppColors.primary.withOpacity(0.18)
                          : const Color(0xFFE9DCC7))
                      : (isDark
                          ? AppColors.primary.withOpacity(0.12)
                          : const Color(0xFFE9DCC7))),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: border,
                width: 2,
              ),
              boxShadow: boxShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: AppColors.primary.withOpacity(0.13),
                highlightColor: Colors.transparent,
                onTap: widget.enabled ? widget.onPressed : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.label,
                      style: style,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
