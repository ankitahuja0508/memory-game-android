# 📝 IAP Product Names & Descriptions for Google Play Console

Use these exact names and descriptions when creating products in Google Play Console.

---

## 🚫 Remove Ads (Non-Consumable)

**Product ID**: `remove_ads`

**Name**: `Remove Ads`

**Description**: 
```
Remove all ads permanently and enjoy an uninterrupted, ad-free gaming experience. Support the developers and play without distractions!
```

**Price**: $4.99 (or your preferred price)

---

## 💰 Coin Packs (Consumable)

### Small Coin Pack

**Product ID**: `coins_small`

**Name**: `Small Coin Pack`

**Description**:
```
Get 500 coins to purchase power-ups and unlock new content. Perfect for getting started!
```

**Price**: $0.99

---

### Medium Coin Pack

**Product ID**: `coins_medium`

**Name**: `Medium Coin Pack`

**Description**:
```
Get 1,500 coins plus 200 bonus coins (1,700 total)! Great value for regular players.
```

**Price**: $2.99

---

### Large Coin Pack

**Product ID**: `coins_large`

**Name**: `Large Coin Pack`

**Description**:
```
Get 5,000 coins plus 1,000 bonus coins (6,000 total)! Stock up on power-ups and unlock everything.
```

**Price**: $9.99

---

### Extra Large Coin Pack

**Product ID**: `coins_extra_large`

**Name**: `Extra Large Coin Pack`

**Description**:
```
Get 10,000 coins plus 2,500 bonus coins (12,500 total)! The ultimate coin pack for serious players.
```

**Price**: $19.99

---

## 💎 Gem Packs (Consumable)

### Small Gem Pack

**Product ID**: `gems_small`

**Name**: `Small Gem Pack`

**Description**:
```
Get 20 premium gems to unlock exclusive themes and special power-ups. Premium currency for special items!
```

**Price**: $1.99

---

### Medium Gem Pack

**Product ID**: `gems_medium`

**Name**: `Medium Gem Pack`

**Description**:
```
Get 60 gems plus 10 bonus gems (70 total)! Unlock multiple themes and premium features.
```

**Price**: $4.99

---

### Large Gem Pack

**Product ID**: `gems_large`

**Name**: `Large Gem Pack`

**Description**:
```
Get 150 gems plus 30 bonus gems (180 total)! Unlock all themes and have gems to spare.
```

**Price**: $9.99

---

## 🎁 Starter Pack (Consumable)

**Product ID**: `starter_pack`

**Name**: `Starter Pack`

**Description**:
```
Perfect starter bundle! Get 1,000 coins and 20 gems to kickstart your memory training journey. Great value for new players!
```

**Price**: $2.99

---

## 📋 Quick Copy-Paste Table

| Product ID | Name | Type | Price |
|------------|------|------|-------|
| `remove_ads` | Remove Ads | Non-consumable | $4.99 |
| `coins_small` | Small Coin Pack | Consumable | $0.99 |
| `coins_medium` | Medium Coin Pack | Consumable | $2.99 |
| `coins_large` | Large Coin Pack | Consumable | $9.99 |
| `coins_extra_large` | Extra Large Coin Pack | Consumable | $19.99 |
| `gems_small` | Small Gem Pack | Consumable | $1.99 |
| `gems_medium` | Medium Gem Pack | Consumable | $4.99 |
| `gems_large` | Large Gem Pack | Consumable | $9.99 |
| `starter_pack` | Starter Pack | Consumable | $2.99 |

---

## ⚠️ Important Notes

1. **Product IDs must match exactly** (case-sensitive)
2. **Names and descriptions** can be customized, but the ones above are recommended
3. **Prices** can be adjusted to your preference
4. **Descriptions** should be clear and highlight the value proposition
5. These names and descriptions are also used as **fallbacks** in the app if product details aren't loaded from the store

---

## 🔄 How It Works

The app will:
1. **First try** to load product names/descriptions from Google Play Store
2. **Fallback** to the names/descriptions in `lib/config/iap_config.dart` if store data isn't available
3. This ensures products always display correctly, even if the store is temporarily unavailable

---

**Ready to use!** Copy the names and descriptions above when creating products in Google Play Console. 🎉

