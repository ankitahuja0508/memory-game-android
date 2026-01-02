# ⚡ Quick Guide: Create Consumable Product in Play Console

Based on the latest Google Play Console interface.

---

## 🎯 Quick Steps

1. **Navigate**: 
   - Go to **Monetize** → **Products** → **One-time products**

2. **Create**:
   - Click **"+ Create product"** or **"Create one-time product"**

3. **Important**: 
   - Google Play Console no longer has separate "Consumable" vs "Non-consumable" options
   - All products are created as **"One-time products"**
   - The app code determines consumability (coins/gems are consumable, remove ads is not)

4. **Fill Details**:
   - **Product ID**: `coins_small` (must match your code exactly)
   - **Name**: `Small Coin Pack`
   - **Description**: `Get 500 coins to purchase power-ups...`
   - **Price**: `$0.99 USD`
   - **Status**: `Active`

5. **Save**: Click **"Save"**

---

## 📍 Where to Find It

In the left sidebar, you'll see:
```
Monetize with Play
  └── Products
      ├── App pricing
      ├── One-time products  ← Click here!
      ├── Subscriptions
      └── Play Points
```

---

## ✅ That's It!

- Product will be created immediately
- Wait 2-4 hours for it to appear in your app
- Test with a release build

---

**Need more details?** See `PLAY_CONSOLE_CREATE_PRODUCTS.md` for the complete guide.

