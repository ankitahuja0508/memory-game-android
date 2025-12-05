import 'package:flutter/services.dart';

/// Service for haptic feedback
class HapticService {
  bool _enabled = true;

  bool get enabled => _enabled;

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Light impact - for button taps
  Future<void> lightImpact() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium impact - for card flips
  Future<void> mediumImpact() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for matches
  Future<void> heavyImpact() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection click
  Future<void> selectionClick() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for mismatch
  Future<void> errorVibration() async {
    if (!_enabled) return;
    await HapticFeedback.vibrate();
  }

  /// Success vibration pattern
  Future<void> successVibration() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Level complete celebration
  Future<void> celebrationVibration() async {
    if (!_enabled) return;
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }
}
