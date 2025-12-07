import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Firebase features
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase and all services
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isInitialized = true;

      // Configure Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Enable offline persistence for Firestore
      await firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );

      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// Sign in anonymously (for cloud save without account requirement)
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await auth.signInAnonymously();
      debugPrint('✅ Signed in anonymously: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      debugPrint('❌ Anonymous sign-in failed: $e');
      crashlytics.recordError(e, StackTrace.current);
      return null;
    }
  }

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Log analytics event
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log level completion
  Future<void> logLevelComplete(int level, int stars, Duration time, int coins) async {
    await logEvent('level_complete', parameters: {
      'level': level,
      'stars': stars,
      'time_seconds': time.inSeconds,
      'coins_earned': coins,
    });
  }

  /// Log power-up usage
  Future<void> logPowerUpUsed(String powerUpId) async {
    await logEvent('power_up_used', parameters: {
      'power_up_id': powerUpId,
    });
  }

  /// Log achievement unlocked
  Future<void> logAchievementUnlocked(String achievementId) async {
    await logEvent('achievement_unlocked', parameters: {
      'achievement_id': achievementId,
    });
  }

  /// Log theme unlocked
  Future<void> logThemeUnlocked(String themeId) async {
    await logEvent('theme_unlocked', parameters: {
      'theme_id': themeId,
    });
  }

  /// Save player data to cloud
  Future<void> savePlayerData(Map<String, dynamic> playerData) async {
    if (!isSignedIn) return;

    try {
      await firestore
          .collection('players')
          .doc(currentUser!.uid)
          .set({
        ...playerData,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ Player data saved to cloud');
    } catch (e) {
      debugPrint('❌ Failed to save player data: $e');
      crashlytics.recordError(e, StackTrace.current);
    }
  }

  /// Load player data from cloud
  Future<Map<String, dynamic>?> loadPlayerData() async {
    if (!isSignedIn) return null;

    try {
      final doc = await firestore
          .collection('players')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        debugPrint('✅ Player data loaded from cloud');
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to load player data: $e');
      crashlytics.recordError(e, StackTrace.current);
      return null;
    }
  }

  /// Submit score to leaderboard
  Future<void> submitScore(int level, int score, Duration time) async {
    if (!isSignedIn) return;

    try {
      await firestore.collection('leaderboard').add({
        'userId': currentUser!.uid,
        'level': level,
        'score': score,
        'timeSeconds': time.inSeconds,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Score submitted to leaderboard');
    } catch (e) {
      debugPrint('❌ Failed to submit score: $e');
      crashlytics.recordError(e, StackTrace.current);
    }
  }

  /// Get top scores for a level
  Future<List<Map<String, dynamic>>> getLeaderboard(int level, {int limit = 10}) async {
    try {
      final query = await firestore
          .collection('leaderboard')
          .where('level', isEqualTo: level)
          .orderBy('score', descending: true)
          .orderBy('timeSeconds', descending: false)
          .limit(limit)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('❌ Failed to load leaderboard: $e');
      crashlytics.recordError(e, StackTrace.current);
      return [];
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await auth.signOut();
      debugPrint('✅ Signed out');
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
      crashlytics.recordError(e, StackTrace.current);
    }
  }
}

