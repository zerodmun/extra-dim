import 'package:flutter/material.dart';

/// A custom slider with a gradient active track and glowing thumb.
///
/// Displays [label] on the left and [valueText] on the right above the track.
/// The active portion uses a warm orange-to-amber gradient, while the inactive
/// portion is the standard dark surface colour.
class GradientSlider extends StatelessWidget {
  const GradientSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = '',
    this.valueText = '',
    this.min = 0.0,
    this.max = 1.0,
  });

  /// Current slider value in [min] – [max] range.
  final double value;

  /// Called continuously while the user drags the thumb.
  final ValueChanged<double> onChanged;

  /// Text label rendered above the track on the left.
  final String label;

  /// Formatted value string rendered above the track on the right.
  final String valueText;

  /// Minimum slider value. Defaults to 0.
  final double min;

  /// Maximum slider value. Defaults to 1.
  final double max;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Header row ---
        if (label.isNotEmpty || valueText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8B95A2),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  valueText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // --- Custom slider ---
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: const Color(0xFFFF6B35),
            inactiveTrackColor: const Color(0xFF1A1F36),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFFFF6B35).withValues(alpha: 0.15),
            thumbShape: const _GlowingThumbShape(
              enabledThumbRadius: 12,
              glowColor: Color(0xFFFF6B35),
            ),
            trackShape: const _GradientTrackShape(),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ---------- Custom thumb with outer glow ----------

class _GlowingThumbShape extends SliderComponentShape {
  const _GlowingThumbShape({
    required this.enabledThumbRadius,
    required this.glowColor,
  });

  final double enabledThumbRadius;
  final Color glowColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(enabledThumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Outer glow.
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, enabledThumbRadius + 4, glowPaint);

    // White fill.
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius, fillPaint);

    // Inner orange dot.
    final innerPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius * 0.4, innerPaint);
  }
}

// ---------- Custom gradient track ----------

class _GradientTrackShape extends SliderTrackShape {
  const _GradientTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 6;
    final double trackLeft = offset.dx + 12;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 24;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final canvas = context.canvas;
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );
    final radius = Radius.circular(trackRect.height / 2);

    // Inactive track (full width, drawn first).
    final inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? const Color(0xFF1A1F36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, radius),
      inactivePaint,
    );

    // Active track (from left to thumb).
    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    if (activeRect.width > 0) {
      final activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
        ).createShader(activeRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(activeRect, radius),
        activePaint,
      );
    }
  }
}
