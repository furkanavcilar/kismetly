import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../firestore_user_service.dart';

class MonetizationService extends ChangeNotifier {
  MonetizationService._();
  static MonetizationService? _instance;
  static MonetizationService get instance => _instance ??= MonetizationService._();

  bool _isInitialized = false;
  bool _isPremium = false;
  int _credits = 0;
  DateTime? _premiumUntil;
  final FirestoreUserService _firestoreService = FirestoreUserService();

  bool get isInitialized => _isInitialized;
  bool get isPremium => _isPremium;
  int get credits => _credits;
  DateTime? get premiumUntil => _premiumUntil;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);

      // Initialize RevenueCat with your API key
      // TODO: Replace with your actual RevenueCat API key
      const apiKey = String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');
      if (apiKey.isEmpty) {
        debugPrint('RevenueCat API key not set. Using stub mode.');
        await _loadFromFirestore();
        _isInitialized = true;
        notifyListeners();
        return;
      }

      await Purchases.configure(
        PurchasesConfiguration(apiKey)
          ..appUserID = FirebaseAuth.instance.currentUser?.uid,
      );

      // Set user ID when authenticated
      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null) {
          await Purchases.logIn(user.uid);
          await refreshUserStatus();
        } else {
          await Purchases.logOut();
        }
      });

      await refreshUserStatus();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('MonetizationService init error: $e');
      await _loadFromFirestore();
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> refreshUserStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _isPremium = false;
        _credits = 0;
        _premiumUntil = null;
        notifyListeners();
        return;
      }

      // Get RevenueCat customer info
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        final premiumEntitlement = customerInfo.entitlements.active['premium'];
        _isPremium = premiumEntitlement != null;
        if (premiumEntitlement != null && premiumEntitlement.expirationDate != null) {
          _premiumUntil = DateTime.tryParse(premiumEntitlement.expirationDate!);
        } else {
          _premiumUntil = null;
        }
      } catch (e) {
        debugPrint('RevenueCat fetch error: $e');
      }

      // Sync with Firestore
      await _loadFromFirestore();
      await _syncToFirestore();
    } catch (e) {
      debugPrint('refreshUserStatus error: $e');
    }
  }

  Future<void> _loadFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userData = await _firestoreService.getUserData(user.uid);
      if (userData != null) {
        _isPremium = userData['isPremium'] as bool? ?? false;
        _credits = (userData['credits'] as num?)?.toInt() ?? 0;
        final premiumUntilTimestamp = userData['premiumUntil'] as Timestamp?;
        _premiumUntil = premiumUntilTimestamp?.toDate();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('_loadFromFirestore error: $e');
    }
  }

  Future<void> _syncToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _firestoreService.updateUserPremium(
        user.uid,
        isPremium: _isPremium,
        premiumUntil: _premiumUntil,
      );
      await _firestoreService.updateUserCredits(user.uid, _credits);
    } catch (e) {
      debugPrint('_syncToFirestore error: $e');
    }
  }

  Future<bool> purchaseProMonthly() async {
    try {
      final offerings = await Purchases.getOfferings();
      Package? monthlyPackage;
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        try {
          monthlyPackage = offerings.current!.availablePackages.firstWhere(
            (pkg) => pkg.identifier == 'monthly',
          );
        } catch (_) {
          monthlyPackage = offerings.current!.availablePackages.first;
        }
      }

      if (monthlyPackage == null) {
        debugPrint('Monthly package not found');
        return false;
      }

      final purchaserInfo = await Purchases.purchasePackage(monthlyPackage);
      final premiumEntitlement = purchaserInfo.entitlements.active['premium'];
      _isPremium = premiumEntitlement != null;
      if (premiumEntitlement != null && premiumEntitlement.expirationDate != null) {
        _premiumUntil = DateTime.tryParse(premiumEntitlement.expirationDate!);
      } else {
        _premiumUntil = null;
      }

      await _syncToFirestore();
      notifyListeners();
      return _isPremium;
    } catch (e) {
      debugPrint('purchaseProMonthly error: $e');
      return false;
    }
  }

  Future<bool> purchaseProAnnual() async {
    try {
      final offerings = await Purchases.getOfferings();
      Package? annualPackage;
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        try {
          annualPackage = offerings.current!.availablePackages.firstWhere(
            (pkg) => pkg.identifier == 'annual',
          );
        } catch (_) {
          annualPackage = offerings.current!.availablePackages.last;
        }
      }

      if (annualPackage == null) {
        debugPrint('Annual package not found');
        return false;
      }

      final purchaserInfo = await Purchases.purchasePackage(annualPackage);
      final premiumEntitlement = purchaserInfo.entitlements.active['premium'];
      _isPremium = premiumEntitlement != null;
      if (premiumEntitlement != null && premiumEntitlement.expirationDate != null) {
        _premiumUntil = DateTime.tryParse(premiumEntitlement.expirationDate!);
      } else {
        _premiumUntil = null;
      }

      await _syncToFirestore();
      notifyListeners();
      return _isPremium;
    } catch (e) {
      debugPrint('purchaseProAnnual error: $e');
      return false;
    }
  }

  Future<bool> purchaseCredits(int amount) async {
    try {
      final offerings = await Purchases.getOfferings();
      Package? creditPackage;
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        try {
          creditPackage = offerings.current!.availablePackages.firstWhere(
            (pkg) => pkg.identifier == 'credits_$amount',
          );
        } catch (_) {
          try {
            creditPackage = offerings.current!.availablePackages.firstWhere(
              (pkg) => pkg.storeProduct.identifier.contains('credit'),
            );
          } catch (_) {
            creditPackage = null;
          }
        }
      }

      if (creditPackage == null) {
        debugPrint('Credit package not found for amount: $amount');
        // Stub: Add credits directly for testing
        _credits += amount;
        await _syncToFirestore();
        notifyListeners();
        return true;
      }

      await Purchases.purchasePackage(creditPackage);
      // Extract credit amount from purchase (you may need to adjust this based on your setup)
      _credits += amount;
      await _syncToFirestore();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('purchaseCredits error: $e');
      return false;
    }
  }

  Future<bool> deductCredits(int amount) async {
    if (_credits < amount) {
      return false;
    }

    _credits -= amount;
    await _syncToFirestore();
    notifyListeners();
    return true;
  }

  bool canAfford(int amount) => _credits >= amount || _isPremium;

  void setPremium(bool value, DateTime? until) {
    _isPremium = value;
    _premiumUntil = until;
    _syncToFirestore();
    notifyListeners();
  }

  void setCredits(int value) {
    _credits = value;
    _syncToFirestore();
    notifyListeners();
  }

  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final premiumEntitlement = customerInfo.entitlements.active['premium'];
      _isPremium = premiumEntitlement != null;
      if (premiumEntitlement != null && premiumEntitlement.expirationDate != null) {
        _premiumUntil = DateTime.tryParse(premiumEntitlement.expirationDate!);
      } else {
        _premiumUntil = null;
      }
      await _syncToFirestore();
      notifyListeners();
      return _isPremium;
    } catch (e) {
      debugPrint('restorePurchases error: $e');
      return false;
    }
  }
}

