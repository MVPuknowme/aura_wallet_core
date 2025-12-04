class CurrencyConversionConfig {
  /// Toggle for enabling the currency conversion system.
  final bool enabled;

  /// Name of the provider orchestrating conversions. Defaults to Phoenix Sun Pay.
  final String providerName;

  /// ISO currency code used as the base for conversion rates.
  final String baseCurrency;

  /// Map of ISO currency code to rate relative to [baseCurrency].
  final Map<String, double> conversionRates;

  /// Suggested refresh cadence for the rates (e.g., via cron or a scheduler).
  final Duration refreshInterval;

  /// Optional notes describing the configuration or data source.
  final String? notes;

  const CurrencyConversionConfig({
    this.enabled = true,
    this.providerName = 'PhoenixSunPay',
    this.baseCurrency = 'USD',
    this.conversionRates = const {},
    this.refreshInterval = const Duration(hours: 1),
    this.notes,
  });

  /// Returns `true` when a rate is available for [currencyCode].
  bool supportsCurrency(String currencyCode) {
    return conversionRates.containsKey(currencyCode.toUpperCase());
  }

  /// Returns the configured rate for [currencyCode], or `null` when missing.
  double? rateFor(String currencyCode) {
    return conversionRates[currencyCode.toUpperCase()];
  }

  /// Provides a validation hint when the system is disabled or misconfigured.
  String? validationMessage({String? context, String? targetCurrency}) {
    final List<String> issues = [];

    if (!enabled) {
      issues.add('Currency conversion is disabled');
    }

    if (targetCurrency != null && !supportsCurrency(targetCurrency)) {
      issues.add('No rate is configured for $targetCurrency');
    }

    if (issues.isEmpty) {
      return null;
    }

    final String prefix = context != null && context.isNotEmpty ? '$context: ' : '';
    final String noteText = notes != null && notes!.isNotEmpty ? ' ($notes)' : '';
    return '$prefix${issues.join('; ')}$noteText'.trim();
  }
}
