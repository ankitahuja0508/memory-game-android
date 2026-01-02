# 🔄 How Consumable Products Work

Explanation of how consumable vs non-consumable products are handled in the app.

---

## 📱 Google Play Console

**Important**: In Google Play Console, all products are created as **"One-time products"**. There is no separate "Consumable" vs "Non-consumable" option in the UI.

**What you do:**
1. Go to **Monetize → Products → One-time products**
2. Create all products the same way (no type selection)
3. The app code determines if a product is consumable

---

## 💻 App Code Implementation

The app determines consumability by using different purchase methods:

### Consumable Products (Coins, Gems, Starter Pack)

**Method**: `buyConsumable()`

**What happens:**
1. User purchases product (e.g., `coins_small`)
2. App calls `buyConsumable()` 
3. Purchase is granted
4. **Package automatically consumes the purchase** after granting rewards
5. Product can be purchased again

**Products that use this:**
- `coins_small`, `coins_medium`, `coins_large`, `coins_extra_large`
- `gems_small`, `gems_medium`, `gems_large`
- `starter_pack`

### Non-Consumable Products (Remove Ads)

**Method**: `buyNonConsumable()`

**What happens:**
1. User purchases product (`remove_ads`)
2. App calls `buyNonConsumable()`
3. Purchase is granted
4. App calls `completePurchase()` to acknowledge
5. **Purchase is NOT consumed** - it remains owned
6. Product cannot be purchased again (app checks if already owned)

**Products that use this:**
- `remove_ads`

---

## 🔍 Code Location

**File**: `lib/domain/services/iap_service.dart`

**Purchase Method Selection** (lines 159-180):
```dart
if (IAPConfig.isRemoveAds(productId)) {
  // Non-consumable: Remove Ads
  await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
} else {
  // Consumable: Coins, gems, starter pack
  await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
}
```

**Purchase Handling** (lines 232-262):
- For consumable products: Package automatically handles consumption
- For non-consumable products: App calls `completePurchase()` to acknowledge

---

## ✅ Summary

| Aspect | Consumable | Non-Consumable |
|--------|-----------|----------------|
| **Play Console** | Created as "One-time product" | Created as "One-time product" |
| **App Method** | `buyConsumable()` | `buyNonConsumable()` |
| **Consumption** | Automatic (by package) | Not consumed (acknowledged only) |
| **Can Purchase Again** | ✅ Yes | ❌ No (checked in app) |
| **Examples** | Coins, gems, starter pack | Remove ads |

---

## 🎯 Key Points

1. **Play Console**: All products are "One-time products" - no distinction
2. **App Code**: Determines consumability via `buyConsumable()` vs `buyNonConsumable()`
3. **Consumption**: Handled automatically by the `in_app_purchase` package for consumables
4. **Acknowledgment**: Non-consumables are acknowledged with `completePurchase()` but not consumed

---

**The implementation is correct and follows Google Play's current requirements!** ✅

