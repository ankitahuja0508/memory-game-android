import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/iap_config.dart';
import 'ad_service.dart';

/// Service for managing in-app purchases
/// 
/// Handles:
/// - Purchase flow for consumable products (coins, gems)
/// - Purchase flow for non-consumable products (remove ads)
/// - Purchase restoration
/// - Purchase verification and completion
class IAPService {
  IAPService._();
  static final IAPService instance = IAPService._();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  // Product details cache
  Map<String, ProductDetails> _productDetailsCache = {};
  Map<String, ProductDetails> get productDetails => _productDetailsCache;

  // Purchase callbacks
  void Function(String productId, bool success, String? error)? onPurchaseComplete;
  void Function()? onProductsLoaded;

  // Prefs keys
  static const String _adsRemovedKey = 'iap_ads_removed';
  static const String _purchasesKey = 'iap_purchases';

  /// Initialize the IAP service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ IAP Service already initialized');
      return;
    }

    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Check if IAP is available
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('❌ In-app purchases not available on this device');
        _isInitialized = false;
        return;
      }

      // Listen to purchase updates
      _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () {
          _purchaseSubscription?.cancel();
        },
        onError: (error) {
          debugPrint('❌ Purchase stream error: $error');
        },
      );

      // Restore previous purchases
      await _restorePurchases();

      // Load product details
      await loadProductDetails();

      _isInitialized = true;
      debugPrint('✅ IAP Service initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize IAP Service: $e');
      debugPrint('Stack: $stackTrace');
      _isInitialized = false;
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if ads are removed (user purchased remove_ads)
  bool get adsRemoved => _prefs?.getBool(_adsRemovedKey) ?? false;

  /// Load product details from store
  /// Can be called multiple times to refresh product information
  Future<void> loadProductDetails() async {
    if (!_isInitialized) {
      debugPrint('⚠️ Cannot load products - IAP not initialized');
      return;
    }

    try {
      debugPrint('🔄 Loading product details from store...');
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
        IAPConfig.allProducts.toSet(),
      );

      if (response.error != null) {
        debugPrint('❌ Error loading products: ${response.error}');
        debugPrint('   Code: ${response.error?.code}');
        debugPrint('   Message: ${response.error?.message}');
        debugPrint('   Details: ${response.error?.details}');
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('⚠️ Products not found in store: ${response.notFoundIDs}');
        debugPrint('   Make sure these products are created and active in Google Play Console');
      }

      // Clear and update cache with fresh product details
      _productDetailsCache.clear();
      
      // Cache product details (these are automatically localized by Google Play)
      for (final product in response.productDetails) {
        _productDetailsCache[product.id] = product;
        debugPrint('✅ Loaded product: ${product.id}');
        debugPrint('   Title: ${product.title}');
        debugPrint('   Price: ${product.price} (localized for device locale)');
        final descPreview = product.description.isNotEmpty 
            ? (product.description.length > 50 
                ? '${product.description.substring(0, 50)}...' 
                : product.description)
            : 'No description';
        debugPrint('   Description: $descPreview');
      }

      onProductsLoaded?.call();
      debugPrint('✅ Successfully loaded ${response.productDetails.length}/${IAPConfig.allProducts.length} products');
      
      if (response.productDetails.length < IAPConfig.allProducts.length) {
        debugPrint('⚠️ Some products are missing. Check Google Play Console.');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception loading products: $e');
      debugPrint('Stack: $stackTrace');
    }
  }

  /// Get product details for a specific product ID
  ProductDetails? getProductDetails(String productId) {
    return _productDetailsCache[productId];
  }

  /// Purchase a product
  /// Returns true if purchase was initiated successfully
  Future<bool> purchaseProduct(String productId) async {
    if (!_isInitialized) {
      debugPrint('❌ Cannot purchase - IAP not initialized');
      onPurchaseComplete?.call(productId, false, 'IAP not initialized. Please wait a moment and try again.');
      return false;
    }

    final productDetails = _productDetailsCache[productId];
    if (productDetails == null) {
      debugPrint('❌ Product not found in cache: $productId');
      debugPrint('   Attempting to reload products...');
      
      // Try to reload products once
      await loadProductDetails();
      
      // Check again after reload
      final retryProductDetails = _productDetailsCache[productId];
      if (retryProductDetails == null) {
        debugPrint('❌ Product still not found after reload: $productId');
        onPurchaseComplete?.call(productId, false, 'Product not available. Please check your connection and try again.');
        return false;
      }
      
      // Use the reloaded product details
      debugPrint('✅ Product loaded after retry: $productId');
    }

    try {
      debugPrint('🛒 Initiating purchase: $productId');

      // Check if it's a non-consumable and already purchased
      if (IAPConfig.isRemoveAds(productId) && adsRemoved) {
        debugPrint('⚠️ Remove ads already purchased');
        onPurchaseComplete?.call(productId, true, null);
        return true;
      }

      // Get the product details (use retry result if we reloaded)
      final finalProductDetails = _productDetailsCache[productId] ?? productDetails;
      if (finalProductDetails == null) {
        debugPrint('❌ Product details not available: $productId');
        onPurchaseComplete?.call(productId, false, 'Product details not available');
        return false;
      }

      // Create purchase param
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: finalProductDetails,
      );

      // Note: In Google Play Console, all products are created as "one-time products".
      // The app determines consumability by using the appropriate purchase method:
      // - buyConsumable(): For products that should be consumed (coins, gems, starter pack)
      //   The package automatically handles consumption after purchase
      // - buyNonConsumable(): For products that should NOT be consumed (remove ads)
      //   These are acknowledged with completePurchase() but not consumed
      
      if (IAPConfig.isRemoveAds(productId)) {
        // Non-consumable: Remove Ads - acknowledge but don't consume
        final bool success = await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
        if (!success) {
          debugPrint('❌ Failed to initiate purchase');
          onPurchaseComplete?.call(productId, false, 'Failed to initiate purchase');
        }
        return success;
      } else {
        // Consumable: Coins, gems, starter pack - automatically consumed after purchase
        final bool success = await _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam,
        );
        if (!success) {
          debugPrint('❌ Failed to initiate purchase');
          onPurchaseComplete?.call(productId, false, 'Failed to initiate purchase');
        }
        return success;
      }
    } catch (e) {
      debugPrint('❌ Exception during purchase: $e');
      onPurchaseComplete?.call(productId, false, e.toString());
      return false;
    }
  }

  /// Handle purchase updates from the stream
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('📦 Purchase update: ${purchaseDetails.productID} - ${purchaseDetails.status}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          debugPrint('⏳ Purchase pending: ${purchaseDetails.productID}');
          // Notify UI that purchase is pending (optional - for loading states)
          // Don't call onPurchaseComplete here as purchase isn't complete yet
          break;

        case PurchaseStatus.purchased:
          _handleSuccessfulPurchase(purchaseDetails);
          break;

        case PurchaseStatus.error:
          debugPrint('❌ Purchase error: ${purchaseDetails.error}');
          final errorMessage = purchaseDetails.error?.message ?? 
                              purchaseDetails.error?.code.toString() ?? 
                              'Purchase failed';
          onPurchaseComplete?.call(
            purchaseDetails.productID,
            false,
            errorMessage,
          );
          // Complete the purchase even on error to acknowledge it and prevent it from being stuck
          if (purchaseDetails.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchaseDetails);
          }
          break;

        case PurchaseStatus.restored:
          debugPrint('♻️ Purchase restored: ${purchaseDetails.productID}');
          _handleSuccessfulPurchase(purchaseDetails, isRestore: true);
          break;

        case PurchaseStatus.canceled:
          debugPrint('🚫 Purchase canceled: ${purchaseDetails.productID}');
          onPurchaseComplete?.call(purchaseDetails.productID, false, 'Purchase canceled');
          // Complete the purchase to acknowledge cancellation and prevent it from being stuck
          if (purchaseDetails.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchaseDetails);
          }
          break;
      }
    }
  }

  /// Handle a successful purchase
  /// 
  /// Note: In Google Play Console, all products are created as "one-time products".
  /// The app determines if a product is consumable by using buyConsumable() vs buyNonConsumable().
  /// - Consumable products (coins, gems): Automatically consumed by buyConsumable()
  /// - Non-consumable products (remove ads): Acknowledged with completePurchase()
  void _handleSuccessfulPurchase(
    PurchaseDetails purchaseDetails, {
    bool isRestore = false,
  }) {
    final productId = purchaseDetails.productID;
    debugPrint('✅ Purchase successful: $productId (restore: $isRestore)');

    try {
      // Handle remove ads (non-consumable)
      if (IAPConfig.isRemoveAds(productId)) {
        _markAdsAsRemoved();
        debugPrint('✅ Ads removed successfully');
      }

      // Save purchase record
      _savePurchaseRecord(productId, purchaseDetails);

      // Notify listeners (this grants rewards in the UI)
      onPurchaseComplete?.call(productId, true, null);

      // Complete/acknowledge the purchase
      // For consumable products purchased via buyConsumable(), consumption is handled automatically
      // For non-consumable products, we need to acknowledge with completePurchase()
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
        debugPrint('✅ Purchase completed and acknowledged');
      }
    } catch (e) {
      debugPrint('❌ Error handling purchase: $e');
      onPurchaseComplete?.call(productId, false, e.toString());
    }
  }

  /// Mark ads as removed
  void _markAdsAsRemoved() {
    _prefs?.setBool(_adsRemovedKey, true);
    // Notify AdService to remove ads
    AdService.instance.setAdsRemoved(true);
    debugPrint('✅ Ads removed flag saved and AdService updated');
  }

  /// Save purchase record
  void _savePurchaseRecord(String productId, PurchaseDetails purchaseDetails) {
    try {
      final purchases = _prefs?.getStringList(_purchasesKey) ?? [];
      final record = '${productId}_${DateTime.now().millisecondsSinceEpoch}';
      purchases.add(record);
      _prefs?.setStringList(_purchasesKey, purchases);
      debugPrint('💾 Purchase record saved: $productId');
    } catch (e) {
      debugPrint('❌ Error saving purchase record: $e');
    }
  }

  /// Restore previous purchases
  /// This will trigger purchase stream updates for any previously purchased non-consumable items
  Future<void> _restorePurchases() async {
    if (!_isInitialized) {
      debugPrint('⚠️ Cannot restore purchases - IAP not initialized');
      return;
    }

    try {
      debugPrint('♻️ Restoring purchases...');
      await _inAppPurchase.restorePurchases();
      debugPrint('✅ Purchase restoration initiated - waiting for stream updates...');
      // Note: Restored purchases will come through the purchase stream
      // and be handled by _handlePurchaseUpdates() -> _handleSuccessfulPurchase()
    } catch (e) {
      debugPrint('❌ Error restoring purchases: $e');
    }
  }

  /// Manually restore purchases (for user-triggered restore)
  Future<void> restorePurchases() async {
    await _restorePurchases();
  }

  /// Get purchase rewards for a product
  /// Returns a map with 'coins' and/or 'gems' keys
  Map<String, int> getPurchaseRewards(String productId) {
    final productInfo = IAPConfig.getProductInfo(productId);
    if (productInfo == null) {
      return {};
    }

    final rewards = <String, int>{};
    
    if (productInfo.coins > 0) {
      rewards['coins'] = productInfo.totalCoins;
    }
    
    if (productInfo.gems > 0) {
      rewards['gems'] = productInfo.totalGems;
    }

    // Starter pack special handling
    if (IAPConfig.isStarterPack(productId)) {
      rewards['coins'] = productInfo.coins;
      rewards['gems'] = productInfo.gems;
      // Could add power-ups here if needed
    }

    return rewards;
  }

  /// Check if a product has been purchased (for non-consumables)
  bool hasPurchased(String productId) {
    if (IAPConfig.isRemoveAds(productId)) {
      return adsRemoved;
    }
    // For consumables, we don't track if they've been purchased
    // since they can be purchased multiple times
    return false;
  }

  /// Dispose the service
  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _isInitialized = false;
    debugPrint('🔄 IAP Service disposed');
  }
}

