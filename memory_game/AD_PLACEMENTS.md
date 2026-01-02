# 🎯 AdMob Ad Placements - Memory Match Brain Training

## Overview
This document details all ad placements in the app, following AdMob guidelines for optimal user experience and revenue.

---

## 📱 **Ad Types Used**

### 1. **Banner Ads** (320x50 adaptive)
- Non-intrusive
- Placed at bottom of screens
- Does not interfere with gameplay
- Auto-refreshes according to AdMob policy

### 2. **Interstitial Ads** (Full-screen)
- Shown at natural break points
- Frequency-limited and cooldown-based
- Never interrupts active gameplay

### 3. **Rewarded Video Ads**
- User-initiated only
- Provides tangible rewards
- Daily limit enforced

---

## 🗺️ **Complete Ad Placement Map**

### **1. Home Screen (Menu)**
📍 **Location**: `lib/presentation/screens/menu/menu_screen.dart`

**Ad Type**: Banner Ad (Adaptive, bottom)

**When Shown**:
- Immediately when home screen loads
- Persistent while on home screen

**User Flow**:
```
App Launch → Home Screen → Banner appears at bottom
```

**Guidelines Compliance**:
- ✅ Not blocking navigation
- ✅ Clear separation from content
- ✅ Above the fold visibility

---

### **2. Level Select Screen**
📍 **Location**: `lib/presentation/screens/level_select/level_select_screen.dart`

**Ad Type**: Banner Ad (Adaptive, bottom)

**When Shown**:
- When browsing levels
- Below the scrollable level grid

**User Flow**:
```
Home → Play → Level Select → Banner at bottom
```

**Guidelines Compliance**:
- ✅ Below scrollable content
- ✅ Doesn't obstruct level selection
- ✅ Natural placement

---

### **3. Shop Screen (Power-ups)**
📍 **Location**: `lib/presentation/screens/shop/shop_screen.dart`

**Ad Types**:
1. **Rewarded Video Ad Card** (top, conditional)
   - Only shown when ad is loaded and ready
   - User can tap to watch ad for 100 coins
   - Daily limit: 10 ads/day

2. **Banner Ad** (bottom)
   - Below power-up purchase list
   - Persistent while browsing shop

**When Shown**:
```
Home → Power-ups → Rewarded Ad Card (if ready) + Banner at bottom
```

**Reward System**:
- Watch ad = 100 coins
- Daily limit enforced
- Card disappears when limit reached

**Guidelines Compliance**:
- ✅ Rewarded ads are user-initiated
- ✅ Clear value proposition (100 coins)
- ✅ Daily limits prevent spam
- ✅ Banner doesn't block purchases

---

### **4. Between Levels (Interstitial)**
📍 **Location**: `lib/domain/services/ad_service.dart` → `onLevelComplete()`

**Ad Type**: Interstitial Ad (Full-screen)

**Frequency**:
- Every **3 levels** completed
- **2-minute cooldown** between ads
- Never shown during active gameplay

**Trigger Points**:
```
Level 3 Complete → Ad
Level 6 Complete → Ad (if 2 min passed)
Level 9 Complete → Ad (if 2 min passed)
...and so on
```

**User Flow**:
```
Game Complete → Result Dialog → Close Dialog → Interstitial Ad → Next Level
```

**Guidelines Compliance**:
- ✅ Natural break point (after level completion)
- ✅ Frequency limited (every 3 levels)
- ✅ Time-based cooldown (2 minutes)
- ✅ Never interrupts gameplay
- ✅ Skippable after 5 seconds (AdMob default)

---

### **5. Game Continuation (Rewarded Video)**
📍 **Location**: `lib/presentation/screens/game/game_screen.dart` → Result Dialog

**Ad Type**: Rewarded Video

**When Shown**:
- When level fails
- User can watch ad to get +30 seconds and continue

**User Flow**:
```
Level Failed → Result Dialog → "Watch Ad for +30s" button → Ad → Continue playing
```

**Reward**:
- +30 seconds added to timer
- Game continues from current state
- Can only be used once per level

**Guidelines Compliance**:
- ✅ 100% user-initiated
- ✅ Clear value (extra time)
- ✅ Optional - user can choose to restart instead
- ✅ One-time use per level

---

### **6. Themes Screen**
📍 **Location**: `lib/presentation/screens/themes/themes_screen.dart`

**Ad Type**: Banner Ad (Adaptive, bottom)

**When Shown**:
- While browsing/purchasing themes
- Below theme grid

**User Flow**:
```
Home → Themes → Banner at bottom
```

**Guidelines Compliance**:
- ✅ Below scrollable content
- ✅ Doesn't interfere with theme selection
- ✅ Natural placement

---

## 📊 **Ad Frequency Summary**

| Ad Type | Location | Frequency | Cooldown | User-Initiated |
|---------|----------|-----------|----------|----------------|
| **Banner** | Home Screen | Always | N/A | No |
| **Banner** | Level Select | Always | N/A | No |
| **Banner** | Shop | Always | N/A | No |
| **Banner** | Themes | Always | N/A | No |
| **Interstitial** | Between Levels | Every 3 levels | 2 minutes | No |
| **Rewarded** | Shop (coins) | User clicks | 10/day limit | **Yes** |
| **Rewarded** | Game Continue | Level failure | 1/level | **Yes** |

---

## 🎯 **AdMob Guidelines Compliance**

### ✅ **Best Practices Followed**

1. **Natural Placements**
   - Ads at natural break points
   - No interruption during active gameplay
   - Clear visual separation from content

2. **Frequency Control**
   - Interstitial ads limited to every 3 levels
   - 2-minute cooldown between interstitials
   - Rewarded ads limited to 10/day

3. **User Experience**
   - Banner ads don't block navigation
   - Interstitials only between levels
   - Rewarded ads provide clear value

4. **Accidental Clicks Prevention**
   - Banners have clear spacing
   - Buttons not placed near ads
   - Proper margins and padding

5. **Rewarded Ad Best Practices**
   - User must initiate
   - Clear reward communication
   - Reward delivered immediately
   - Daily limits enforced

---

## 🔧 **Configuration**

### Current Settings (Test Mode)
```dart
// lib/config/ad_config.dart

Interstitial Frequency: 3 levels
Interstitial Cooldown: 120 seconds
Rewarded Ad Reward: 100 coins
Rewarded Ad Daily Limit: 10
Continue Ad Bonus: +30 seconds
```

### Test Ad IDs (Active)
```
Banner: ca-app-pub-3940256099942544/6300978111
Interstitial: ca-app-pub-3940256099942544/1033173712
Rewarded: ca-app-pub-3940256099942544/5224354917
```

---

## 🚀 **Revenue Optimization**

### High-Value Placements
1. ⭐ **Shop Screen** - Dual placement (rewarded + banner)
2. ⭐ **Between Levels** - Interstitial at peak engagement
3. ⭐ **Home Screen** - First impression, high visibility

### User Retention Balance
- Ads don't frustrate users
- Rewarded ads provide value
- Frequency limits prevent ad fatigue
- Natural placements maintain flow

---

## 📈 **Expected Ad Impressions**

### Per User Session (30 minutes, 10 levels)
- **Banner Ads**: 4-6 impressions (home, levels, shop, themes)
- **Interstitial Ads**: 3 impressions (every 3 levels)
- **Rewarded Ads**: 0-2 impressions (user choice)

**Total**: ~9 ad opportunities per session

### Ad Load Distribution
```
Banner Ads: 50% of impressions
Interstitial Ads: 40% of impressions
Rewarded Ads: 10% of impressions (user-initiated)
```

---

## 🎮 **How to Test Each Placement**

### 1. **Home Screen Banner**
```
Launch app → Home screen → Banner at bottom
```

### 2. **Level Select Banner**
```
Home → Play → See banner below level grid
```

### 3. **Shop Rewarded + Banner**
```
Home → Power-ups → "Watch Ad for Coins" card + banner at bottom
```

### 4. **Between Levels Interstitial**
```
Play 3 levels → Complete level 3 → See interstitial
```

### 5. **Game Continue Rewarded**
```
Fail a level → See "Watch ad for +30s" button → Click it
```

### 6. **Themes Banner**
```
Home → Themes → See banner at bottom
```

---

## 🔄 **Future Enhancements**

1. **Native Ads** - In level list (between level cards)
2. **App Open Ads** - When returning from background (optional)
3. **Rewarded Interstitial** - Combination format for better eCPM

---

## 📝 **Notes for Production**

**Before Launch:**
1. Replace test ad IDs with production IDs in `lib/config/ad_config.dart`
2. Update `AndroidManifest.xml` with production AdMob app ID
3. Update `Info.plist` for iOS with production AdMob app ID
4. Test on real devices for 24-48 hours
5. Monitor AdMob console for policy violations
6. Adjust frequency based on user feedback

**AdMob Account Setup Required:**
1. Create app in AdMob console
2. Generate ad units (Banner, Interstitial, Rewarded)
3. Enable mediation (optional)
4. Set up app-ads.txt
5. Configure payment settings

---

## ✅ **Checklist**

- [x] Banner ads implemented
- [x] Interstitial ads implemented
- [x] Rewarded ads implemented
- [x] Frequency limits enforced
- [x] Cooldowns implemented
- [x] User-initiated rewards
- [x] Natural placements
- [x] Test ads working
- [ ] Production ads configured (pending AdMob setup)
- [ ] Revenue tracking enabled (pending production)

---

**Last Updated**: December 2025  
**AdMob SDK Version**: google_mobile_ads ^5.3.1  
**Status**: Test Mode (Ready for production deployment)

