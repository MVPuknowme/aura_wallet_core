import 'src/aura_internal_wallet_ipml.dart';
import 'src/config_options/biometric_options.dart';
import 'src/config_options/currency_conversion_config.dart';
import 'src/config_options/payment_processing_rules.dart';
import 'src/config_options/token_analytics_config.dart';
import 'src/constants/aura_constants.dart';
import 'src/core/type_data/token_analytics_models.dart';
import 'src/entities/aura_wallet.dart';
import 'src/env/env.dart';

/// An abstract class representing the core functionality of an Aura wallet.
abstract class AuraWalletCore {
  /// Factory constructor for creating an instance of [AuraWalletCore].
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

  /// Internal method to create an instance of [AuraWalletCore].
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

  /// Generates a random HD wallet.
  ///
  /// Returns an [ComprehensiveWallet] containing the wallet information.
  Future<ComprehensiveWallet> createRandomHDWallet();

  /// Restores a HD wallet from a passphrase.
  ///
  /// [passPhrase]: The passphrase used to restore the wallet.
  /// [walletName]: The name of the wallet (default is [CONST_DEFAULT_WALLET_NAME]).
  ///
  /// Returns an [AuraWallet] instance.
  Future<AuraWallet> restoreHDWallet({
    required String passPhrase,
    String walletName = CONST_DEFAULT_WALLET_NAME,
  });

  /// Loads a previously stored wallet.
  ///
  /// [walletName]: The name of the wallet to load (default is [CONST_DEFAULT_WALLET_NAME]).
  ///
  /// Returns an [AuraWallet] instance or `null` if no wallet is found.
  Future<AuraWallet?> loadStoredWallet({
    String walletName = CONST_DEFAULT_WALLET_NAME,
  });

  /// Removes a wallet from storage.
  ///
  /// [walletName]: The name of the wallet to remove (default is [CONST_DEFAULT_WALLET_NAME]).
  Future<void> removeWallet({
    String walletName = CONST_DEFAULT_WALLET_NAME,
  });

  /// Builds a geographic distribution analysis for the provided token holdings.
  TokenGeoAnalysis analyzeTokenGeography(List<TokenHolding> holdings);
}

export 'src/config_options/token_analytics_config.dart';
export 'src/core/type_data/token_analytics_models.dart';
