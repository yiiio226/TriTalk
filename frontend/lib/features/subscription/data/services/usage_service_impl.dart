import 'package:frontend/features/subscription/domain/models/paid_feature.dart';
import 'package:frontend/features/subscription/domain/services/usage_service.dart';

/// Concrete implementation of [UsageService]
///
/// Currently uses in-memory storage. Should be replaced with:
/// - Backend API for cross-device sync
/// - Local storage with daily reset logic
class UsageServiceImpl implements UsageService {
  static final UsageServiceImpl _instance = UsageServiceImpl._internal();
  factory UsageServiceImpl() => _instance;
  UsageServiceImpl._internal();

  // In-memory cache for current session
  // TODO: Replace with SharedPreferences + daily reset logic
  final Map<PaidFeature, int> _usageCounts = {};

  @override
  int getUsedCount(PaidFeature feature) {
    return _usageCounts[feature] ?? 0;
  }

  @override
  Future<void> incrementUsage(PaidFeature feature) async {
    _usageCounts[feature] = (_usageCounts[feature] ?? 0) + 1;
    // TODO: Persist to local storage
    // TODO: Sync with backend if online
  }

  /// Reset all counts (call at midnight or app start on new day)
  void resetDailyUsage() {
    _usageCounts.clear();
  }
}
