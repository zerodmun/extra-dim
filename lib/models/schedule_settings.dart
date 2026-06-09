import 'package:flutter/material.dart';

class ScheduleSettings {
  final bool enabled;
  final String mode; // 'sunset' or 'custom'
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const ScheduleSettings({
    this.enabled = false,
    this.mode = 'sunset',
    this.startTime = const TimeOfDay(hour: 20, minute: 0),
    this.endTime = const TimeOfDay(hour: 6, minute: 0),
  });

  /// Whether the schedule is currently in its active window.
  bool get isInActiveWindow {
    if (!enabled) return false;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes <= endMinutes) {
      // Same-day range (e.g. 08:00 → 18:00)
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    } else {
      // Overnight range (e.g. 20:00 → 06:00)
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    }
  }

  // ─── Serialization ───────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'mode': mode,
        'startHour': startTime.hour,
        'startMinute': startTime.minute,
        'endHour': endTime.hour,
        'endMinute': endTime.minute,
      };

  factory ScheduleSettings.fromJson(Map<String, dynamic> json) {
    return ScheduleSettings(
      enabled: json['enabled'] as bool? ?? false,
      mode: json['mode'] as String? ?? 'sunset',
      startTime: TimeOfDay(
        hour: json['startHour'] as int? ?? 20,
        minute: json['startMinute'] as int? ?? 0,
      ),
      endTime: TimeOfDay(
        hour: json['endHour'] as int? ?? 6,
        minute: json['endMinute'] as int? ?? 0,
      ),
    );
  }

  // ─── Copy With ───────────────────────────────────────────────────────────

  ScheduleSettings copyWith({
    bool? enabled,
    String? mode,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return ScheduleSettings(
      enabled: enabled ?? this.enabled,
      mode: mode ?? this.mode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  /// Human-readable label for the start time.
  String get startLabel => _formatTime(startTime);

  /// Human-readable label for the end time.
  String get endLabel => _formatTime(endTime);

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleSettings &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          mode == other.mode &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => Object.hash(enabled, mode, startTime, endTime);

  @override
  String toString() =>
      'ScheduleSettings(enabled: $enabled, mode: $mode, '
      'start: $startLabel, end: $endLabel)';
}
