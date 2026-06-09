import 'package:flutter/services.dart';

class OverlayService {
  static const _channel = MethodChannel('com.extradim.app/overlay');

  static bool _isRunning = false;
  static bool get isRunning => _isRunning;

  /// Check if overlay permission is granted
  static Future<bool> checkPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Request overlay permission from user
  static Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('requestPermission');
    } on PlatformException catch (e) {
      throw Exception('Failed to request permission: ${e.message}');
    }
  }

  /// Start the screen overlay filter
  static Future<void> startOverlay({
    required int red,
    required int green,
    required int blue,
    required int alpha,
    bool usePixelFilter = false,
    int pixelFilterLevel = 0,
  }) async {
    try {
      await _channel.invokeMethod('startOverlay', {
        'red': red,
        'green': green,
        'blue': blue,
        'alpha': alpha,
        'usePixelFilter': usePixelFilter,
        'pixelFilterLevel': pixelFilterLevel,
      });
      _isRunning = true;
    } on PlatformException catch (e) {
      throw Exception('Failed to start overlay: ${e.message}');
    }
  }

  /// Stop the screen overlay filter
  static Future<void> stopOverlay() async {
    try {
      await _channel.invokeMethod('stopOverlay');
      _isRunning = false;
    } on PlatformException catch (e) {
      throw Exception('Failed to stop overlay: ${e.message}');
    }
  }

  /// Update the overlay filter color and intensity
  static Future<void> updateFilter({
    required int red,
    required int green,
    required int blue,
    required int alpha,
    bool usePixelFilter = false,
    int pixelFilterLevel = 0,
  }) async {
    try {
      await _channel.invokeMethod('updateFilter', {
        'red': red,
        'green': green,
        'blue': blue,
        'alpha': alpha,
        'usePixelFilter': usePixelFilter,
        'pixelFilterLevel': pixelFilterLevel,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to update filter: ${e.message}');
    }
  }

  /// Check if overlay service is currently running
  static Future<bool> checkIsRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>('isRunning');
      _isRunning = result ?? false;
      return _isRunning;
    } on PlatformException {
      return false;
    }
  }
}
