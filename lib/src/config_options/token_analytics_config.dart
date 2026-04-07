class TokenAnalyticsConfig {
  /// Enables or disables token analytics features.
  final bool enabled;

  /// Optional label for the analytics provider or strategy.
  final String providerName;

  /// Home geography to compare allocations against.
  final String defaultRegion;

  /// Maximum number of geographies to include in generated summaries.
  final int topRegionsLimit;

  const TokenAnalyticsConfig({
    this.enabled = true,
    this.providerName = 'BuiltInGeoAnalytics',
    this.defaultRegion = 'GLOBAL',
    this.topRegionsLimit = 3,
  });

  String? validationMessage() {
    if (!enabled) {
      return 'Token analytics is disabled';
    }

    if (topRegionsLimit <= 0) {
      return 'Token analytics requires topRegionsLimit greater than zero';
    }

    return null;
  }
}
