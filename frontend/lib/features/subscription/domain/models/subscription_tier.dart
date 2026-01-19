/// Subscription tier levels for TriTalk
///
/// The tiers are ordered from lowest to highest:
/// - free: Default tier with limited features
/// - plus: Intermediate tier with additional features
/// - pro: Premium tier with all features
enum SubscriptionTier { free, plus, pro }

/// Extension methods for [SubscriptionTier]
extension SubscriptionTierExtension on SubscriptionTier {
  /// Returns the display name in English
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.plus:
        return 'Plus';
      case SubscriptionTier.pro:
        return 'Pro';
    }
  }

  /// Check if this tier has access to the required tier level
  ///
  /// Pro tier includes Plus features, Plus tier includes Free features
  /// Returns true if this tier level is >= required tier level
  bool hasAccess(SubscriptionTier requiredTier) {
    return index >= requiredTier.index;
  }

  /// Convert from string identifier to tier enum
  static SubscriptionTier fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pro':
        return SubscriptionTier.pro;
      case 'plus':
        return SubscriptionTier.plus;
      default:
        return SubscriptionTier.free;
    }
  }
}
