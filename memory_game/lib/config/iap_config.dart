/// In-App Purchase Product IDs Configuration
/// 
/// Update these product IDs to match your Google Play Console / App Store Connect setup
class IAPConfig {
  IAPConfig._();

  // ============================================
  // NON-CONSUMABLE PRODUCTS
  // ============================================
  
  /// Remove all ads permanently
  static const String removeAds = 'remove_ads';

  // ============================================
  // CONSUMABLE PRODUCTS - COIN PACKS
  // ============================================
  
  /// Small coin pack - 500 coins
  static const String coinsSmall = 'coins_small';
  
  /// Medium coin pack - 1,500 coins + 200 bonus
  static const String coinsMedium = 'coins_medium';
  
  /// Large coin pack - 5,000 coins + 1,000 bonus
  static const String coinsLarge = 'coins_large';
  
  /// Extra large coin pack - 10,000 coins + 2,500 bonus
  static const String coinsExtraLarge = 'coins_extra_large';

  // ============================================
  // CONSUMABLE PRODUCTS - GEM PACKS
  // ============================================
  
  /// Small gem pack - 20 gems
  static const String gemsSmall = 'gems_small';
  
  /// Medium gem pack - 60 gems + 10 bonus
  static const String gemsMedium = 'gems_medium';
  
  /// Large gem pack - 150 gems + 30 bonus
  static const String gemsLarge = 'gems_large';

  // ============================================
  // CONSUMABLE PRODUCTS - STARTER PACKS
  // ============================================
  
  /// Starter pack - coins + gems + power-ups
  static const String starterPack = 'starter_pack';

  // ============================================
  // ALL PRODUCT IDs
  // ============================================
  
  static const List<String> allProducts = [
    // Non-consumables
    removeAds,
    // Coin packs
    coinsSmall,
    coinsMedium,
    coinsLarge,
    coinsExtraLarge,
    // Gem packs
    gemsSmall,
    gemsMedium,
    gemsLarge,
    // Starter packs
    starterPack,
  ];

  // ============================================
  // PRODUCT METADATA (Fallback if store unavailable)
  // ============================================
  
  static const Map<String, ProductInfo> productInfo = {
    // Coin packs
    coinsSmall: ProductInfo(
      coins: 500,
      price: 0.99,
      name: 'Small Coin Pack',
      description: 'Get 500 coins to purchase power-ups and unlock new content. Perfect for getting started!',
    ),
    coinsMedium: ProductInfo(
      coins: 1500,
      bonus: 200,
      price: 2.99,
      name: 'Medium Coin Pack',
      description: 'Get 1,500 coins plus 200 bonus coins (1,700 total)! Great value for regular players.',
    ),
    coinsLarge: ProductInfo(
      coins: 5000,
      bonus: 1000,
      price: 9.99,
      name: 'Large Coin Pack',
      description: 'Get 5,000 coins plus 1,000 bonus coins (6,000 total)! Stock up on power-ups and unlock everything.',
    ),
    coinsExtraLarge: ProductInfo(
      coins: 10000,
      bonus: 2500,
      price: 19.99,
      name: 'Extra Large Coin Pack',
      description: 'Get 10,000 coins plus 2,500 bonus coins (12,500 total)! The ultimate coin pack for serious players.',
    ),
    // Gem packs
    gemsSmall: ProductInfo(
      gems: 20,
      price: 1.99,
      name: 'Small Gem Pack',
      description: 'Get 20 premium gems to unlock exclusive themes and special power-ups. Premium currency for special items!',
    ),
    gemsMedium: ProductInfo(
      gems: 60,
      bonus: 10,
      price: 4.99,
      name: 'Medium Gem Pack',
      description: 'Get 60 gems plus 10 bonus gems (70 total)! Unlock multiple themes and premium features.',
    ),
    gemsLarge: ProductInfo(
      gems: 150,
      bonus: 30,
      price: 9.99,
      name: 'Large Gem Pack',
      description: 'Get 150 gems plus 30 bonus gems (180 total)! Unlock all themes and have gems to spare.',
    ),
    // Starter pack
    starterPack: ProductInfo(
      coins: 1000,
      gems: 20,
      price: 2.99,
      name: 'Starter Pack',
      description: 'Perfect starter bundle! Get 1,000 coins and 20 gems to kickstart your memory training journey. Great value for new players!',
    ),
    // Remove ads
    removeAds: ProductInfo(
      price: 4.99,
      name: 'Remove Ads',
      description: 'Remove all ads permanently and enjoy an uninterrupted, ad-free gaming experience. Support the developers and play without distractions!',
      isNonConsumable: true,
    ),
  };

  /// Get product info by ID
  static ProductInfo? getProductInfo(String productId) {
    return productInfo[productId];
  }

  /// Check if product is a coin pack
  static bool isCoinPack(String productId) {
    return productId == coinsSmall ||
        productId == coinsMedium ||
        productId == coinsLarge ||
        productId == coinsExtraLarge;
  }

  /// Check if product is a gem pack
  static bool isGemPack(String productId) {
    return productId == gemsSmall ||
        productId == gemsMedium ||
        productId == gemsLarge;
  }

  /// Check if product is remove ads
  static bool isRemoveAds(String productId) {
    return productId == removeAds;
  }

  /// Check if product is starter pack
  static bool isStarterPack(String productId) {
    return productId == starterPack;
  }
}

/// Product information metadata
class ProductInfo {
  final int coins;
  final int gems;
  final int bonus;
  final double price;
  final String name;
  final String description;
  final bool isNonConsumable;

  const ProductInfo({
    this.coins = 0,
    this.gems = 0,
    this.bonus = 0,
    required this.price,
    required this.name,
    required this.description,
    this.isNonConsumable = false,
  });

  int get totalCoins => coins + (isCoinPack ? bonus : 0);
  int get totalGems => gems + (isGemPack ? bonus : 0);
  
  bool get isCoinPack => coins > 0;
  bool get isGemPack => gems > 0;
}



