import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsService {
  static const String _keyFilterActive = 'filter_active';
  static const String _keyCurrentProfileId = 'current_profile_id';
  static const String _keyCustomProfiles = 'custom_profiles';
  static const String _keyScheduleEnabled = 'schedule_enabled';
  static const String _keyScheduleMode = 'schedule_mode';
  static const String _keyScheduleStartHour = 'schedule_start_hour';
  static const String _keyScheduleStartMinute = 'schedule_start_minute';
  static const String _keyScheduleEndHour = 'schedule_end_hour';
  static const String _keyScheduleEndMinute = 'schedule_end_minute';
  static const String _keyDimLevel = 'dim_level';
  static const String _keyIntensity = 'intensity';
  static const String _keyColorRed = 'color_red';
  static const String _keyColorGreen = 'color_green';
  static const String _keyColorBlue = 'color_blue';
  static const String _keyUsePixelFilter = 'use_pixel_filter';
  static const String _keyPixelFilterLevel = 'pixel_filter_level';
  static const String _keyFirstLaunch = 'first_launch';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Filter state
  bool get isFilterActive => _prefs.getBool(_keyFilterActive) ?? false;
  Future<void> setFilterActive(bool value) =>
      _prefs.setBool(_keyFilterActive, value);

  // Current profile
  String get currentProfileId =>
      _prefs.getString(_keyCurrentProfileId) ?? 'candle';
  Future<void> setCurrentProfileId(String id) =>
      _prefs.setString(_keyCurrentProfileId, id);

  // Custom profiles (stored as JSON)
  List<Map<String, dynamic>> get customProfiles {
    final json = _prefs.getString(_keyCustomProfiles);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> setCustomProfiles(List<Map<String, dynamic>> profiles) =>
      _prefs.setString(_keyCustomProfiles, jsonEncode(profiles));

  // Schedule settings
  bool get scheduleEnabled => _prefs.getBool(_keyScheduleEnabled) ?? false;
  Future<void> setScheduleEnabled(bool value) =>
      _prefs.setBool(_keyScheduleEnabled, value);

  String get scheduleMode => _prefs.getString(_keyScheduleMode) ?? 'custom';
  Future<void> setScheduleMode(String mode) =>
      _prefs.setString(_keyScheduleMode, mode);

  TimeOfDay get scheduleStartTime => TimeOfDay(
        hour: _prefs.getInt(_keyScheduleStartHour) ?? 20,
        minute: _prefs.getInt(_keyScheduleStartMinute) ?? 0,
      );
  Future<void> setScheduleStartTime(TimeOfDay time) async {
    await _prefs.setInt(_keyScheduleStartHour, time.hour);
    await _prefs.setInt(_keyScheduleStartMinute, time.minute);
  }

  TimeOfDay get scheduleEndTime => TimeOfDay(
        hour: _prefs.getInt(_keyScheduleEndHour) ?? 6,
        minute: _prefs.getInt(_keyScheduleEndMinute) ?? 0,
      );
  Future<void> setScheduleEndTime(TimeOfDay time) async {
    await _prefs.setInt(_keyScheduleEndHour, time.hour);
    await _prefs.setInt(_keyScheduleEndMinute, time.minute);
  }

  // Dim level (0-100)
  int get dimLevel => _prefs.getInt(_keyDimLevel) ?? 20;
  Future<void> setDimLevel(int value) => _prefs.setInt(_keyDimLevel, value);

  // Intensity (0-100)
  int get intensity => _prefs.getInt(_keyIntensity) ?? 40;
  Future<void> setIntensity(int value) => _prefs.setInt(_keyIntensity, value);

  // Color
  int get colorRed => _prefs.getInt(_keyColorRed) ?? 255;
  Future<void> setColorRed(int value) => _prefs.setInt(_keyColorRed, value);

  int get colorGreen => _prefs.getInt(_keyColorGreen) ?? 120;
  Future<void> setColorGreen(int value) =>
      _prefs.setInt(_keyColorGreen, value);

  int get colorBlue => _prefs.getInt(_keyColorBlue) ?? 0;
  Future<void> setColorBlue(int value) => _prefs.setInt(_keyColorBlue, value);

  // First launch
  bool get isFirstLaunch => _prefs.getBool(_keyFirstLaunch) ?? true;
  Future<void> setFirstLaunch(bool value) =>
      _prefs.setBool(_keyFirstLaunch, value);

  // Pixel filter settings
  bool get usePixelFilter => _prefs.getBool(_keyUsePixelFilter) ?? false;
  Future<void> setUsePixelFilter(bool value) =>
      _prefs.setBool(_keyUsePixelFilter, value);

  int get pixelFilterLevel => _prefs.getInt(_keyPixelFilterLevel) ?? 0;
  Future<void> setPixelFilterLevel(int value) =>
      _prefs.setInt(_keyPixelFilterLevel, value);

  // Calculate overlay alpha from intensity + dim
  int calculateAlpha(int intensity, int dimLevel) {
    // Combine intensity (color filter strength) and dim (darkness)
    // intensity maps to 0-150, dim maps to 0-120
    // Total max alpha = 200 (never fully opaque)
    final intensityAlpha = (intensity / 100.0 * 150).round();
    final dimAlpha = (dimLevel / 100.0 * 120).round();
    return (intensityAlpha + dimAlpha).clamp(0, 220);
  }
}
