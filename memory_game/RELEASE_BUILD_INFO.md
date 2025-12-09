# Memory Game - Release Build Information

## 🔐 Keystore Information

### Keystore Details
- **Location**: `android/app/memory-game-release.keystore`
- **Alias**: `aexyno`
- **Password (Store)**: `aexyno`
- **Password (Key)**: `aexyno`
- **Validity**: 10,000 days (approximately 27 years)
- **Algorithm**: RSA 2048-bit
- **Certificate Info**:
  - CN: Aexyn
  - OU: Mobile Development
  - O: Aexyn
  - C: US

### Security Note
⚠️ **IMPORTANT**: Keep your keystore file and passwords secure!
- The keystore is already added to `.gitignore`
- Never share or commit the keystore file or `key.properties` to version control
- Backup the keystore file in a secure location
- You'll need this same keystore for all future updates to the app

## 📦 Release Builds Generated

### APK Files (Split by ABI)
Located in: `build/app/outputs/flutter-apk/`

1. **ARM 64-bit** (`app-arm64-v8a-release.apk`)
   - Size: ~33MB
   - For: Modern Android devices (most common)

2. **ARM 32-bit** (`app-armeabi-v7a-release.apk`)
   - Size: ~31MB
   - For: Older Android devices

3. **x86 64-bit** (`app-x86_64-release.apk`)
   - Size: ~34MB
   - For: Intel-based devices and emulators

### App Bundle (AAB)
Located in: `build/app/outputs/bundle/release/`

- **File**: `app-release.aab`
- **Size**: ~58MB
- **Use**: Upload to Google Play Store (recommended)
- **Benefits**: 
  - Google Play generates optimized APKs for each device
  - Smaller download size for users
  - Supports Play Feature Delivery and Play Asset Delivery

## 🚀 Release Optimizations Applied

### Code Optimization
- ✅ ProGuard/R8 minification enabled
- ✅ Code shrinking enabled
- ✅ Resource shrinking enabled
- ✅ Debug logging removed in release builds
- ✅ Tree-shaking for unused code
- ✅ Icon fonts optimized (99.6% reduction)
- ✅ Fixed: Flutter Local Notifications crash on device reboot (Gson TypeToken preserved)

### Build Configuration
- ✅ Signed with release keystore
- ✅ Production AdMob IDs configured
- ✅ Firebase Crashlytics enabled for crash reporting
- ✅ Offline persistence for Firestore

## 📱 Deployment Options

### Google Play Store (Recommended)
1. Upload `app-release.aab` to Play Console
2. Google Play will handle APK generation and optimization
3. Users get the smallest possible download

### Direct APK Distribution
1. Use the appropriate APK based on device architecture
2. Most modern devices: `app-arm64-v8a-release.apk`
3. For universal compatibility, you can create a fat APK:
   ```bash
   flutter build apk --release
   ```

## 🔄 Building Future Releases

### Update Version
1. Edit `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # Increment version and build number
   ```

2. Build new release:
   ```bash
   # For Play Store (AAB)
   flutter build appbundle --release
   
   # For APKs (split by ABI)
   flutter build apk --release --split-per-abi
   ```

### Verify Signing
To verify the APK is properly signed:
```bash
jarsigner -verify -verbose -certs app-release.apk
```

## 📊 Build Commands Reference

```bash
# Clean build
flutter clean

# Build release AAB (for Play Store)
flutter build appbundle --release

# Build release APKs (split by ABI)
flutter build apk --release --split-per-abi

# Build single universal APK
flutter build apk --release

# Run release build on device
flutter run --release
```

## 🔍 Testing Release Build

Before publishing, test the release build:
1. Install on a physical device
2. Test all features, especially:
   - AdMob ads (should show real ads, not test ads)
   - Firebase features (analytics, crashlytics, auth)
   - In-app purchases (if configured)
   - Background music and sound effects
   - Power-ups and achievements
   - Share functionality
   - Local notifications

## 📝 Pre-Launch Checklist

- [x] Release keystore created and secured
- [x] ProGuard rules configured
- [x] AdMob production IDs configured
- [x] Firebase services configured
- [x] App permissions reviewed
- [x] Privacy policy and terms updated
- [x] Release builds generated
- [ ] Test on multiple devices
- [ ] Submit for Play Store review

---

**Build Date**: December 10, 2024
**Flutter Version**: Check with `flutter --version`
**Package Name**: com.aexyn.memorymatch.memorygame
