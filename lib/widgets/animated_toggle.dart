import 'package:flutter/material.dart';

/// A premium animated power toggle button.
///
/// When [isActive] is `true` the button glows with an orange gradient and the
/// power icon turns white. When off it sits as a subtle dark circle with a grey
/// icon. A satisfying scale-bounce plays on every tap.
class AnimatedToggle extends StatefulWidget {
  const AnimatedToggle({
    super.key,
    required this.isActive,
    required this.onToggle,
    this.size = 80.0,
  });

  /// Whether the toggle is currently on.
  final bool isActive;

  /// Called when the user taps the button.
  final VoidCallback onToggle;

  /// Diameter of the button. Defaults to 80.
  final double size;

  @override
  State<AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _scaleController.forward();
    await _scaleController.reverse();
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isActive;

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1F36),
                      const Color(0xFF1A1F36).withValues(alpha: 0.8),
                    ],
                  ),
            border: active
                ? null
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.50),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFB347).withValues(alpha: 0.25),
                      blurRadius: 48,
                      spreadRadius: 4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Icon(
                Icons.power_settings_new,
                key: ValueKey<bool>(active),
                size: widget.size * 0.42,
                color: active
                    ? Colors.white
                    : const Color(0xFF8B95A2).withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
