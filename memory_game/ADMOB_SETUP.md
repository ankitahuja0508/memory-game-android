# AdMob Setup Guide - Memory Match

## 📋 Ad Units to Create in AdMob

Create these ad units at [AdMob Console](https://admob.google.com):

### **Step 1: Create Your App**
1. Go to AdMob Console → Apps → Add App
2. Platform: Android
3. App name: Memory Match - Brain Training
4. App store: Not listed yet (select this if app isn't published)

### **Step 2: Copy Your App ID**
After creating the app, copy the **App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)

---

## 🎬 Ad Units Required (10 Total for Android)

### **1. App ID** (Required)
| Field | Value |
|-------|-------|
| Name | Memory Match - Brain Training |
| Platform | Android |
| **App ID** | `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX` |

**Update in:**
- `android/app/src/main/AndroidManifest.xml` (line 43)
- `lib/config/ad_config.dart` (line 45: `_prodAppIdAndroid`)

---

### **2. Rewarded Video Ads** (3 units)

| Ad Unit Name | Purpose | Reward | Update in `ad_config.dart` |
|--------------|---------|--------|----------------------------|
| `rewarded_shop_coins` | Shop - Watch ad for 100 coins | 100 coins | Line 48: `_prodRewardedShopAndroid` |
| `rewarded_extra_time` | Game - Watch ad for +30 seconds | 30 seconds | Line 49: `_prodRewardedExtraTimeAndroid` |
| `rewarded_daily_bonus` | Daily - 2x bonus multiplier | 2x multiplier | Line 50: `_prodRewardedDailyBonusAndroid` |

**AdMob Settings for each:**
- Ad format: Rewarded
- Reward amount: 100 / 30 / 2
- Reward type: coins / seconds / multiplier

---

### **3. Interstitial Ad** (1 unit)

| Ad Unit Name | Purpose | Update in `ad_config.dart` |
|--------------|---------|----------------------------|
| `interstitial_between_levels` | Shown every 3 levels | Line 53: `_prodInterstitialAndroid` |

**AdMob Settings:**
- Ad format: Interstitial
- Frequency cap: Optional (we control in code - 2 min cooldown, every 3 levels)

---

### **4. Banner Ads** (6 units)

| Ad Unit Name | Screen | Update in `ad_config.dart` |
|--------------|--------|----------------------------|
| `banner_home` | Home/Menu screen | Line 56: `_prodBannerHomeAndroid` |
| `banner_levels` | Level select screen | Line 57: `_prodBannerLevelsAndroid` |
| `banner_shop` | Shop/Power-ups screen | Line 58: `_prodBannerShopAndroid` |
| `banner_themes` | Themes screen | Line 59: `_prodBannerThemesAndroid` |
| `banner_achievements` | Achievements screen | Line 60: `_prodBannerAchievementsAndroid` |
| `banner_rewards` | Daily rewards screen | Line 61: `_prodBannerRewardsAndroid` |

**AdMob Settings for each:**
- Ad format: Banner
- Size: Adaptive (recommended) or Standard (320x50)

---

## 📁 Files to Update with Production IDs

### 1. `lib/config/ad_config.dart`
Replace all `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX` placeholders with your real IDs.

### 2. `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Line 43: Replace test App ID with your production App ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR_APP_ID_HERE"/>
```

---

## 🔒 Debug vs Release Mode

The app automatically uses:
- **Debug/Test builds**: Google's test ad IDs (safe for development)
- **Release builds**: Your production ad IDs (generates revenue)

**You don't need to manually switch!** The `AdConfig.isProduction` flag checks `kReleaseMode`.

```dart
// Automatic detection
flutter run              → Uses TEST ads
flutter run --release    → Uses PRODUCTION ads
flutter build apk        → Uses TEST ads (debug)
flutter build apk --release → Uses PRODUCTION ads
```

---

## ✅ Pre-requisites for App Review (Google Play)

### **1. Privacy Policy (Required)**
- [ ] Host privacy policy at: `https://YOUR_DOMAIN/privacy-policy`
- [ ] Update URL in `settings_screen.dart`
- [ ] Add URL to Google Play Console → Store listing → Privacy policy

**Our privacy policy includes:**
- AdMob data collection disclosure
- Firebase analytics disclosure
- Children's privacy (COPPA compliance)

### **2. Ad Disclosure in App Description**
Add to your Google Play description:
```
This app contains ads. Ads help us keep the game free to play.
```

### **3. Content Rating**
- Go to Play Console → Content rating
- Answer questionnaire honestly
- Ads shown: Yes
- User-generated content: No (unless you have leaderboard names)

### **4. Data Safety Section (Required)**
In Play Console → Policy → App content → Data safety:

| Data Type | Collected | Shared | Purpose |
|-----------|-----------|--------|---------|
| Device identifiers | Yes | Yes (AdMob) | Advertising, Analytics |
| Gameplay data | Yes | No | App functionality |
| Crash logs | Yes | Yes (Crashlytics) | App stability |

### **5. Ads Declaration**
Play Console → Policy → App content → Ads:
- [ ] My app contains ads
- [ ] Ads are clearly distinguishable from app content

### **6. Families Policy (If targeting children)**
If your app targets children under 13:
- [ ] Enroll in Designed for Families program
- [ ] Use only certified ad networks
- [ ] No personalized ads for children

---

## 🧪 Testing Ads

### **Test on Real Device (Recommended)**
1. Build debug APK: `flutter build apk --debug`
2. Install on device
3. Ads will use test IDs automatically
4. You'll see "Test Ad" label on ads

### **Test Production Ads (Before Release)**
1. Add your device ID to test devices in AdMob Console
2. Build release APK: `flutter build apk --release`
3. Verify ads load correctly
4. Remove device from test devices before publishing

### **Get Your Device ID**
Run the app and check logcat for:
```
Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("YOUR_DEVICE_ID"))
```

---

## 📊 Expected Revenue

| Ad Type | Typical eCPM | Impressions/Day* | Est. Daily Revenue |
|---------|--------------|------------------|-------------------|
| Rewarded Video | $10-30 | 500 | $5-15 |
| Interstitial | $5-15 | 1000 | $5-15 |
| Banner | $0.50-2 | 5000 | $2.50-10 |

*Based on 1000 daily active users with moderate engagement

---

## 🚨 Common Issues

### **Ads Not Loading**
1. Check internet connection
2. Verify ad unit IDs are correct
3. New ad units may take 1-2 hours to activate
4. Check AdMob account for policy violations

### **Low Fill Rate**
1. Check if your region has advertiser demand
2. Enable backup ad networks in mediation
3. Consider adaptive banner sizes

### **App Rejected for Ad Issues**
1. Ensure ads don't cover content
2. Don't place ads that look like UI elements
3. Interstitials shouldn't appear immediately on app launch
4. Don't incentivize clicking ads

---

## 📝 Checklist Before Release

- [ ] Create AdMob account
- [ ] Create app in AdMob
- [ ] Create all 10 ad units
- [ ] Update `ad_config.dart` with production IDs
- [ ] Update `AndroidManifest.xml` with App ID
- [ ] Host Privacy Policy
- [ ] Deploy Firebase Hosting
- [ ] Complete Data Safety section
- [ ] Complete Content Rating
- [ ] Test on real device
- [ ] Build release APK: `flutter build apk --release`
- [ ] Submit to Play Store

---

## 📞 Support

- **AdMob Help**: https://support.google.com/admob
- **Flutter Ads Plugin**: https://pub.dev/packages/google_mobile_ads
- **AdMob Policies**: https://support.google.com/admob/answer/6128543

