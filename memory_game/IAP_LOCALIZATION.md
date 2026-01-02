# 🌍 IAP Localization Guide

This document explains how pricing, names, and descriptions are automatically localized in the app.

---

## ✅ Automatic Localization

The app **automatically** fetches and displays localized content from Google Play Console based on the user's device locale. No additional code is needed!

---

## 💰 Price Localization

### How It Works:

1. **You set the base price** in Google Play Console (e.g., $4.99 USD)
2. **Google Play automatically converts** it to the user's local currency
3. **The app displays** the price exactly as provided by Google Play

### Examples:

| Your Base Price | User in USA | User in UK | User in Germany | User in Japan |
|----------------|-------------|------------|-----------------|---------------|
| $4.99 USD | $4.99 | £4.99 | €4.99 | ¥550 |

### Code Implementation:

```dart
// In shop_screen.dart - _IAPProductCard widget
String get _price {
  // Priority 1: Use localized price from Play Console
  if (productDetails != null && productDetails.price.isNotEmpty) {
    return productDetails.price; // Already localized!
  }
  // Fallback only if store unavailable
  // ...
}
```

**The `productDetails.price` is already formatted and localized by Google Play!**

---

## 📝 Name & Description Localization

### How It Works:

1. **You set default name/description** in Google Play Console (in your primary language)
2. **Optionally add translations** for other languages
3. **Google Play returns** the appropriate language based on user's device locale
4. **The app displays** the localized name/description

### Code Implementation:

```dart
// In shop_screen.dart - _IAPProductCard widget
String get _title {
  // Priority 1: Use localized name from Play Console
  if (productDetails != null && 
      productDetails.title != null && 
      productDetails.title!.isNotEmpty) {
    return productDetails.title!; // Already localized!
  }
  // Fallback only if store unavailable
  // ...
}

String get _description {
  // Priority 1: Use localized description from Play Console
  if (productDetails != null && 
      productDetails.description != null && 
      productDetails.description!.isNotEmpty) {
    return productDetails.description!; // Already localized!
  }
  // Fallback only if store unavailable
  // ...
}
```

---

## 🎯 Priority Order

The app uses this priority when displaying product information:

1. **First Priority**: Google Play Console data (localized)
   - Price: Automatically localized currency
   - Name: Localized if translations exist, otherwise default
   - Description: Localized if translations exist, otherwise default

2. **Fallback**: Config data (`iap_config.dart`)
   - Only used if store data isn't available
   - Prices in USD (fallback only)
   - Names/descriptions in English (fallback only)

---

## 🔧 Setting Up Translations in Google Play Console

### Step 1: Create Product with Default Language

1. Go to Google Play Console
2. Create your product with name/description in your primary language (e.g., English)

### Step 2: Add Translations (Optional)

1. Click on your product
2. Click **Add translation** or **Manage translations**
3. Select a language (e.g., Spanish, French, German)
4. Enter translated name and description
5. Save

### Step 3: Test

1. Change your device language
2. Open the app
3. Go to Shop → Store tab
4. Verify products show in the correct language

---

## 📊 What Gets Localized

| Field | Localization | How |
|-------|-------------|-----|
| **Price** | ✅ Automatic | Google Play converts currency based on user's country |
| **Name** | ✅ If translations exist | Google Play returns translated name based on device language |
| **Description** | ✅ If translations exist | Google Play returns translated description based on device language |

---

## ⚠️ Important Notes

1. **Prices are always localized** - Google Play handles currency conversion automatically
2. **Names/Descriptions** - Only localized if you add translations in Play Console
3. **Fallback values** - Config values are in USD/English, but only used if store unavailable
4. **No code changes needed** - Localization is handled automatically by the `in_app_purchase` package

---

## 🧪 Testing Localization

### Test Price Localization:

1. Change your device's region/country
2. Open the app
3. Go to Shop → Store tab
4. Verify prices show in the correct currency

### Test Name/Description Localization:

1. Add translations in Google Play Console
2. Change your device's language
3. Open the app
4. Go to Shop → Store tab
5. Verify names/descriptions show in the correct language

---

## 📝 Example: Multi-Language Setup

### In Google Play Console:

**Product**: `remove_ads`

**English (Default)**:
- Name: "Remove Ads"
- Description: "Remove all ads permanently..."

**Spanish (Translation)**:
- Name: "Eliminar Anuncios"
- Description: "Elimina todos los anuncios permanentemente..."

**French (Translation)**:
- Name: "Supprimer les Publicités"
- Description: "Supprimez toutes les publicités de façon permanente..."

### In the App:

- **English device**: Shows "Remove Ads" with English description
- **Spanish device**: Shows "Eliminar Anuncios" with Spanish description
- **French device**: Shows "Supprimer les Publicités" with French description
- **Price**: Automatically shows in local currency ($4.99, €4.99, etc.)

---

## ✅ Summary

- ✅ **Prices**: Automatically localized by Google Play (no setup needed)
- ✅ **Names**: Localized if translations added in Play Console
- ✅ **Descriptions**: Localized if translations added in Play Console
- ✅ **Fallback**: Config values used only if store unavailable
- ✅ **No code changes**: Everything handled automatically!

---

**The app is ready for international users!** 🌍

