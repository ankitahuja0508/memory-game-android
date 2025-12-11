import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing push and local notifications
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  // Notification channel IDs
  static const String _dailyRewardChannel = 'daily_reward';
  static const String _engagementChannel = 'engagement';
  static const String _achievementChannel = 'achievement';

  // Prefs keys
  static const String _lastOpenKey = 'last_app_open';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  /// Initialize notification service (WITHOUT requesting permission)
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Initialize timezone database
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.local); // Use device's local timezone

      // Initialize local notifications (doesn't require permission)
      await _initializeLocalNotifications();

      // Set up Firebase messaging handlers
      await _setupFirebaseMessaging();

      _isInitialized = true;
      debugPrint('✅ Notification service initialized (permission handled by UI)');

      // Note: Notifications will be scheduled when user grants permission via banner
      // Update last open time
      await _updateLastOpenTime();

    } catch (e) {
      debugPrint('❌ Notification service initialization failed: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels (Android)
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    final android = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      await android.createNotificationChannel(const AndroidNotificationChannel(
        _dailyRewardChannel,
        'Daily Rewards',
        description: 'Notifications about daily rewards',
        importance: Importance.high,
      ));

      await android.createNotificationChannel(const AndroidNotificationChannel(
        _engagementChannel,
        'Game Reminders',
        description: 'Reminders to come back and play',
        importance: Importance.defaultImportance,
      ));

      await android.createNotificationChannel(const AndroidNotificationChannel(
        _achievementChannel,
        'Achievements',
        description: 'Achievement unlocked notifications',
        importance: Importance.high,
      ));
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 Received foreground message: ${message.notification?.title}');
      _showLocalNotification(
        title: message.notification?.title ?? 'Memory Match',
        body: message.notification?.body ?? '',
        channel: _engagementChannel,
      );
    });

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 Opened app from notification: ${message.notification?.title}');
    });

    // Get FCM token
    final token = await _messaging.getToken();
    debugPrint('📱 FCM Token: $token');

    // Subscribe to topics
    await _messaging.subscribeToTopic('all_users');
    await _messaging.subscribeToTopic('game_updates');
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('📬 Notification tapped: ${response.payload}');
    // Handle navigation based on payload if needed
  }

  /// Update last app open time
  Future<void> _updateLastOpenTime() async {
    await _prefs?.setInt(_lastOpenKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if notifications are enabled
  bool get areNotificationsEnabled {
    return _prefs?.getBool(_notificationsEnabledKey) ?? true;
  }

  /// Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_notificationsEnabledKey, enabled);
    
    if (!enabled) {
      await cancelAllNotifications();
    } else {
      await scheduleEngagementNotifications();
    }
  }

  /// Show a local notification immediately
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String channel,
    String? payload,
  }) async {
    if (!areNotificationsEnabled) return;

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          channel == _dailyRewardChannel ? 'Daily Rewards' :
          channel == _achievementChannel ? 'Achievements' : 'Game Reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Schedule engagement notifications
  Future<void> scheduleEngagementNotifications() async {
    if (!_isInitialized || !areNotificationsEnabled) return;

    await cancelAllNotifications();

    // Get random messages for variety
    final random = Random();

    // Schedule daily reward reminder (every day at 10 AM)
    await _scheduleDailyNotification(
      id: 1,
      title: '🎁 Daily Reward Waiting!',
      body: 'Your daily reward is ready to claim. Don\'t break your streak!',
      hour: 10,
      minute: 0,
      channel: _dailyRewardChannel,
    );

    // Schedule "We miss you" notification (if inactive for 1 day)
    final missingMessages = [
      ('🧠 Time to Train!', 'Your brain misses the workout. Come back and play!'),
      ('👋 We Miss You!', 'It\'s been a while. Ready to sharpen your memory?'),
      ('🎮 Ready to Play?', 'New challenges await! Can you beat your high score?'),
      ('💪 Stay Sharp!', 'Keep your memory in top shape. Play a quick game!'),
      ('🔥 Don\'t Lose Your Streak!', 'Come back and keep your daily streak alive!'),
    ];
    
    final (missTitle, missBody) = missingMessages[random.nextInt(missingMessages.length)];
    await _scheduleNotification(
      id: 2,
      title: missTitle,
      body: missBody,
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      channel: _engagementChannel,
    );

    // Schedule 3-day reminder
    final threeDayMessages = [
      ('🌟 Your Brain Needs You!', 'It\'s been 3 days! Your memory is waiting to be trained.'),
      ('🎯 New Levels Await!', 'Haven\'t played in a while. Ready for a challenge?'),
      ('🏆 Leaderboard Calling!', 'Other players are catching up. Defend your rank!'),
    ];
    
    final (threeTitle, threeBody) = threeDayMessages[random.nextInt(threeDayMessages.length)];
    await _scheduleNotification(
      id: 3,
      title: threeTitle,
      body: threeBody,
      scheduledDate: DateTime.now().add(const Duration(days: 3)),
      channel: _engagementChannel,
    );

    // Schedule 7-day "big reward" reminder
    await _scheduleNotification(
      id: 4,
      title: '🎁 Special Reward Waiting!',
      body: 'Come back now and get a special comeback bonus!',
      scheduledDate: DateTime.now().add(const Duration(days: 7)),
      channel: _dailyRewardChannel,
    );

    debugPrint('📅 Engagement notifications scheduled');
  }

  /// Schedule a notification for a specific date/time
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channel,
    String? payload,
  }) async {
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          channel == _dailyRewardChannel ? 'Daily Rewards' :
          channel == _achievementChannel ? 'Achievements' : 'Game Reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Schedule a daily recurring notification
  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channel,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          'Daily Rewards',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Convert DateTime to TZDateTime (using device timezone)
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.local;
    return tz.TZDateTime.from(dateTime, location);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Show achievement unlocked notification
  Future<void> showAchievementNotification({
    required String achievementName,
    required String achievementIcon,
  }) async {
    await _showLocalNotification(
      title: '🏆 Achievement Unlocked!',
      body: '$achievementIcon $achievementName',
      channel: _achievementChannel,
    );
  }

  /// Show level complete notification (for background)
  Future<void> showLevelCompleteNotification({
    required int level,
    required int stars,
  }) async {
    final starsEmoji = '⭐' * stars;
    await _showLocalNotification(
      title: '🎯 Level $level Complete!',
      body: 'You earned $starsEmoji! Keep going!',
      channel: _engagementChannel,
    );
  }

  /// Cancel engagement notifications (when user opens app)
  Future<void> onAppOpened() async {
    await _updateLastOpenTime();
    // Note: Notifications are scheduled when user grants permission via banner
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Handling background message: ${message.messageId}');
}
