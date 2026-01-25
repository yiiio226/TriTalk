import 'package:frontend/features/subscription/domain/models/paid_feature.dart';

/// Service interface to track usage of paid features
///
/// Implementation should be in data layer, connecting to:
/// - Backend API for cross-device sync
/// - Local storage with daily reset logic
abstract class UsageService {
  /// Get the number of times a feature has been used today
  int getUsedCount(PaidFeature feature);

  /// Increment the usage count for a feature
  Future<void> incrementUsage(PaidFeature feature);
}
