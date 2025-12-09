import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing in-app review/rating prompts
class RateAppService {
  RateAppService._();
  static final RateAppService instance = RateAppService._();

  final InAppReview _inAppReview = InAppReview.instance;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Prefs keys
  static const String _hasRatedKey = 'has_rated_app';
  static const String _lastPromptKey = 'last_rate_prompt';
  static const String _promptCountKey = 'rate_prompt_count';
  static const String _levelsCompletedKey = 'levels_completed_since_prompt';

  // Thresholds for showing rate prompt
  static const int _minLevelsForFirstPrompt = 5;
  static const int _minLevelsBetweenPrompts = 10;
  static const int _maxPrompts = 3;
  static const int _daysBetweenPrompts = 7;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    debugPrint('✅ Rate App service initialized');
  }

  /// Check if user has already rated
  bool get hasRated => _prefs?.getBool(_hasRatedKey) ?? false;

  /// Get number of times we've prompted
  int get _promptCount => _prefs?.getInt(_promptCountKey) ?? 0;

  /// Get levels completed since last prompt
  int get _levelsSincePrompt => _prefs?.getInt(_levelsCompletedKey) ?? 0;

  /// Mark that user has rated (or dismissed permanently)
  Future<void> markAsRated() async {
    await _prefs?.setBool(_hasRatedKey, true);
    debugPrint('✅ User marked as rated');
  }

  /// Increment levels completed counter
  Future<void> onLevelCompleted() async {
    if (!_isInitialized || hasRated) return;
    
    final current = _levelsSincePrompt;
    await _prefs?.setInt(_levelsCompletedKey, current + 1);
  }

  /// Alias for onLevelCompleted for backwards compatibility
  Future<void> incrementLevelsCompleted() => onLevelCompleted();

  /// Check if we should show the rate prompt
  Future<bool> shouldShowRatePrompt() async {
    if (!_isInitialized) return false;
    if (hasRated) return false;
    if (_promptCount >= _maxPrompts) return false;

    final levelsSincePrompt = _levelsSincePrompt;

    // First prompt after X levels
    if (_promptCount == 0 && levelsSincePrompt >= _minLevelsForFirstPrompt) {
      return true;
    }

    // Subsequent prompts
    if (_promptCount > 0 && levelsSincePrompt >= _minLevelsBetweenPrompts) {
      // Also check time since last prompt
      final lastPrompt = _prefs?.getInt(_lastPromptKey) ?? 0;
      final daysSincePrompt = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lastPrompt))
          .inDays;

      if (daysSincePrompt >= _daysBetweenPrompts) {
        return true;
      }
    }

    return false;
  }

  /// Alias for shouldShowRatePrompt for backwards compatibility
  Future<bool> shouldPromptForReview() => shouldShowRatePrompt();

  /// Request in-app review
  Future<bool> requestReview() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();
      
      if (isAvailable) {
        debugPrint('📱 Requesting in-app review...');
        await _inAppReview.requestReview();
        
        // Update counters
        await _prefs?.setInt(_promptCountKey, _promptCount + 1);
        await _prefs?.setInt(_lastPromptKey, DateTime.now().millisecondsSinceEpoch);
        await _prefs?.setInt(_levelsCompletedKey, 0); // Reset levels counter
        
        debugPrint('✅ In-app review requested');
        return true;
      } else {
        debugPrint('❌ In-app review not available');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Failed to request review: $e');
      return false;
    }
  }

  /// Open store listing (fallback)
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '123456789', // Replace with actual App Store ID
        microsoftStoreId: null,
      );
      await markAsRated();
    } catch (e) {
      debugPrint('❌ Failed to open store listing: $e');
    }
  }

  /// Reset rate prompt state (for testing)
  Future<void> resetRateState() async {
    await _prefs?.remove(_hasRatedKey);
    await _prefs?.remove(_lastPromptKey);
    await _prefs?.remove(_promptCountKey);
    await _prefs?.remove(_levelsCompletedKey);
    debugPrint('🔄 Rate state reset');
  }
}
