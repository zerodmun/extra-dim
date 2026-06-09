import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The hero radial dimmer control for Extra Dim.
///
/// Renders a 270° arc from bottom-left to bottom-right with a gradient progress
/// indicator, glow effects, a draggable handle, and a centred percentage readout.
/// The value animates smoothly on change via an internal [AnimationController].
class DimmerDial extends StatefulWidget {
  const DimmerDial({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Brightness',
    this.size = 250.0,
  });

  /// Current value in the range 0.0 – 1.0.
  final double value;

  /// Called when the user drags the dial.
  final ValueChanged<double> onChanged;

  /// Small label shown below the percentage text.
  final String label;

  /// Diameter of the dial. Defaults to 250.
  final double size;

  @override
  State<DimmerDial> createState() => _DimmerDialState();
}

class _DimmerDialState extends State<DimmerDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  double _currentAnimatedValue = 0.0;

  // Arc geometry constants (in radians).
  static const double _startAngle = 135.0 * math.pi / 180.0;
  static const double _sweepAngle = 270.0 * math.pi / 180.0;

  @override
  void initState() {
    super.initState();
    _currentAnimatedValue = widget.value;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: widget.value,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ))
      ..addListener(() {
        setState(() {
          _currentAnimatedValue = _animation.value;
        });
      });
  }

  @override
  void didUpdateWidget(covariant DimmerDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.value - widget.value).abs() > 0.001) {
      _animation = Tween<double>(
        begin: _currentAnimatedValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ));
      _animController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ---------- Gesture handling ----------

  void _handlePan(Offset localPosition) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    // atan2 gives angle from positive-x axis, clockwise.
    double angle = math.atan2(dy, dx);
    if (angle < 0) angle += 2 * math.pi;

    // Map angle to value (0-1) within the arc range.
    double relativeAngle = angle - _startAngle;
    if (relativeAngle < 0) relativeAngle += 2 * math.pi;

    // Ignore touches in the dead-zone (bottom gap).
    if (relativeAngle > _sweepAngle) {
      // Snap to closest end.
      final distToStart = relativeAngle - _sweepAngle;
      final distToEnd = 2 * math.pi - relativeAngle;
      if (distToStart < distToEnd) {
        widget.onChanged(1.0);
      } else {
        widget.onChanged(0.0);
      }
      return;
    }

    final newValue = (relativeAngle / _sweepAngle).clamp(0.0, 1.0);
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_currentAnimatedValue * 100).round();

    return GestureDetector(
      onPanStart: (d) => _handlePan(d.localPosition),
      onPanUpdate: (d) => _handlePan(d.localPosition),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _DimmerDialPainter(
            value: _currentAnimatedValue,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: const Color(0xFF8B95A2).withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- CustomPainter ----------

class _DimmerDialPainter extends CustomPainter {
  _DimmerDialPainter({required this.value});

  final double value;

  static const double _startAngle = 135.0 * math.pi / 180.0;
  static const double _sweepAngle = 270.0 * math.pi / 180.0;
  static const double _trackWidth = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - _trackWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // --- Background ring ---
    final bgPaint = Paint()
      ..color = const Color(0xFF12162B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _trackWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _startAngle, _sweepAngle, false, bgPaint);

    if (value <= 0.001) return;

    final currentSweep = _sweepAngle * value;

    // --- Glow behind arc ---
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _trackWidth + 16
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..shader = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + currentSweep,
        colors: [
          const Color(0xFFFF6B35).withValues(alpha: 0.35),
          const Color(0xFFFFB347).withValues(alpha: 0.35),
        ],
        tileMode: TileMode.clamp,
      ).createShader(rect);
    canvas.drawArc(rect, _startAngle, currentSweep, false, glowPaint);

    // --- Progress arc ---
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _trackWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + currentSweep,
        colors: const [
          Color(0xFFFF6B35),
          Color(0xFFFFB347),
        ],
        tileMode: TileMode.clamp,
      ).createShader(rect);
    canvas.drawArc(rect, _startAngle, currentSweep, false, arcPaint);

    // --- Drag handle ---
    final handleAngle = _startAngle + currentSweep;
    final handleCenter = Offset(
      center.dx + radius * math.cos(handleAngle),
      center.dy + radius * math.sin(handleAngle),
    );

    // Handle outer glow.
    final handleGlow = Paint()
      ..color = const Color(0xFFFF6B35).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(handleCenter, 12, handleGlow);

    // Handle fill.
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handleCenter, 9, handlePaint);

    // Handle inner dot.
    final innerDot = Paint()
      ..color = const Color(0xFFFF6B35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handleCenter, 4.5, innerDot);
  }

  @override
  bool shouldRepaint(covariant _DimmerDialPainter old) => old.value != value;
}
