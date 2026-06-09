import 'package:flutter/material.dart';

/// A selectable pill-shaped chip used for preset profiles (e.g. Night, Reading).
///
/// When [isSelected] is `true` the chip glows with an orange gradient and white
/// text. When unselected it uses a dark surface with a subtle border and muted
/// text. Colour transitions animate over 200 ms.
class ProfileChip extends StatelessWidget {
  const ProfileChip({
    super.key,
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  /// Display name shown next to the icon.
  final String name;

  /// Leading icon for the chip.
  final IconData icon;

  /// Whether this chip is currently active.
  final bool isSelected;

  /// Called when the chip is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF1A1F36),
          border: isSelected
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey<bool>(isSelected),
                size: 18,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF8B95A2),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8B95A2),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
              child: Text(name),
            ),
          ],
        ),
      ),
    );
  }
}
