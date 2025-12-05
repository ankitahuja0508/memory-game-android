# 🎮 Memory Match - Setup Guide

This document provides instructions for setting up all external services and obtaining the necessary IDs for the Memory Match game.

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Firebase Setup](#firebase-setup)
3. [Google Ads Setup](#google-ads-setup)
4. [In-App Purchases Setup](#in-app-purchases-setup)
5. [Analytics Setup](#analytics-setup)
6. [Push Notifications](#push-notifications)
7. [Build & Deploy](#build--deploy)

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Android Studio / Xcode
- Firebase CLI (optional)

### Run the app locally

```bash
# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Build for release
flutter build apk --release     # Android
flutter build ios --release     # iOS
flutter build web --release     # Web
```

---

## 🔥 Firebase Setup

Firebase is used for:
- Cloud save/sync
- Analytics
- Crashlytics
- Remote Config
- Cloud Firestore (leaderboards)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `memory-match-game`
4. Enable Google Analytics (recommended)
5. Select or create an Analytics account

### Step 2: Add Android App

1. Click "Add App" → Android
2. Enter package name: `com.memorymatch.memory_game`
3. Enter app nickname: `Memory Match Android`
4. Download `google-services.json`
5. Place it in `android/app/google-services.json`

### Step 3: Add iOS App

1. Click "Add App" → iOS
2. Enter bundle ID: `com.memorymatch.memoryGame`
3. Enter app nickname: `Memory Match iOS`
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/GoogleService-Info.plist`

### Step 4: Add Web App

1. Click "Add App" → Web
2. Enter app nickname: `Memory Match Web`
3. Copy the configuration values

### Step 5: Configure Flutter

Add the Firebase packages to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_analytics: ^10.7.0
  firebase_crashlytics: ^3.4.0
```

Create `lib/config/firebase_config.dart`:

```dart
// MOCK CONFIGURATION - Replace with your actual Firebase config
class FirebaseConfig {
  // Android
  static const String androidApiKey = 'YOUR_ANDROID_API_KEY';
  static const String androidAppId = '1:123456789:android:abc123def456';
  static const String androidMessagingSenderId = '123456789';
  static const String androidProjectId = 'memory-match-game';

  // iOS
  static const String iosApiKey = 'YOUR_IOS_API_KEY';
  static const String iosAppId = '1:123456789:ios:abc123def456';
  static const String iosMessagingSenderId = '123456789';
  static const String iosProjectId = 'memory-match-game';
  static const String iosBundleId = 'com.memorymatch.memoryGame';

  // Web
  static const String webApiKey = 'YOUR_WEB_API_KEY';
  static const String webAppId = '1:123456789:web:abc123def456';
  static const String webMessagingSenderId = '123456789';
  static const String webProjectId = 'memory-match-game';
  static const String webAuthDomain = 'memory-match-game.firebaseapp.com';
  static const String webStorageBucket = 'memory-match-game.appspot.com';
}
```

### Step 6: Initialize Firebase

In `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MemoryGameApp());
}
```

---

## 📺 Google Ads Setup

Google AdMob is used for:
- Rewarded video ads
- Interstitial ads
- Banner ads

### Step 1: Create AdMob Account

1. Go to [AdMob](https://admob.google.com/)
2. Sign in with your Google account
3. Accept the terms and conditions

### Step 2: Create App

1. Click "Apps" → "Add App"
2. Select platform (Android/iOS)
3. Enter app name: `Memory Match`
4. Note down your **App ID**

### Step 3: Create Ad Units

Create the following ad units:

| Ad Type | Placement | Mock Ad Unit ID |
|---------|-----------|-----------------|
| Rewarded | Watch for coins | `ca-app-pub-3940256099942544/5224354917` |
| Interstitial | Between levels | `ca-app-pub-3940256099942544/1033173712` |
| Banner | Shop/Menu | `ca-app-pub-3940256099942544/6300978111` |

> ⚠️ The IDs above are **Google's test ad units**. Replace with your actual ad unit IDs for production.

### Step 4: Configure Flutter

Add to `pubspec.yaml`:

```yaml
dependencies:
  google_mobile_ads: ^4.0.0
```

Create `lib/config/ad_config.dart`:

```dart
// MOCK AD CONFIGURATION
// Replace with your actual AdMob IDs for production

import 'dart:io';

class AdConfig {
  // App IDs
  static String get appId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY'; // Your Android App ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ'; // Your iOS App ID
    }
    return '';
  }

  // Test Ad Unit IDs (use these during development)
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android test
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS test
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android test
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS test
    }
    return '';
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android test
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS test
    }
    return '';
  }
}
```

### Step 5: Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
    </application>
</manifest>
```

### Step 6: iOS Configuration

Add to `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ</string>
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
</array>
```

---

## 💰 In-App Purchases Setup

### Google Play (Android)

#### Step 1: Google Play Console Setup

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app or select existing
3. Navigate to "Monetize" → "Products" → "In-app products"

#### Step 2: Create Products

| Product ID | Type | Price | Description |
|------------|------|-------|-------------|
| `coins_small` | Consumable | $0.99 | 500 Coins |
| `coins_medium` | Consumable | $2.99 | 1,500 + 200 Bonus Coins |
| `coins_large` | Consumable | $9.99 | 5,000 + 1,000 Bonus Coins |
| `gems_small` | Consumable | $1.99 | 20 Gems |
| `gems_medium` | Consumable | $4.99 | 60 + 10 Bonus Gems |
| `gems_large` | Consumable | $9.99 | 150 + 30 Bonus Gems |
| `remove_ads` | Non-consumable | $4.99 | Remove all ads |
| `vip_monthly` | Subscription | $9.99/month | VIP Pass |

#### Step 3: License Testing

1. Go to "Settings" → "License testing"
2. Add tester email addresses
3. Set license response to "RESPOND_NORMALLY"

### App Store (iOS)

#### Step 1: App Store Connect Setup

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Navigate to "Features" → "In-App Purchases"

#### Step 2: Create Products

Create matching products with the same IDs as Android.

### Flutter Configuration

Add to `pubspec.yaml`:

```yaml
dependencies:
  in_app_purchase: ^3.1.11
```

Create `lib/config/iap_config.dart`:

```dart
// In-App Purchase Product IDs
class IAPConfig {
  // Consumables
  static const String coinsSmall = 'coins_small';
  static const String coinsMedium = 'coins_medium';
  static const String coinsLarge = 'coins_large';
  static const String gemsSmall = 'gems_small';
  static const String gemsMedium = 'gems_medium';
  static const String gemsLarge = 'gems_large';

  // Non-consumables
  static const String removeAds = 'remove_ads';

  // Subscriptions
  static const String vipMonthly = 'vip_monthly';

  static const List<String> allProducts = [
    coinsSmall,
    coinsMedium,
    coinsLarge,
    gemsSmall,
    gemsMedium,
    gemsLarge,
    removeAds,
    vipMonthly,
  ];

  // Product details (fallback if store is unavailable)
  static const Map<String, ProductInfo> productInfo = {
    coinsSmall: ProductInfo(coins: 500, price: 0.99),
    coinsMedium: ProductInfo(coins: 1500, bonus: 200, price: 2.99),
    coinsLarge: ProductInfo(coins: 5000, bonus: 1000, price: 9.99),
    gemsSmall: ProductInfo(gems: 20, price: 1.99),
    gemsMedium: ProductInfo(gems: 60, bonus: 10, price: 4.99),
    gemsLarge: ProductInfo(gems: 150, bonus: 30, price: 9.99),
  };
}

class ProductInfo {
  final int coins;
  final int gems;
  final int bonus;
  final double price;

  const ProductInfo({
    this.coins = 0,
    this.gems = 0,
    this.bonus = 0,
    required this.price,
  });
}
```

---

## 📊 Analytics Setup

### Firebase Analytics

Already included with Firebase setup. Key events to track:

```dart
// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Track level completion
  Future<void> logLevelComplete(int level, int stars, Duration time) async {
    await _analytics.logEvent(
      name: 'level_complete',
      parameters: {
        'level': level,
        'stars': stars,
        'time_seconds': time.inSeconds,
      },
    );
  }

  // Track purchase
  Future<void> logPurchase(String productId, double value) async {
    await _analytics.logPurchase(
      currency: 'USD',
      value: value,
      items: [AnalyticsEventItem(itemId: productId)],
    );
  }

  // Track ad watched
  Future<void> logAdWatched(String adType, String placement) async {
    await _analytics.logEvent(
      name: 'ad_watched',
      parameters: {
        'ad_type': adType,
        'placement': placement,
      },
    );
  }
}
```

---

## 🔔 Push Notifications

### Firebase Cloud Messaging Setup

1. In Firebase Console, go to "Cloud Messaging"
2. For iOS, upload your APNs authentication key

Add to `pubspec.yaml`:

```yaml
dependencies:
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.1.0
```

---

## 🏗️ Build & Deploy

### Android Release Build

1. Create a keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

3. Build:
```bash
flutter build appbundle --release
```

### iOS Release Build

1. Open `ios/Runner.xcworkspace` in Xcode
2. Set up signing with your Apple Developer account
3. Build:
```bash
flutter build ios --release
```

### Web Build

```bash
flutter build web --release
```

---

## 🔐 Environment Variables

For CI/CD, use these environment variables:

```bash
# Firebase
FIREBASE_ANDROID_API_KEY=your_key
FIREBASE_IOS_API_KEY=your_key
FIREBASE_PROJECT_ID=memory-match-game

# AdMob
ADMOB_ANDROID_APP_ID=ca-app-pub-xxx
ADMOB_IOS_APP_ID=ca-app-pub-xxx

# Signing
ANDROID_KEYSTORE_PASSWORD=xxx
ANDROID_KEY_PASSWORD=xxx
```

---

## 📱 Testing

### Test Accounts

For testing in-app purchases:
- Android: Add email to License Testing
- iOS: Create Sandbox tester in App Store Connect

### Test Ad Units

Use Google's test ad unit IDs during development (already configured in mock config).

---

## ✅ Checklist Before Launch

- [ ] Replace all mock Firebase config with real values
- [ ] Replace test ad unit IDs with production IDs
- [ ] Set up in-app purchase products in store consoles
- [ ] Configure analytics events
- [ ] Set up crash reporting
- [ ] Test on multiple devices
- [ ] Test offline functionality
- [ ] Review privacy policy and terms
- [ ] Set up app store listings
- [ ] Create promotional screenshots/videos

---

## 🆘 Troubleshooting

### Common Issues

**Firebase initialization fails:**
- Ensure `google-services.json` is in correct location
- Run `flutter clean && flutter pub get`

**Ads not showing:**
- Check AdMob account approval status
- Verify app is published or in testing
- Check ad unit IDs

**Purchases not working:**
- Verify product IDs match exactly
- Check app is uploaded to stores
- Test with sandbox/license testing accounts

---

## 📞 Support

For issues with this project, check:
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [AdMob Documentation](https://developers.google.com/admob)
