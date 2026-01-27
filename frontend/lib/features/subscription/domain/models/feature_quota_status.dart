/// Represents the usage status and limits for a single feature.
///
/// This model is used by both the cache layer and the UI to display
/// and check feature quota states.
class FeatureQuotaStatus {
  /// Number of times this feature has been used in the current period.
  final int used;

  /// Maximum allowed uses. -1 means unlimited.
  final int limit;

  /// The period identifier for this usage count.
  /// - For 'daily' features: 'YYYY-MM-DD' (UTC date)
  /// - For 'static' features: 'lifetime'
  final String period;

  /// How the quota refreshes: 'daily' or 'static'.
  final String refreshRule;

  const FeatureQuotaStatus({
    required this.used,
    required this.limit,
    required this.period,
    required this.refreshRule,
  });

  /// Whether the feature is unlimited.
  bool get isUnlimited => limit == -1;

  /// Whether the feature is completely blocked (limit = 0).
  bool get isBlocked => limit == 0;

  /// Remaining uses in the current period. Returns -1 if unlimited.
  int get remaining => isUnlimited ? -1 : (limit - used).clamp(0, limit);

  /// Whether the user can still use this feature.
  bool get canUse => isUnlimited || used < limit;

  /// Create a copy with updated used count (for optimistic updates).
  FeatureQuotaStatus copyWithUsed(int newUsed) {
    return FeatureQuotaStatus(
      used: newUsed,
      limit: limit,
      period: period,
      refreshRule: refreshRule,
    );
  }

  /// Create from JSON (cache deserialization).
  factory FeatureQuotaStatus.fromJson(Map<String, dynamic> json) {
    return FeatureQuotaStatus(
      used: json['used'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      period: json['period'] as String? ?? '',
      refreshRule: json['refresh_rule'] as String? ?? 'daily',
    );
  }

  /// Convert to JSON (cache serialization).
  Map<String, dynamic> toJson() {
    return {
      'used': used,
      'limit': limit,
      'period': period,
      'refresh_rule': refreshRule,
    };
  }

  @override
  String toString() =>
      'FeatureQuotaStatus(used: $used, limit: $limit, period: $period, refreshRule: $refreshRule)';
}

/// Result of a track usage operation.
class TrackUsageResult {
  /// Whether the usage was successfully tracked.
  final bool success;

  /// Remaining quota after this usage. -1 if unlimited.
  final int remaining;

  /// Optional message (e.g., error reason).
  final String? message;

  const TrackUsageResult({
    required this.success,
    required this.remaining,
    this.message,
  });

  /// Success result factory.
  factory TrackUsageResult.succeeded(int remaining) {
    return TrackUsageResult(success: true, remaining: remaining, message: null);
  }

  /// Failure result factory.
  factory TrackUsageResult.failed(String message) {
    return TrackUsageResult(success: false, remaining: 0, message: message);
  }

  /// Quota exceeded result factory.
  factory TrackUsageResult.quotaExceeded() {
    return const TrackUsageResult(
      success: false,
      remaining: 0,
      message: 'Quota exceeded',
    );
  }
}

/// Complete quota cache data for a user.
///
/// This represents the entire cached state stored in SharedPreferences.
class FeatureQuotaCache {
  /// Schema version for future migrations.
  final int version;

  /// When this cache was last updated (milliseconds since epoch).
  final int updatedAt;

  /// The subscription tier when this cache was created.
  /// Used to detect tier changes and invalidate cache.
  final String tier;

  /// Status for each feature, keyed by feature key string.
  final Map<String, FeatureQuotaStatus> features;

  const FeatureQuotaCache({
    this.version = 1,
    required this.updatedAt,
    required this.tier,
    required this.features,
  });

  /// Create an empty cache.
  factory FeatureQuotaCache.empty() {
    return FeatureQuotaCache(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      tier: 'free',
      features: const {},
    );
  }

  /// Create from JSON (SharedPreferences deserialization).
  factory FeatureQuotaCache.fromJson(Map<String, dynamic> json) {
    final featuresJson = json['features'] as Map<String, dynamic>? ?? {};
    final features = <String, FeatureQuotaStatus>{};

    for (final entry in featuresJson.entries) {
      if (entry.value is Map<String, dynamic>) {
        features[entry.key] = FeatureQuotaStatus.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    }

    return FeatureQuotaCache(
      version: json['version'] as int? ?? 1,
      updatedAt: json['updated_at'] as int? ?? 0,
      tier: json['tier'] as String? ?? 'free',
      features: features,
    );
  }

  /// Convert to JSON (SharedPreferences serialization).
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'updated_at': updatedAt,
      'tier': tier,
      'features': features.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  /// Create a copy with updated feature status.
  FeatureQuotaCache copyWithFeature(String key, FeatureQuotaStatus status) {
    return FeatureQuotaCache(
      version: version,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      tier: tier,
      features: {...features, key: status},
    );
  }

  /// Create a copy with new tier (invalidates cache).
  FeatureQuotaCache copyWithTier(String newTier) {
    return FeatureQuotaCache(
      version: version,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      tier: newTier,
      features: const {}, // Clear features when tier changes
    );
  }
}
