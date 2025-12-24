import 'package:flutter/material.dart';

class RevenueCatService extends ChangeNotifier {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isPro = false;
  int _dailyMessageCount = 0;
  static const int _freeLimit = 10;

  bool get isPro => _isPro;
  int get remainingFreeMessages => _isPro ? 9999 : (_freeLimit - _dailyMessageCount);

  void mockPurchase() {
    _isPro = true;
    notifyListeners();
  }

  void mockRestore() {
    // Simulate restore finding a purchase
    _isPro = true;
    notifyListeners();
  }

  bool canSendMessage() {
    if (_isPro) return true;
    return _dailyMessageCount < _freeLimit;
  }

  void incrementMessageCount() {
    if (!_isPro) {
      _dailyMessageCount++;
      notifyListeners();
    }
  }

  void resetDailyCount() {
    _dailyMessageCount = 0;
    notifyListeners();
  }
}
