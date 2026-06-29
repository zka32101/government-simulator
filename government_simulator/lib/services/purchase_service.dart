import 'package:purchases_flutter/purchases_flutter.dart';

const String _entitlementId = 'government_simulator_full';
const String _productId = 'government_simulator_v1';

class PurchaseService {
  static bool _configured = false;

  static Future<void> configure(String apiKey) async {
    if (_configured) return;
    await Purchases.setLogLevel(LogLevel.debug);
    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
    _configured = true;
  }

  Future<bool> isEntitlementActive() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }

  Future<bool> purchaseFull() async {
    try {
      final offerings = await Purchases.getOfferings();
      final pkg = offerings.current?.availablePackages
          .where((p) => p.storeProduct.identifier == _productId)
          .firstOrNull;
      if (pkg == null) return false;
      final result = await Purchases.purchasePackage(pkg);
      return result.entitlements.active.containsKey(_entitlementId);
    } on PurchasesErrorCode catch (e) {
      // User cancelled
      if (e == PurchasesErrorCode.purchaseCancelledError) return false;
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> restorePurchase() async {
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }

  Future<String?> getProductPrice() async {
    try {
      final offerings = await Purchases.getOfferings();
      final pkg = offerings.current?.availablePackages
          .where((p) => p.storeProduct.identifier == _productId)
          .firstOrNull;
      return pkg?.storeProduct.priceString;
    } catch (_) {
      return '¥600';
    }
  }
}
