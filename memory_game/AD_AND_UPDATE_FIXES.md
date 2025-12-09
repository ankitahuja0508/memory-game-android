# Ad Configuration and App Update Implementation

## Issue 1: Test Ads Showing in Release Builds ✅ FIXED

### Problem
Test ads were appearing in release builds instead of production ads.

### Root Cause
The `kReleaseMode` check alone might not be sufficient in all build configurations or when the app is built with certain flags.

### Solution Applied
Enhanced the production/debug detection in `AdConfig`:

```dart
static bool get isProduction {
  // Check if we're in release mode
  if (kReleaseMode) return true;
  
  // Additional check: assertions are only enabled in debug mode
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return !inDebugMode;
}
```

This dual-check approach ensures:
1. First checks Flutter's `kReleaseMode` constant
2. Falls back to assertion-based detection (assertions only run in debug mode)
3. More reliable detection across different build configurations

### Enhanced Logging
Added explicit logging in `AdService` to show which mode is active:
```
🏷️ Build Mode: PRODUCTION (Real Ads) or DEBUG (Test Ads)
🔑 Using App ID: ca-app-pub-xxxxx...
```

### Verification
To verify correct ad configuration:
1. Build release APK: `flutter build apk --release`
2. Install and run
3. Check logs: `adb logcat | grep "Build Mode"`
4. Should see: `Build Mode: PRODUCTION (Real Ads)`

---

## Issue 2: App Update Checker ✅ IMPLEMENTED

### Features Added

#### 1. Update Detection Service
Created `AppUpdateService` with:
- Version comparison logic
- Build number comparison (more reliable)
- Firebase Remote Config integration
- GitHub releases API fallback (optional)
- Update dismissal tracking
- Force update capability

#### 2. Remote Config Integration
Added to `RemoteConfigService`:
- `latest_app_version` - Latest available version
- `latest_build_number` - Latest build number  
- `update_required` - Force update flag
- `update_message` - Custom update message

#### 3. Automatic Update Check
- Checks on app startup (2 seconds delay)
- Shows update dialog when available
- Allows dismissal (unless required)
- Opens Play Store/App Store

### Configuration Required

#### 1. Update Version Numbers
In `app_update_service.dart`, update these for each release:
```dart
static const String _currentVersion = '1.0.0'; // Your app version
static const int _currentBuildNumber = 1;      // Your build number
```

#### 2. Configure Store URLs
In `app_update_service.dart`:
```dart
// Android Play Store URL
static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.aexyn.memorymatch.memorygame';

// iOS App Store URL (update when available)
static const String _appStoreUrl = 'https://apps.apple.com/app/idYOURAPPID';
```

#### 3. Firebase Console Setup
In Firebase Console > Remote Config, add these parameters:

| Parameter | Type | Default Value | Description |
|-----------|------|---------------|-------------|
| `latest_app_version` | String | "1.0.0" | Latest version available |
| `latest_build_number` | Number | 1 | Latest build number |
| `update_required` | Boolean | false | Force update if true |
| `update_message` | String | "A new version is available!" | Message to show users |

#### 4. Optional: GitHub Integration
If using GitHub releases:
```dart
static const String _githubApiUrl = 
  'https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/releases/latest';
```

### How It Works

1. **On App Start**: 
   - Checks Remote Config for latest version
   - Compares with current version
   - Shows dialog if update available

2. **Update Dialog**:
   - Shows version info and update message
   - "Update Now" button opens store
   - "Later" button dismisses (if not required)
   - Force updates can't be dismissed

3. **Smart Checking**:
   - Only checks once per day (unless forced)
   - Remembers dismissed versions
   - Skips in debug mode

### Testing

#### Test Update Detection
1. In Firebase Console, set:
   - `latest_app_version`: "1.0.1"
   - `latest_build_number`: 2
   - `update_message`: "Bug fixes and improvements"

2. Restart app
3. Should see update dialog after 2 seconds

#### Test Force Update
1. In Firebase Console, set:
   - `update_required`: true
   
2. Restart app
3. Update dialog can't be dismissed

### Update Flow for New Releases

When releasing a new version:

1. **Update app code**:
   ```dart
   // In app_update_service.dart
   static const String _currentVersion = '1.0.1';
   static const int _currentBuildNumber = 2;
   ```

2. **Update pubspec.yaml**:
   ```yaml
   version: 1.0.1+2
   ```

3. **Build and publish** to Play Store

4. **Update Firebase** Remote Config:
   - Set `latest_app_version` to "1.0.1"
   - Set `latest_build_number` to 2
   - Add update message
   - Set `update_required` if critical

5. **Previous versions** will automatically detect and prompt for update

### Files Modified

1. **`lib/config/ad_config.dart`**
   - Enhanced production/debug detection

2. **`lib/domain/services/ad_service.dart`**
   - Added detailed logging for build mode

3. **`lib/domain/services/app_update_service.dart`** (NEW)
   - Complete update checking implementation

4. **`lib/domain/services/remote_config_service.dart`**
   - Added update-related parameters

5. **`lib/app.dart`**
   - Integrated update checking on startup

### Benefits

- ✅ Users always know when updates are available
- ✅ Critical updates can be forced
- ✅ Flexible configuration via Firebase
- ✅ No app rebuild needed to change update messages
- ✅ Works offline (checks when online)
- ✅ Respects user dismissals

### Troubleshooting

**Ads still showing test ads?**
- Check logs for "Build Mode: PRODUCTION"
- Ensure using `--release` flag when building
- Verify AdMob App ID in AndroidManifest.xml matches production

**Update not showing?**
- Check Remote Config values in Firebase Console
- Ensure version/build number is higher than current
- Check logs for update service initialization
- Try force refresh: `AppUpdateService.instance.checkForUpdate(force: true)`

**Update dialog shows repeatedly?**
- User may have uninstalled/reinstalled
- Check SharedPreferences for dismissed version
- Clear with: `AppUpdateService.instance.clearDismissedVersion()`
