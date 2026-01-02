# Flutter Local Notifications Release Build Crash Fix

## Issue Summary
The app was crashing in release builds when the device rebooted and tried to reschedule notifications. The crash occurred with the following error:

```
Fatal Exception: java.lang.RuntimeException: Unable to start receiver 
com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver: 
java.lang.IllegalStateException: TypeToken must be created with a type argument
```

## Root Cause
ProGuard/R8 code shrinker was stripping out generic type information needed by Gson library, which is used internally by the flutter_local_notifications plugin to serialize/deserialize scheduled notifications.

## Solution Applied

### Updated ProGuard Rules
Added the following rules to `android/app/proguard-rules.pro`:

```pro
# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Gson specific rules
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Gson TypeToken and generic type information
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.google.gson.** { *; }

# Preserve generic type information for Gson
-keep class sun.misc.Unsafe { *; }
-dontwarn sun.misc.Unsafe

# Keep generic signatures for serialization
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
```

These rules ensure that:
1. Flutter Local Notifications classes are not obfuscated
2. Gson's TypeToken class and its generic type information are preserved
3. Generic signatures required for JSON serialization are maintained
4. Inner classes and annotations are kept intact

## Testing Instructions

### 1. Install the Updated Release Build
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 2. Test Notification Scheduling
1. Open the app
2. Schedule a daily reward notification (should be automatic on app launch)
3. Go to Settings > Apps > Memory Match > Notifications
4. Verify notifications are enabled

### 3. Test Boot Receiver (Critical Test)
1. Schedule notifications by using the app
2. Restart the device (power off/on)
3. After reboot, the app should NOT crash
4. Check if scheduled notifications still work

### 4. Alternative Test Method
If you don't want to reboot:
```bash
# Force stop the app
adb shell am force-stop com.aexyn.memorymatch.memorygame

# Trigger the boot receiver manually
adb shell am broadcast -a android.intent.action.BOOT_COMPLETED -p com.aexyn.memorymatch.memorygame
```

## Verification Checklist

- [x] ProGuard rules updated
- [x] Release APK built successfully
- [ ] App installs without issues
- [ ] Notifications can be scheduled
- [ ] App doesn't crash after device reboot
- [ ] Previously scheduled notifications persist after reboot

## Build Information

- Build Date: December 10, 2024
- APK Size: 68.5MB
- Location: `build/app/outputs/flutter-apk/app-release.apk`
- ProGuard: Enabled with minification
- R8: Enabled with resource shrinking

## Prevention for Future Issues

1. **Always test release builds** with device reboots when using notification plugins
2. **Check ProGuard logs** for warnings about missing classes
3. **Keep ProGuard rules updated** when adding new plugins
4. **Test on real devices** - emulators may not trigger all boot scenarios

## Additional Notes

- The fix preserves all Gson-related classes to ensure JSON serialization works
- Generic type information is critical for TypeToken to work properly
- The `Signature` attribute must be kept for generic types to be preserved
- This fix should also prevent similar issues with other plugins using Gson

## Related Files

- `/android/app/proguard-rules.pro` - Updated ProGuard configuration
- `/android/app/build.gradle.kts` - Build configuration with ProGuard enabled

## If Issues Persist

If the crash still occurs:

1. Check logcat for any new errors:
   ```bash
   adb logcat | grep -E "flutterlocalnotifications|Gson|TypeToken"
   ```

2. Verify ProGuard rules are being applied:
   - Check `build/app/outputs/mapping/release/configuration.txt`
   - Ensure our rules are included

3. Consider adding more aggressive keep rules:
   ```pro
   # Keep everything from notifications plugin (nuclear option)
   -keep class com.dexterous.flutterlocalnotifications.** { *; }
   -keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }
   ```

## References

- [Flutter Local Notifications ProGuard](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/android#proguard--r8)
- [Gson ProGuard Rules](https://github.com/google/gson/blob/master/examples/android-proguard-example/proguard.cfg)
- [R8 and Generic Types](https://developer.android.com/studio/build/shrink-code#keep-code)
