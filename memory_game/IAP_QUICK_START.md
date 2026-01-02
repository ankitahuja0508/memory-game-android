# 🚀 IAP Quick Start Guide

Quick reference for setting up in-app purchases on Android.

---

## ⚡ Quick Setup (5 Steps)

### 1. Create Products in Google Play Console

**How to create:**
1. Go to: **Monetize → Products → One-time products**
2. Click **"+ Create product"** or **"Create one-time product"**
3. Select **"Consumable"** (or **"Non-consumable"** for Remove Ads)
4. Fill in Product ID, Name, Description, Price
5. Set Status to **"Active"**
6. Click **"Save"**

**📖 Detailed guide**: See `PLAY_CONSOLE_CREATE_PRODUCTS.md` for step-by-step instructions.

Create these products with **exact** IDs:

| Product ID | Type | Price |
|------------|------|-------|
| `remove_ads` | Non-consumable | $4.99 |
| `coins_small` | Consumable | $0.99 |
| `coins_medium` | Consumable | $2.99 |
| `coins_large` | Consumable | $9.99 |
| `coins_extra_large` | Consumable | $19.99 |
| `gems_small` | Consumable | $1.99 |
| `gems_medium` | Consumable | $4.99 |
| `gems_large` | Consumable | $9.99 |
| `starter_pack` | Consumable | $2.99 |

**⚠️ Product IDs must match exactly (case-sensitive)!**

### 2. Set Up License Testing

Go to: **Settings → License testing**

- Add your test Gmail accounts
- Set License response to **RESPOND_NORMALLY**
- Save

### 3. Build Release Version

```bash
cd memory_game
flutter build appbundle --release
```

### 4. Install on Test Device

- Install the release build
- Use a device with Google account from license testing list
- Device must have Google Play Services

### 5. Test Purchases

1. Open app → Shop → Store tab
2. Try purchasing "Remove Ads"
3. Verify no ads appear anywhere
4. Test coin/gem packs
5. Test "Restore Purchases"

---

## ✅ Verify Remove Ads Works

After purchasing "Remove Ads", check these screens:

- [ ] Menu/Home - No banner ad
- [ ] Level Select - No banner ad  
- [ ] Shop - No banner ad, no rewarded ad card
- [ ] Themes - No banner ad
- [ ] Achievements - No banner ad
- [ ] Daily Rewards - No banner ad
- [ ] Complete 3+ levels - No interstitial ad

---

## 🐛 Common Issues

**"Product not found"**
- Wait 2-4 hours after creating products
- Verify product IDs match exactly
- Use release build (not debug)

**"Purchase failed"**
- Check Google Play Services is installed
- Verify test account is in license testing
- Check internet connection

**Ads still showing**
- Restart the app
- Check logs for "✅ Ads removed flag saved"
- Verify purchase completed successfully

---

## 📝 Product IDs Reference

All product IDs are in: `lib/config/iap_config.dart`

If you need to change product IDs:
1. Update `iap_config.dart`
2. Create matching products in Google Play Console
3. Rebuild and test

---

## 📚 Full Documentation

- **Setup Guide**: `IAP_SETUP_GUIDE.md` (detailed steps)
- **Verification**: `IAP_VERIFICATION.md` (code verification)

---

**Ready to go!** 🎉

