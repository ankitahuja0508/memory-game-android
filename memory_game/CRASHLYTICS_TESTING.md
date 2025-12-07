# 🐛 Crashlytics Testing Guide

Crashlytics is now **fully integrated**! Here's how to enable it and test it.

---

## ✅ What's Already Done

- ✅ `firebase_crashlytics` package installed
- ✅ Crashlytics Gradle plugin added
- ✅ Crashlytics initialized in `FirebaseService`
- ✅ Crash handlers configured in code
- ✅ App built with Crashlytics SDK

---

## 📋 Step 1: Enable Crashlytics in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **"memory-match---brain-training"**
3. Click **"Crashlytics"** in the left sidebar
4. Click **"Enable Crashlytics"** button
5. That's it! 

**Note:** You don't need any additional configuration - it's automatically set up with your `google-services.json`.

---

## 🧪 Step 2: Test Crashlytics

### Method 1: Run the App and Trigger a Test Crash

1. **Install the debug APK** on your device:
   ```bash
   flutter run --debug
   # OR install the APK manually
   adb install build/app/outputs/flutter-apk/app-debug.apk
   ```

2. **Trigger a test crash** (add this to a button in your app temporarily):
   ```dart
   // In any screen, add a test button
   ElevatedButton(
     onPressed: () {
       FirebaseCrashlytics.instance.crash(); // Forces a crash
     },
     child: Text('Test Crash'),
   )
   ```

3. **Or use this code in your app** (already in FirebaseService):
   ```dart
   import 'package:firebase_crashlytics/firebase_crashlytics.dart';
   
   // Trigger a test crash
   FirebaseCrashlytics.instance.crash();
   ```

4. **App will crash** - this is expected!

5. **Restart the app** - Crashlytics will send the crash report

6. **Check Firebase Console** → **Crashlytics**
   - Crash should appear within 5-10 minutes
   - First crash might take longer (up to 1 hour)

### Method 2: Log Non-Fatal Errors (Recommended for Testing)

Instead of crashing the app, you can log errors:

```dart
try {
  throw Exception('Test error for Crashlytics');
} catch (error, stackTrace) {
  FirebaseCrashlytics.instance.recordError(error, stackTrace);
}
```

This will send an error report without crashing the app.

---

## 📊 Step 3: View Crashes in Firebase Console

1. Go to **Firebase Console** → **Crashlytics**

2. You'll see:
   - **Crash-free users %** - Percentage of users not experiencing crashes
   - **Crashes** - List of all crashes
   - **Issues** - Grouped crashes by type

3. Click on a crash to see:
   - Stack trace
   - Device info (model, OS version)
   - App version
   - User ID (if set)
   - Custom logs and keys

---

## 🔧 Already Configured Features

### 1. **Automatic Crash Reporting**
All unhandled exceptions are automatically caught and reported:

```dart
// Already in main.dart via FirebaseService
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

### 2. **Custom Logs** (Optional - Add Later)
You can add custom logs to help debug:

```dart
FirebaseCrashlytics.instance.log('User completed level 5');
FirebaseCrashlytics.instance.log('Power-up used: Freeze');
```

These logs appear with the crash report.

### 3. **Custom Keys** (Optional - Add Later)
Track custom data:

```dart
FirebaseCrashlytics.instance.setCustomKey('level', 5);
FirebaseCrashlytics.instance.setCustomKey('coins', 1500);
FirebaseCrashlytics.instance.setCustomKey('player_id', userId);
```

### 4. **User Identification** (Optional - Add Later)
Identify users in crash reports:

```dart
FirebaseCrashlytics.instance.setUserIdentifier(userId);
```

---

## 🎮 What Crashlytics Tracks

### Automatically Tracked:
- ✅ App crashes
- ✅ Device model & OS version
- ✅ App version & build number
- ✅ Stack traces
- ✅ Time of crash
- ✅ Free memory/disk space

### You Can Add:
- Custom logs (e.g., "User clicked buy button")
- Custom keys (e.g., player level, coins)
- User IDs (anonymous Firebase auth ID)
- Non-fatal errors (errors that don't crash the app)

---

## 🐛 Testing Scenarios

### Scenario 1: Test Fatal Crash
```dart
// Add this button temporarily to test
TextButton(
  onPressed: () {
    FirebaseCrashlytics.instance.crash();
  },
  child: Text('💥 Test Crash'),
)
```

**Expected:**
- App crashes immediately
- After restart, crash appears in Firebase Console (5-10 min)

### Scenario 2: Test Non-Fatal Error
```dart
// In your error handling code
try {
  // Some risky operation
  int.parse('not a number');
} catch (e, stack) {
  FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
  // App continues running
}
```

**Expected:**
- App doesn't crash
- Error appears in Firebase Console under "Non-fatals" (5-10 min)

### Scenario 3: Test with Custom Data
```dart
FirebaseCrashlytics.instance.setCustomKey('testing', true);
FirebaseCrashlytics.instance.log('About to test crash');
FirebaseCrashlytics.instance.crash();
```

**Expected:**
- Crash report includes custom key and log

---

## 🚨 Important Notes

### 1. **Debug vs Release Mode**
- **Debug builds:** Crashes reported immediately
- **Release builds:** Crashes reported on next app launch
- Both modes work with Crashlytics

### 2. **First Crash Delay**
- First crash can take up to **1 hour** to appear
- Subsequent crashes appear in **5-10 minutes**
- Be patient on first test!

### 3. **Offline Crashes**
- Crashes are stored locally if offline
- Sent when internet connection is restored

### 4. **Development Testing**
To see crashes faster during development:

```bash
# Force send crash reports immediately (debug mode)
adb shell setprop debug.firebase.crashlytics.force_send_enabled true
```

Then restart the app.

---

## 📊 Crashlytics Dashboard Guide

### Key Metrics:

**Overview:**
- **Crash-free users** - Aim for 99%+
- **Crashes** - Total number
- **Affected users** - How many users hit crashes

**Issues:**
- Crashes grouped by type
- Shows most common crashes first
- Click to see full details

**Per Issue:**
- Stack trace (where crash occurred)
- Occurrences (how many times)
- Affected versions (which app versions)
- Devices (which models/OS)
- Logs & keys (custom data you added)

---

## ✅ Verification Checklist

After enabling Crashlytics:

- [ ] Firebase Console shows Crashlytics is enabled
- [ ] App runs without errors
- [ ] Test crash appears in dashboard (within 1 hour)
- [ ] Stack trace is readable
- [ ] Device info is present
- [ ] App version is correct

---

## 🔧 Troubleshooting

### Crash not appearing in console?

1. **Check Crashlytics is enabled:**
   - Firebase Console → Crashlytics → Should say "Enabled"

2. **Rebuild the app:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --debug
   ```

3. **Wait longer:**
   - First crash can take up to 1 hour
   - Subsequent crashes: 5-10 minutes

4. **Force send (debug only):**
   ```bash
   adb shell setprop debug.firebase.crashlytics.force_send_enabled true
   adb shell am force-stop com.aexyn.memorymatch.memory_game
   # Then restart the app
   ```

5. **Check logs:**
   ```bash
   flutter run
   # Look for Crashlytics initialization messages
   ```

### "Crashlytics not initialized" error?

- Ensure `google-services.json` is in `android/app/`
- Ensure Firebase is initialized before Crashlytics
- Check `main.dart` has `await FirebaseService.instance.initialize()`

---

## 🎯 Production Best Practices

### 1. **Don't Force Crashes in Production**
Remove test crash buttons before releasing!

### 2. **Add Context to Errors**
```dart
try {
  await riskyOperation();
} catch (e, stack) {
  FirebaseCrashlytics.instance.log('Context: Loading level 5 data');
  FirebaseCrashlytics.instance.setCustomKey('operation', 'loadLevel');
  FirebaseCrashlytics.instance.recordError(e, stack);
}
```

### 3. **Set User IDs**
```dart
// After anonymous sign-in
final userId = FirebaseService.instance.currentUser?.uid;
if (userId != null) {
  FirebaseCrashlytics.instance.setUserIdentifier(userId);
}
```

### 4. **Monitor Regularly**
- Check Crashlytics weekly
- Fix crashes with > 1% of users
- Prioritize crashes on latest app version

### 5. **Version Your Builds**
Update version in `pubspec.yaml` for each release:
```yaml
version: 1.0.1+2  # Increment build number
```

This helps track which version has which crashes.

---

## 📱 Example: Add Test Crash Button (Temporary)

For easy testing, add this to your settings screen temporarily:

```dart
// In settings_screen.dart
if (kDebugMode) {  // Only show in debug mode
  ListTile(
    leading: Icon(Icons.bug_report, color: Colors.red),
    title: Text('🧪 Test Crashlytics'),
    subtitle: Text('Tap to trigger a test crash'),
    onTap: () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Test Crash?'),
          content: Text('This will crash the app to test Crashlytics'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseCrashlytics.instance.crash();
              },
              child: Text('Crash Now'),
            ),
          ],
        ),
      );
    },
  ),
}
```

**Remember to remove this before releasing to production!**

---

## 📞 Support

- [Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
- [Flutter Crashlytics Plugin](https://firebase.flutter.dev/docs/crashlytics/overview/)
- [Testing Crashlytics](https://firebase.google.com/docs/crashlytics/test-implementation)

---

**🎉 Crashlytics is ready! Enable it in Firebase Console and start testing!**

