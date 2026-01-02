# 📱 How to Create Consumable Products in Google Play Console (Latest)

Step-by-step guide to create consumable in-app products in the latest Google Play Console interface.

---

## 🚀 Step-by-Step Instructions

### Step 1: Access One-Time Products

1. Go to [Google Play Console](https://play.google.com/console)
2. Sign in with your developer account
3. **Select your app** from the dashboard
4. In the left sidebar, navigate to:
   - **Monetize** → **Products** → **One-time products**
   
   (You'll see this in the sidebar under "Monetize with Play" → "Products" section)

### Step 2: Create New Product

1. Click the **"+ Create product"** or **"Create one-time product"** button
2. You'll see a form to create a one-time product

### Step 3: Important Note About Product Types

**⚠️ Important**: Google Play Console no longer has separate "Consumable" vs "Non-consumable" options in the UI. All products are created as **"One-time products"**.

**The app code determines consumability:**
- Products purchased via `buyConsumable()` in the app are automatically consumed (coins, gems, starter pack)
- Products purchased via `buyNonConsumable()` in the app are acknowledged but not consumed (remove ads)

**For this step**: Just create the product - you don't need to select a type in the console.

### Step 5: Fill in Product Details

You'll now see a form with the following fields:

#### **Product ID** (Required)
- Enter your product ID (e.g., `coins_small`)
- **Important**: Must match exactly with your code (case-sensitive)
- Can only contain lowercase letters, numbers, and underscores
- Cannot be changed after creation

#### **Name** (Required)
- Enter the product name (e.g., "Small Coin Pack")
- This is what users will see in the store
- Can be translated later

#### **Description** (Required)
- Enter a description of the product
- This is what users will see in the store
- Can be translated later

#### **Default Price** (Required)
- Set the price for your product
- Select your base currency (usually USD)
- Google Play will automatically convert to other currencies

#### **Status**
- **Active** - Product is available for purchase
- **Inactive** - Product is not available (for testing or maintenance)

### Step 6: Save Product

1. Review all the information
2. Click **"Save"** or **"Create"** button
3. The product will be created and appear in your products list

---

## 📋 Example: Creating "coins_small" Product

Here's exactly what to enter for the Small Coin Pack:

```
Product ID: coins_small
Name: Small Coin Pack
Description: Get 500 coins to purchase power-ups and unlock new content. Perfect for getting started!
Default Price: $0.99 USD
Status: Active
```

---

## 🔄 Creating Multiple Products

After creating your first product:

1. Click **"+ Create product"** again
2. Repeat the process for each product
3. You can create all products at once or one at a time

**Recommended order:**
1. Create all consumable products first (coin packs, gem packs, starter pack)
2. Then create non-consumable products (remove ads)

---

## ⚙️ Product Settings After Creation

After creating a product, you can:

### Edit Product Details
- Click on the product name in the list
- Edit name, description, price, or status
- **Note**: Product ID cannot be changed

### Add Translations
1. Click on the product
2. Click **"Add translation"** or **"Manage translations"**
3. Select a language
4. Enter translated name and description
5. Save

### Set Up Pricing
- Prices are automatically converted to local currencies
- You can view pricing in different countries
- No additional setup needed for currency conversion

---

## ✅ Verification Checklist

After creating each product, verify:

- [ ] Product ID matches exactly with your code
- [ ] Name is clear and descriptive
- [ ] Description explains the value
- [ ] Price is set correctly
- [ ] Status is set to "Active" (or "Inactive" for testing)
- [ ] Product appears in your products list

---

## 🎯 All Products to Create

Create these consumable products:

| Product ID | Name | Type | Price |
|------------|------|------|-------|
| `coins_small` | Small Coin Pack | Consumable | $0.99 |
| `coins_medium` | Medium Coin Pack | Consumable | $2.99 |
| `coins_large` | Large Coin Pack | Consumable | $9.99 |
| `coins_extra_large` | Extra Large Coin Pack | Consumable | $19.99 |
| `gems_small` | Small Gem Pack | Consumable | $1.99 |
| `gems_medium` | Medium Gem Pack | Consumable | $4.99 |
| `gems_large` | Large Gem Pack | Consumable | $9.99 |
| `starter_pack` | Starter Pack | Consumable | $2.99 |

And this non-consumable:

| Product ID | Name | Type | Price |
|------------|------|------|-------|
| `remove_ads` | Remove Ads | Non-consumable | $4.99 |

---

## 🐛 Common Issues

### "Product ID already exists"
- The Product ID must be unique
- Choose a different ID or delete the existing product first

### "Invalid Product ID format"
- Use only lowercase letters, numbers, and underscores
- No spaces, special characters, or uppercase letters

### "Cannot change Product ID"
- Product IDs are permanent
- You must delete and recreate if you need to change it

### "Product not showing in app"
- Wait 2-4 hours after creation (Google needs time to propagate)
- Verify Product ID matches exactly (case-sensitive)
- Ensure product status is "Active"
- Use a release build (not debug) for testing

---

## 📸 Visual Guide (What You'll See)

### Step 1: Navigation Sidebar
```
Monetize with Play
├── Products
│   ├── App pricing
│   ├── One-time products  ← Click here!
│   ├── Subscriptions
│   └── Play Points
├── Price experiments
├── Purchase recommendations
├── Promo codes
├── Financial reports
└── Monetization setup
```

### Step 2: One-Time Products Page
```
[+ Create product] or [Create one-time product] button

You'll see a list of existing products (if any)
```

### Step 3: Product Type Selection
```
Create one-time product

Select product type:
○ Consumable      ← Select this for coins/gems
○ Non-consumable  ← Select this for remove ads

[Continue]
```

### Step 4: Product Details Form
```
Product ID: [coins_small________]
Name: [Small Coin Pack________]
Description: [Get 500 coins...]
Default price: [$0.99 USD ▼]
Status: [Active ▼]

[Save] [Cancel]
```

---

## ⏱️ Timeline

- **Product Creation**: Immediate
- **Availability in App**: 2-4 hours (Google propagation time)
- **Testing**: Can test immediately with license testing accounts

---

## 🔍 After Creating Products

1. **Verify in Products List**:
   - All products should appear in your "In-app products" list
   - Status should show "Active" (green checkmark)

2. **Test in App**:
   - Build release version: `flutter build appbundle --release`
   - Install on test device
   - Go to Shop → Store tab
   - Products should appear with correct prices

3. **Check Logs**:
   - Look for: `✅ Loaded product: coins_small`
   - Verify prices are loading correctly

---

## 📚 Additional Resources

- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [In-App Products Documentation](https://developer.android.com/google/play/billing/in-app-products)

---

## ✅ Quick Summary

1. Go to **Monetize → Products → In-app products**
2. Click **"+ Create product"**
3. Select **"In-app product"** → **"Consumable"**
4. Fill in Product ID, Name, Description, Price
5. Set Status to **"Active"**
6. Click **"Save"**
7. Wait 2-4 hours for propagation
8. Test in release build

---

**That's it!** Your consumable products are now ready. 🎉

