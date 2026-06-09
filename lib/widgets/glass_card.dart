import 'package:flutter/material.dart';

/// A premium glassmorphism card with subtle gradient overlay and border glow.
///
/// Provides a frosted-glass aesthetic consistent with the Extra Dim dark theme.
/// The card uses a semi-transparent dark surface with a faint diagonal gradient
/// from top-left (slightly brighter) to bottom-right for realistic depth.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  /// Content rendered inside the glass card.
  final Widget? child;

  /// Outer margin around the card. Defaults to zero.
  final EdgeInsetsGeometry? margin;

  /// Inner padding inside the card. Defaults to 20 on all sides.
  final EdgeInsetsGeometry? padding;

  /// Corner radius override. Defaults to 20.
  final double? borderRadius;

  /// Optional tap callback – makes the card act as a button.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? 20.0;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            // --- Glass surface ---
            color: const Color(0xFF1A1F36).withValues(alpha: 0.7),
            // --- Subtle gradient for glass depth ---
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.01),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
            // --- Border glow ---
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.0,
            ),
            // --- Soft drop shadow for lift ---
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
