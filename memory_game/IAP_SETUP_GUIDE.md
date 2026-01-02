# 💰 In-App Purchase Setup Guide - Android

Complete step-by-step guide to set up in-app purchases for the Memory Match game on Android.

## 🌍 Automatic Localization

**Important**: The app automatically fetches **localized prices, names, and descriptions** from Google Play Console based on the user's device locale!

- **Prices**: Automatically displayed in the user's local currency (e.g., $4.99 USD, €4.99 EUR, £4.99 GBP)
- **Names**: Product names are shown in the user's language (if you've set up translations in Play Console)
- **Descriptions**: Product descriptions are shown in the user's language (if you've set up translations in Play Console)

The app prioritizes store data over config fallbacks, so users always see the correct localized information.

---

## 📋 Prerequisites

- Google Play Console account
- App published in Google Play Console (at least in Internal Testing or Closed Testing)
- App signed with release keystore
- Access to your app's package name (e.g., `com.aexyn.memorygame`)

---

## 🚀 Step 1: Create Products in Google Play Console

### 1.1 Access In-App Products

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Navigate to **Monetize** → **Products** → **In-app products**
4. Click **Create product**

### 1.2 Create Each Product

Create the following products with **exact** product IDs:

#### **Remove Ads (Non-Consumable)**
- **Product ID**: `remove_ads`
- **Type**: Non-consumable
- **Price**: Set your price (e.g., $4.99)
- **Status**: Active
- **Description**: "Remove all ads permanently and enjoy an ad-free experience!"

#### **Coin Packs (Consumable)**

**Small Pack:**
- **Product ID**: `coins_small`
- **Type**: Consumable
- **Price**: $0.99
- **Description**: "500 Coins"

**Medium Pack:**
- **Product ID**: `coins_medium`
- **Type**: Consumable
- **Price**: $2.99
- **Description**: "1,500 Coins + 200 Bonus"

**Large Pack:**
- **Product ID**: `coins_large`
- **Type**: Consumable
- **Price**: $9.99
- **Description**: "5,000 Coins + 1,000 Bonus"

**Extra Large Pack:**
- **Product ID**: `coins_extra_large`
- **Type**: Consumable
- **Price**: $19.99
- **Description**: "10,000 Coins + 2,500 Bonus"

#### **Gem Packs (Consumable)**

**Small Pack:**
- **Product ID**: `gems_small`
- **Type**: Consumable
- **Price**: $1.99
- **Description**: "20 Gems"

**Medium Pack:**
- **Product ID**: `gems_medium`
- **Type**: Consumable
- **Price**: $4.99
- **Description**: "60 Gems + 10 Bonus"

**Large Pack:**
- **Product ID**: `gems_large`
- **Type**: Consumable
- **Price**: $9.99
- **Description**: "150 Gems + 30 Bonus"

#### **Starter Pack (Consumable)**
- **Product ID**: `starter_pack`
- **Type**: Consumable
- **Price**: $2.99
- **Description**: "Starter Pack: 1,000 Coins + 20 Gems"

### 1.3 Verify Product IDs Match

**⚠️ CRITICAL**: The product IDs in Google Play Console **MUST** exactly match the IDs in:
- `lib/config/iap_config.dart`

Current product IDs in code:
```dart
removeAds = 'remove_ads'
coinsSmall = 'coins_small'
coinsMedium = 'coins_medium'
coinsLarge = 'coins_large'
coinsExtraLarge = 'coins_extra_large'
gemsSmall = 'gems_small'
gemsMedium = 'gems_medium'
gemsLarge = 'gems_large'
starterPack = 'starter_pack'
```

---

## 🧪 Step 2: Set Up License Testing

### 2.1 Add Test Accounts

1. In Google Play Console, go to **Settings** → **License testing**
2. Add your test email addresses (Gmail accounts)
3. Set **License response** to **RESPOND_NORMALLY**
4. Click **Save**

### 2.2 Test Accounts Requirements

- Must be Gmail accounts
- Must be added to license testing list
- Will receive test purchases (no real charges)
- Can test all purchase flows

---

## 📱 Step 3: Build and Test

### 3.1 Build Release APK/AAB

```bash
cd memory_game
flutter build appbundle --release
# OR for APK:
flutter build apk --release
```

### 3.2 Install on Test Device

1. Install the release build on your test device
2. **Important**: Use a device with a Google account that's in your license testing list
3. The device must have Google Play Services installed

### 3.3 Test Purchase Flow

1. Open the app
2. Navigate to **Shop** → **Store** tab
3. Try purchasing each product:
   - Remove Ads (should work once, then show as purchased)
   - Coin packs (can purchase multiple times)
   - Gem packs (can purchase multiple times)
   - Starter pack (can purchase multiple times)

### 3.4 Verify Remove Ads Works

After purchasing "Remove Ads":
1. ✅ No banner ads should appear on any screen
2. ✅ No interstitial ads should show between levels
3. ✅ Rewarded ad card should not appear in shop
4. ✅ Check these screens:
   - Menu/Home screen
   - Level Select screen
   - Shop screen
   - Themes screen
   - Achievements screen
   - Daily Rewards screen

---

## 🔍 Step 4: Verify Integration

### 4.1 Check IAP Service Initialization

The IAP service is initialized in `lib/app.dart`:
```dart
await IAPService.instance.initialize();
if (IAPService.instance.adsRemoved) {
  AdService.instance.setAdsRemoved(true);
}
```

### 4.2 Verify Ad Checks

All ad displays check `AdService.instance.adsRemoved`:

✅ **Banner Ads** (checked in):
- `menu_screen.dart` - Line 426
- `level_select_screen.dart` - Line 239
- `shop_screen.dart` - Line 137
- `themes_screen.dart` - Line 157
- `achievements_screen.dart` - Line 132
- `daily_rewards_screen.dart` - Line 113

✅ **Interstitial Ads** (checked in):
- `ad_service.dart` - Line 461: `if (_adsRemoved || _interstitialAd == null) return false;`
- `ad_service.dart` - Line 392: Won't load if `_adsRemoved` is true

✅ **Rewarded Ads** (checked in):
- `shop_screen.dart` - Line 162: `!adService.adsRemoved && adService.isRewardedAdReady()`

### 4.3 Test Purchase Restoration

1. Uninstall and reinstall the app
2. Open the app
3. Go to Shop → Store tab
4. Tap **Restore Purchases**
5. Verify "Remove Ads" is restored (no ads should show)

---

## 🐛 Troubleshooting

### Issue: "Product not found" error

**Solution:**
1. Verify product IDs match exactly (case-sensitive)
2. Ensure products are **Active** in Google Play Console
3. Wait 2-4 hours after creating products (Google needs time to propagate)
4. Make sure you're using a **release build** (not debug)

### Issue: "Purchase failed" or "Billing unavailable"

**Solution:**
1. Verify Google Play Services is installed and updated
2. Check internet connection
3. Ensure device has a Google account signed in
4. Verify the account is in license testing list
5. Try clearing Google Play Store cache

### Issue: Ads still showing after purchasing "Remove Ads"

**Solution:**
1. Check logs for: `✅ Ads removed flag saved and AdService updated`
2. Verify `IAPService.instance.adsRemoved` returns `true`
3. Verify `AdService.instance.adsRemoved` returns `true`
4. Restart the app (ads are checked on initialization)
5. Check SharedPreferences key: `iap_ads_removed` should be `true`

### Issue: Products not loading

**Solution:**
1. Wait 2-4 hours after creating products
2. Use release build (debug builds may have issues)
3. Check internet connection
4. Verify app is signed with release keystore
5. Check logs for product loading errors

### Issue: "This version of the application is not configured for billing"

**Solution:**
1. Ensure app is published in at least **Internal Testing** track
2. Add your test account to the testing track
3. Wait for the app to be available in Play Store for your account
4. Install from Play Store (not direct APK) for first test

---

## ✅ Verification Checklist

Before going live, verify:

- [ ] All products created in Google Play Console
- [ ] Product IDs match exactly with `iap_config.dart`
- [ ] All products are **Active**
- [ ] License testing accounts added
- [ ] Release build tested on device
- [ ] Remove Ads purchase works
- [ ] No ads show after Remove Ads purchase
- [ ] Coin packs grant correct amounts
- [ ] Gem packs grant correct amounts
- [ ] Starter pack grants correct amounts
- [ ] Purchase restoration works
- [ ] Error handling works (cancel, network errors)
- [ ] Loading states work correctly
- [ ] Success messages appear
- [ ] All screens respect ads removed flag

---

## 🌍 Automatic Localization

**Important**: The app automatically fetches **localized prices, names, and descriptions** from Google Play Console based on the user's device locale!

### How It Works:

1. **Prices**: 
   - Google Play automatically converts your base price to the user's local currency
   - Example: If you set $4.99 USD, users in Europe see €4.99, UK users see £4.99
   - The app displays the price exactly as provided by Google Play (already formatted)

2. **Names & Descriptions**:
   - If you add translations in Google Play Console, users see products in their language
   - If no translation exists, users see the default language you set
   - The app always prioritizes store data over config fallbacks

3. **Priority Order**:
   - **First**: Use localized data from Google Play Console (price, title, description)
   - **Fallback**: Use config data only if store data isn't available

### Setting Up Translations (Optional):

1. In Google Play Console, go to your product
2. Click **Add translation** or **Manage translations**
3. Add translations for each language you support
4. The app will automatically display the correct language based on device locale

**Note**: Prices are automatically localized - no translation needed! Just set your base price and Google Play handles currency conversion.

---

## 📝 Code Locations Reference

### IAP Configuration
- **File**: `lib/config/iap_config.dart`
- **Purpose**: Product IDs and metadata

### IAP Service
- **File**: `lib/domain/services/iap_service.dart`
- **Purpose**: Purchase handling, restoration, integration

### Shop Screen
- **File**: `lib/presentation/screens/shop/shop_screen.dart`
- **Purpose**: UI for purchasing products

### Ad Service Integration
- **File**: `lib/domain/services/ad_service.dart`
- **Purpose**: Ad display logic (respects `adsRemoved` flag)

### App Initialization
- **File**: `lib/app.dart`
- **Purpose**: IAP service initialization and sync with AdService

---

## 🎯 Next Steps After Testing

1. **Update Product Prices** (if needed):
   - Edit prices in Google Play Console
   - Update fallback prices in `iap_config.dart` (optional, for display)

2. **Remove Test Accounts** (before production):
   - Remove test accounts from license testing
   - Or set license response to production mode

3. **Monitor Purchases**:
   - Check Google Play Console → Monetize → Products → In-app products
   - Monitor purchase analytics

4. **Handle Refunds** (if needed):
   - Google Play Console → Order management
   - Handle refunds and revoke access if needed

---

## 📞 Support

If you encounter issues:

1. Check logs for IAP-related messages (look for `🛒`, `✅`, `❌` emojis)
2. Verify product IDs match exactly
3. Ensure release build is used
4. Check Google Play Console for product status
5. Test with license testing accounts first

---

## 🎉 You're All Set!

Once all products are created and tested, your in-app purchases are ready for production!

**Remember:**
- Product IDs are case-sensitive
- Products take 2-4 hours to propagate
- Always test with release builds
- Remove Ads works across all screens automatically

