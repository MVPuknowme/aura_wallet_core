import '../../config_options/currency_conversion_config.dart';
import '../../constants/error_constants.dart';
import '../exceptions/aura_internal_exception.dart';

class CurrencyConversionService {
  final CurrencyConversionConfig config;

  const CurrencyConversionService({required this.config});

  /// Converts [amount] from the configured base currency to [targetCurrency].
  ///
  /// Throws [AuraInternalError] when conversion is disabled or the rate is missing.
  double convert({required double amount, required String targetCurrency}) {
    final String currencyCode = targetCurrency.toUpperCase();
    final String? validation = config.validationMessage(
      context: 'Currency conversion',
      targetCurrency: currencyCode,
    );

    if (validation != null) {
      throw AuraInternalError(
        ErrorCode.CurrencyConversionUnavailable,
        validation,
      );
    }

    final double rate = config.rateFor(currencyCode)!;
    return amount * rate;
  }

  /// Returns the configured rate for [targetCurrency] when available.
  double? getRate(String targetCurrency) {
    return config.rateFor(targetCurrency.toUpperCase());
  }
}
