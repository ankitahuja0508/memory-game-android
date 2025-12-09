import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

/// Service for sharing game scores and screenshots
class ShareService {
  ShareService._();
  static final ShareService instance = ShareService._();

  final ScreenshotController screenshotController = ScreenshotController();

  /// Share score with screenshot
  Future<void> shareScore({
    required int level,
    required int stars,
    required int coins,
    required Duration time,
    required int moves,
    bool isPerfect = false,
    Uint8List? screenshotBytes,
  }) async {
    try {
      // Create share text
      final shareText = _createShareText(
        level: level,
        stars: stars,
        coins: coins,
        time: time,
        moves: moves,
        isPerfect: isPerfect,
      );

      if (screenshotBytes != null) {
        // Save screenshot to temp file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/memory_match_score.png');
        await file.writeAsBytes(screenshotBytes);

        // Share with image
        await Share.shareXFiles(
          [XFile(file.path)],
          text: shareText,
          subject: '🧠 Memory Match - Level $level Complete!',
        );
      } else {
        // Share text only
        await Share.share(
          shareText,
          subject: '🧠 Memory Match - Level $level Complete!',
        );
      }
    } catch (e) {
      debugPrint('❌ Share failed: $e');
      // Fallback to text-only share
      await Share.share(
        _createShareText(
          level: level,
          stars: stars,
          coins: coins,
          time: time,
          moves: moves,
          isPerfect: isPerfect,
        ),
      );
    }
  }

  /// Create share text message
  String _createShareText({
    required int level,
    required int stars,
    required int coins,
    required Duration time,
    required int moves,
    bool isPerfect = false,
  }) {
    final starsEmoji = '⭐' * stars + '☆' * (3 - stars);
    final timeStr = _formatDuration(time);
    
    String message = '''
🧠 Memory Match - Brain Training 🧠

🎯 Level $level Complete!
$starsEmoji

⏱️ Time: $timeStr
🎲 Moves: $moves
💰 Coins: +$coins
''';

    if (isPerfect) {
      message += '\n🏆 PERFECT GAME! No mistakes!\n';
    }

    message += '''

Can you beat my score? 🔥
Download Memory Match now!
#MemoryMatch #BrainGames #PuzzleGames
''';

    return message;
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  /// Share achievement
  Future<void> shareAchievement({
    required String achievementName,
    required String achievementIcon,
    required String description,
  }) async {
    final shareText = '''
🏆 Achievement Unlocked! 🏆

$achievementIcon $achievementName
$description

Playing Memory Match - Brain Training!
#MemoryMatch #Achievement #BrainGames
''';

    await Share.share(
      shareText,
      subject: '🏆 Achievement Unlocked: $achievementName',
    );
  }

  /// Share daily streak
  Future<void> shareStreak({required int streak}) async {
    final shareText = '''
🔥 $streak Day Streak! 🔥

I've been training my brain for $streak days straight on Memory Match!

Can you match my dedication? 💪
#MemoryMatch #DailyStreak #BrainTraining
''';

    await Share.share(
      shareText,
      subject: '🔥 $streak Day Streak on Memory Match!',
    );
  }

  /// Capture widget as image bytes
  Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('❌ Failed to capture widget: $e');
      return null;
    }
  }

  /// Share score with screenshot from a widget key
  Future<void> shareScoreWithScreenshot({
    required dynamic result, // GameResult
    required GlobalKey screenshotKey,
  }) async {
    try {
      // Capture the widget
      final screenshotBytes = await captureWidget(screenshotKey);

      // Share with result data
      await shareScore(
        level: result.level as int,
        stars: result.stars as int,
        coins: result.coinsEarned as int,
        time: result.timeTaken as Duration,
        moves: result.moves as int,
        isPerfect: result.isPerfect as bool,
        screenshotBytes: screenshotBytes,
      );
    } catch (e) {
      debugPrint('❌ Share with screenshot failed: $e');
      // Fallback to text only
      await shareScore(
        level: result.level as int,
        stars: result.stars as int,
        coins: result.coinsEarned as int,
        time: result.timeTaken as Duration,
        moves: result.moves as int,
        isPerfect: result.isPerfect as bool,
      );
    }
  }
}
