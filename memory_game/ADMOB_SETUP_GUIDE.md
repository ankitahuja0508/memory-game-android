# 📺 AdMob Integration Guide

AdMob ads are now **fully integrated** with test ad units! Here's everything you need to know.

---

## ✅ What's Already Implemented

### **Ad Types Integrated:**

✅ **Rewarded Video Ads** - Players watch to earn coins  
✅ **Interstitial Ads** - Full-screen ads between levels  
✅ **Banner Ads** - Small ads at bottom of screens  

### **Where Ads Appear:**

| Ad Type | Location | Trigger | User Benefit |
|---------|----------|---------|--------------|
| **Rewarded Video** | Shop Screen | User taps "Watch Ad" | Earns 100 coins |
| **Interstitial** | After Level Complete | Every 3 levels | None (optional skip) |
| **Banner** | Shop Screen | Always visible | None |
| **Banner** | Level Select Screen | Always visible | None |

### **Features:**

✅ Daily limit on rewarded ads (10/day) - prevents abuse  
✅ Cooldown between interstitial ads (2 minutes) - better UX  
✅ Frequency control (interstitial every 3 levels)  
✅ Auto-loading and preloading of ads  
✅ "Remove Ads" support (ready for IAP integration)  
✅ Error handling and retry logic  

---

## 🎮 Current Status: TEST MODE

**All ads are using Google's official test ad unit IDs.**

### What this means:

✅ **Ads work immediately** - No setup needed to test  
✅ **Real ads show** - You'll see actual Google ads  
❌ **No revenue** - Test ads don't generate money  
⚠️ **Don't use in production** - Must replace with real IDs  

### Test Ad Unit IDs Currently Used:

```dart
// Android
Rewarded:      ca-app-pub-3940256099942544/5224354917
Interstitial:  ca-app-pub-3940256099942544/1033173712
Banner:        ca-app-pub-3940256099942544/6300978111

// iOS
Rewarded:      ca-app-pub-3940256099942544/1712485313
Interstitial:  ca-app-pub-3940256099942544/4411468910
Banner:        ca-app-pub-3940256099942544/2934735716
```

---

## 🚀 How to Replace with Real Ad Units

### Step 1: Create AdMob Account

1. Go to https://admob.google.com
2. Sign in with your Google account
3. Click **"Get Started"**
4. Accept terms and conditions

### Step 2: Create Your App in AdMob

1. Click **"Apps"** → **"Add App"**
2. Select **"Android"** (or iOS)
3. **Is your app published?** → Select "No" (if not on Play Store yet)
4. **App name:** `Memory Match - Brain Training`
5. Click **"Add"**
6. **Copy your App ID:** `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`

### Step 3: Create Ad Units

For each ad type, create an ad unit:

#### A. Rewarded Video Ad

1. Click your app → **"Ad units"** → **"Add ad unit"**
2. Select **"Rewarded"**
3. **Ad unit name:** `Rewarded Video - Coins`
4. Click **"Create ad unit"**
5. **Copy the Ad unit ID:** `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`

#### B. Interstitial Ad

1. Click **"Add ad unit"** → **"Interstitial"**
2. **Ad unit name:** `Interstitial - Between Levels`
3. Click **"Create ad unit"**
4. **Copy the Ad unit ID**

#### C. Banner Ad

1. Click **"Add ad unit"** → **"Banner"**
2. **Ad unit name:** `Banner - Shop`
3. Click **"Create ad unit"**
4. **Copy the Ad unit ID**

### Step 4: Update Your App

**File:** `lib/config/ad_config.dart`

Replace the test IDs with your real IDs:

```dart
class AdConfig {
  // Replace with YOUR App ID
  static const String androidAppId = 'ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY';
  
  // Replace with YOUR Ad Unit IDs
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/REWARDED_ID'; // Your rewarded ID
    }
    ...
  }
  
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/INTERSTITIAL_ID'; // Your interstitial ID
    }
    ...
  }
  
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/BANNER_ID'; // Your banner ID
    }
    ...
  }
}
```

**File:** `android/app/src/main/AndroidManifest.xml`

Replace the App ID:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

### Step 5: Rebuild App

```bash
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

### Step 6: Test with Real Ads

1. Install APK on your device
2. Play the game
3. Ads should show (but you won't earn money yet)

### Step 7: Wait for AdMob Approval

1. AdMob will review your app (1-7 days)
2. You'll receive an email when approved
3. **After approval:** Ads start generating revenue! 💰

---

## 💰 Revenue Expectations

### Typical Earnings (US/EU):

| Ad Type | Revenue per View | Notes |
|---------|-----------------|-------|
| **Rewarded Video** | $0.01 - $0.05 | Best revenue, user chooses |
| **Interstitial** | $0.005 - $0.02 | Good revenue, can annoy users |
| **Banner** | $0.0001 - $0.001 | Low revenue, passive income |

### Example Monthly Revenue:

**100 Daily Active Users:**
- Rewarded: 50 views/day × $0.02 = **$1/day**
- Interstitial: 100 views/day × $0.01 = **$1/day**
- Banner: 1000 impressions/day × $0.0005 = **$0.50/day**
- **Total: ~$75/month**

**1,000 Daily Active Users:**
- **Total: ~$750/month**

**10,000 Daily Active Users:**
- **Total: ~$7,500/month** 💰💰

---

## 🎯 Ad Placements (Current Implementation)

### 1. Rewarded Video Ad - Shop Screen

**What it does:**
- Prominent card at top of shop
- User taps "WATCH AD" button
- Watches 30-second video
- Earns 100 coins

**Why it's effective:**
- User **chooses** to watch
- Clear value proposition
- No annoyance factor
- Best revenue/user satisfaction ratio

**Frequency limit:**
- 10 ads per day max (prevents abuse)
- Counter shows remaining ads

### 2. Interstitial Ad - After Level Complete

**What it does:**
- Shows after **every 3rd level**
- Full-screen ad (usually 5-30 seconds)
- Can be skipped after 5 seconds
- **Not shown** if user bought "Remove Ads"

**Why it's effective:**
- Natural break in gameplay
- Good revenue per impression
- Frequency control prevents annoyance

**Smart triggers:**
- Minimum 2 minutes between ads (even if 3 levels completed)
- Only shows if ad is pre-loaded (no delays)

### 3. Banner Ads - Shop & Level Select

**What it does:**
- Small banner at bottom of screen
- 320x50 pixels
- Static or animated
- Always visible (unless "Remove Ads")

**Why it's effective:**
- Passive income
- Doesn't interrupt gameplay
- Low user friction

---

## ⚙️ Customization Options

All settings in `lib/config/ad_config.dart`:

```dart
class AdConfig {
  // Coins rewarded for watching ad
  static const int rewardedAdCoins = 100;
  
  // Show interstitial every N levels
  static const int interstitialAdFrequency = 3;
  
  // Minimum seconds between interstitial ads
  static const int interstitialAdCooldown = 120;
  
  // Max rewarded ads per day
  static const int maxRewardedAdsPerDay = 10;
}
```

### Recommended Adjustments:

**For faster monetization:**
```dart
interstitialAdFrequency = 2;  // Every 2 levels
rewardedAdCoins = 75;          // Lower reward, more ads needed
maxRewardedAdsPerDay = 15;     // Allow more views
```

**For better user experience:**
```dart
interstitialAdFrequency = 5;  // Every 5 levels
rewardedAdCoins = 150;         // Higher reward, fewer ads needed
maxRewardedAdsPerDay = 5;      // Fewer views allowed
```

---

## 🚨 Important Rules & Compliance

### AdMob Policies:

❌ **DON'T:**
- Click your own ads (instant ban)
- Tell users to click ads
- Place ads over game content
- Force users to watch ads to play
- Show ads with inappropriate content

✅ **DO:**
- Make rewarded ads optional
- Give users value for watching
- Space out interstitial ads
- Respect "Remove Ads" purchases
- Follow Google's policies

### App Requirements:

Before AdMob approves:

- [ ] App must be on Google Play (any track)
- [ ] Privacy policy published (can be on GitHub)
- [ ] App must be high quality (no crashes)
- [ ] No policy violations (violence, adult content, etc.)
- [ ] Ads must be appropriate for all ages

---

## 🐛 Troubleshooting

### "Ad failed to load"

**Common causes:**
1. **Internet connection** - Check device is online
2. **AdMob not approved yet** - Test ads work, real ads don't
3. **Invalid ad unit ID** - Double-check IDs match AdMob
4. **App not on Play Store** - Required for real ads
5. **Fill rate** - Not all ad requests have ads available

**Solution:**
- Use test IDs during development
- Check AdMob account status
- Wait for approval (1-7 days)

### "No ads showing"

**Check:**
1. Is `AdService.instance.initialize()` called in main.dart? ✅
2. Is `com.google.android.gms.ads.APPLICATION_ID` in AndroidManifest.xml? ✅
3. Is google_mobile_ads package installed? ✅
4. Are you using test ad unit IDs? (should work immediately)
5. Check logs for errors: `flutter run` and watch for AdMob messages

### "Ads show but no revenue"

**Causes:**
1. **Using test ad IDs** - No revenue with test IDs
2. **Not approved yet** - AdMob needs to approve your account
3. **Low impressions** - Need time to accumulate earnings
4. **Payment threshold** - Need $100 to get paid

---

## 💡 Pro Tips

### 1. **Optimize Rewarded Ad Value**

Test different coin amounts:
- Too high (500): Users never buy coins
- Too low (25): Not worth watching ad
- **Sweet spot: 75-150 coins**

### 2. **Balance Interstitial Frequency**

- Too frequent (every level): Users uninstall
- Too rare (every 10 levels): Low revenue
- **Sweet spot: Every 3-5 levels**

### 3. **Pre-load Ads**

Already implemented! Ads load in background so they're instant when needed.

### 4. **Track Analytics**

Monitor in Firebase Analytics:
- `ad_impression` - How many ads shown
- `ad_click` - How many ads clicked
- `ad_rewarded` - How many rewards given

### 5. **A/B Test**

Try different placements and values:
- Week 1: 100 coins per ad, every 3 levels
- Week 2: 150 coins per ad, every 4 levels
- Compare revenue and retention

---

## 📊 AdMob Dashboard Guide

After approval, monitor your earnings:

### Key Metrics:

**Overview:**
- **Estimated earnings** - How much you've made
- **Impressions** - How many ads shown
- **Match rate** - % of ad requests filled
- **eCPM** - Earnings per 1000 impressions

**Performance:**
- **Click-through rate (CTR)** - % of ads clicked
- **Fill rate** - % of requests with ads
- **Revenue by format** - Which ad type earns most

### Typical Performance:

| Metric | Good | Average | Poor |
|--------|------|---------|------|
| Match Rate | >80% | 60-80% | <60% |
| eCPM | >$5 | $1-5 | <$1 |
| CTR (banner) | >2% | 0.5-2% | <0.5% |
| Fill Rate | >90% | 70-90% | <70% |

---

## 🎓 Next Steps

### Current State: TEST MODE ✅
You can:
- Test all ad types
- See how they look
- Verify placements
- Test user flow

### To Go Live:

1. **Week 1:** Test thoroughly with current setup
2. **Week 2:** Create AdMob account & ad units
3. **Week 3:** Upload to Google Play (internal testing)
4. **Week 4:** Replace test IDs with real IDs
5. **Week 4-5:** Wait for AdMob approval
6. **Week 5+:** Start earning! 💰

---

## 📞 Support & Resources

- [AdMob Help Center](https://support.google.com/admob)
- [AdMob Policies](https://support.google.com/admob/answer/6128543)
- [Google Mobile Ads Flutter](https://developers.google.com/admob/flutter/quick-start)
- [AdMob Community](https://support.google.com/admob/community)

---

## ✅ Quick Reference

**Test the ads now:**
1. ✅ Run the app: `flutter run`
2. ✅ Go to Shop → See rewarded ad card
3. ✅ Tap "WATCH AD" → Ad plays → Earn coins
4. ✅ Complete 3 levels → Interstitial ad shows
5. ✅ Check shop/level select → Banner ads at bottom

**When ready to monetize:**
1. Create AdMob account
2. Create app & ad units
3. Replace IDs in `ad_config.dart`
4. Update `AndroidManifest.xml`
5. Rebuild: `flutter build apk --release`
6. Upload to Play Store
7. Wait for approval
8. 💰 Start earning!

---

**🎉 Ads are ready to test! Install the app and try watching an ad in the shop!**

