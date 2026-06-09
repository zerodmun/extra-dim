// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';

class FilterProfile {
  final String id;
  final String name;
  final int red;
  final int green;
  final int blue;
  final int intensity;
  final int dimLevel;
  final IconData icon;
  final bool isDefault;
  final bool usePixelFilter;
  final int pixelFilterLevel;

  const FilterProfile({
    required this.id,
    required this.name,
    required this.red,
    required this.green,
    required this.blue,
    required this.intensity,
    required this.dimLevel,
    required this.icon,
    this.isDefault = false,
    this.usePixelFilter = false,
    this.pixelFilterLevel = 0,
  });

  /// Maps intensity (0–100) → alpha (0–200).
  int getAlpha() => (intensity * 200 / 100).round().clamp(0, 200);

  /// Builds the overlay [Color] including computed alpha.
  Color get overlayColor => Color.fromARGB(getAlpha(), red, green, blue);

  // ─── Default Profiles ────────────────────────────────────────────────────

  static List<FilterProfile> get defaultProfiles => const [
        FilterProfile(
          id: 'default_candle',
          name: 'Candle',
          red: 255,
          green: 120,
          blue: 0,
          intensity: 40,
          dimLevel: 20,
          icon: Icons.local_fire_department,
          isDefault: true,
        ),
        FilterProfile(
          id: 'default_sunset',
          name: 'Sunset',
          red: 255,
          green: 80,
          blue: 40,
          intensity: 35,
          dimLevel: 15,
          icon: Icons.wb_twilight,
          isDefault: true,
        ),
        FilterProfile(
          id: 'default_reading',
          name: 'Reading',
          red: 255,
          green: 180,
          blue: 60,
          intensity: 25,
          dimLevel: 30,
          icon: Icons.menu_book,
          isDefault: true,
        ),
        FilterProfile(
          id: 'default_night_owl',
          name: 'Night Owl',
          red: 200,
          green: 50,
          blue: 20,
          intensity: 50,
          dimLevel: 40,
          icon: Icons.nightlight_round,
          isDefault: true,
        ),
        FilterProfile(
          id: 'default_amoled_dim',
          name: 'Amoled Dim',
          red: 0,
          green: 0,
          blue: 0,
          intensity: 35,
          dimLevel: 15,
          icon: Icons.dark_mode_rounded,
          isDefault: true,
        ),
        FilterProfile(
          id: 'default_midnight_dim',
          name: 'Midnight',
          red: 0,
          green: 0,
          blue: 0,
          intensity: 50,
          dimLevel: 35,
          icon: Icons.brightness_2_rounded,
          isDefault: true,
        ),
        FilterProfile(
          id: 'default_pixel_25',
          name: 'Pixel Filter 25%',
          red: 0,
          green: 0,
          blue: 0,
          intensity: 0,
          dimLevel: 25,
          icon: Icons.grid_3x3_rounded,
          isDefault: true,
          usePixelFilter: true,
          pixelFilterLevel: 25,
        ),
        FilterProfile(
          id: 'default_pixel_50',
          name: 'Pixel Filter 50%',
          red: 0,
          green: 0,
          blue: 0,
          intensity: 0,
          dimLevel: 50,
          icon: Icons.grid_4x4_rounded,
          isDefault: true,
          usePixelFilter: true,
          pixelFilterLevel: 50,
        ),
        FilterProfile(
          id: 'default_pixel_75',
          name: 'Pixel Filter 75%',
          red: 0,
          green: 0,
          blue: 0,
          intensity: 0,
          dimLevel: 75,
          icon: Icons.grid_on_rounded,
          isDefault: true,
          usePixelFilter: true,
          pixelFilterLevel: 75,
        ),
      ];

  // ─── Serialization ───────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'red': red,
        'green': green,
        'blue': blue,
        'intensity': intensity,
        'dimLevel': dimLevel,
        'icon': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'isDefault': isDefault,
        'usePixelFilter': usePixelFilter,
        'pixelFilterLevel': pixelFilterLevel,
      };

  factory FilterProfile.fromJson(Map<String, dynamic> json) {
    return FilterProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      red: json['red'] as int,
      green: json['green'] as int,
      blue: json['blue'] as int,
      intensity: json['intensity'] as int,
      dimLevel: json['dimLevel'] as int,
      icon: IconData(
        json['icon'] as int,
        fontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
      ),
      isDefault: json['isDefault'] as bool? ?? false,
      usePixelFilter: json['usePixelFilter'] as bool? ?? false,
      pixelFilterLevel: json['pixelFilterLevel'] as int? ?? 0,
    );
  }

  // ─── Copy With ───────────────────────────────────────────────────────────

  FilterProfile copyWith({
    String? id,
    String? name,
    int? red,
    int? green,
    int? blue,
    int? intensity,
    int? dimLevel,
    IconData? icon,
    bool? isDefault,
    bool? usePixelFilter,
    int? pixelFilterLevel,
  }) {
    return FilterProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      red: red ?? this.red,
      green: green ?? this.green,
      blue: blue ?? this.blue,
      intensity: intensity ?? this.intensity,
      dimLevel: dimLevel ?? this.dimLevel,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      usePixelFilter: usePixelFilter ?? this.usePixelFilter,
      pixelFilterLevel: pixelFilterLevel ?? this.pixelFilterLevel,
    );
  }

  /// Generate a unique id for user-created profiles.
  static String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FilterProfile(id: $id, name: $name, rgb: ($red,$green,$blue), '
      'intensity: $intensity, dim: $dimLevel)';
}
