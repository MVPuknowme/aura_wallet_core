export 'src/config_options/token_analytics_config.dart';
export 'src/core/type_data/token_analytics_models.dart';
export 'src/env/env.dart';

import 'src/aura_internal_wallet_ipml.dart';
import 'src/config_options/biometric_options.dart';
import 'src/config_options/currency_conversion_config.dart';
import 'src/config_options/payment_processing_rules.dart';
import 'src/config_options/token_analytics_config.dart';
import 'src/constants/aura_constants.dart';
import 'src/core/type_data/token_analytics_models.dart';
import 'src/entities/aura_wallet.dart';
import 'src/env/env.dart';

abstract class AuraWalletCore {
  factory AuraWalletCore.create({
    required AuraWalletCoreEnvironment environment,
    BiometricOptions? biometricOptions,
    PaymentProcessingRules paymentRules = const PaymentProcessingRules(),
    CurrencyConversionConfig currencyConversionConfig =
        const CurrencyConversionConfig(),
    TokenAnalyticsConfig tokenAnalyticsConfig = const TokenAnalyticsConfig(),
  }) {
    return _instance(
      environment,
      biometricOptions,
      paymentRules,
      currencyConversionConfig,
      tokenAnalyticsConfig,
    );
  }

  static AuraWalletCore _instance(
    AuraWalletCoreEnvironment environment,
    BiometricOptions? biometricOptions,
    PaymentProcessingRules paymentRules,
    CurrencyConversionConfig currencyConversionConfig,
    TokenAnalyticsConfig tokenAnalyticsConfig,
  ) =>
      AuraWalletCoreImpl(
        environment: environment,
        biometricOptions: biometricOptions,
        paymentRules: paymentRules,
        currencyConversionConfig: currencyConversionConfig,
        tokenAnalyticsConfig: tokenAnalyticsConfig,
      );

  Future<ComprehensiveWallet> createRandomHDWallet();

  Future<AuraWallet> restoreHDWallet({
    required String passPhrase,
    String walletName = CONST_DEFAULT_WALLET_NAME,
  });

  Future<AuraWallet?> loadStoredWallet({
    String walletName = CONST_DEFAULT_WALLET_NAME,
  });

  /// Compatibility shim for legacy example code
  Future<AuraWallet?> loadCurrentWallet([String? _]) {
    return loadStoredWallet();
  }

  Future<void> removeWallet({
    String walletName = CONST_DEFAULT_WALLET_NAME,
  });

  TokenGeoAnalysis analyzeTokenGeography(List<TokenHolding> holdings);
}
