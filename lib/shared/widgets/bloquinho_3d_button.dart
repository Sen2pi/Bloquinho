import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class Bloquinho3DButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final Color? frontColor;
  final Color? backColor;
  final Color? borderColor;
  final Color? hoverColor;
  final bool enabled;

  const Bloquinho3DButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 150,
    this.height = 50,
    this.borderRadius = 12,
    this.textStyle,
    this.frontColor,
    this.backColor,
    this.borderColor,
    this.hoverColor,
    this.enabled = true,
  });

  @override
  State<Bloquinho3DButton> createState() => _Bloquinho3DButtonState();
}

class _Bloquinho3DButtonState extends State<Bloquinho3DButton> {
  bool _hovering = false;
  bool _pressed = false;
  double _rotation = 0;

  void _setHover(bool value) {
    setState(() {
      _hovering = value;
      _rotation = value ? 360 : 0;
    });
  }

  void _setPressed(bool value) {
    setState(() {
      _pressed = value;
      if (value) {
        _rotation = 360;
      } else if (!_hovering) {
        _rotation = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final frontColor =
        widget.frontColor ?? (isDark ? AppColors.darkSurface : Colors.white);
    final backColor = widget.backColor ??
        (isDark
            ? const Color.fromARGB(255, 47, 87, 138)
            : const Color.fromARGB(255, 117, 108, 27).withOpacity(0.9));
    final borderColor = widget.borderColor ??
        (isDark ? AppColors.primary : const Color(0xFF7C5A2A));
    final hoverColor = widget.hoverColor ??
        (isDark
            ? const Color.fromARGB(255, 24, 54, 119).withOpacity(0.8)
            : const Color.fromARGB(255, 95, 87, 14));
    final textStyle = widget.textStyle ??
        Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: 1.2,
            );

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.enabled ? widget.onPressed : null,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _rotation),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
          builder: (context, value, child) {
            // value: 0..360
            final radians = value * 3.1415926535 / 180;
            final isFront = value % 360 < 180;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(radians),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: isFront ? frontColor : hoverColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : Colors.black12,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: (textStyle != null)
                        ? textStyle.copyWith(
                            color: isFront
                                ? (isDark ? Colors.white : Colors.black)
                                : Colors.white,
                          )
                        : TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isFront
                                ? (isDark ? Colors.white : Colors.black)
                                : Colors.white,
                            letterSpacing: 1.2,
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
