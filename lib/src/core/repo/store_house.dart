import 'package:alan/alan.dart';
import 'package:aura_wallet_core/src/config_options/biometric_options.dart';
import 'package:aura_wallet_core/src/config_options/payment_processing_rules.dart';
import 'package:aura_wallet_core/src/env/env.dart';
import 'package:aura_wallet_core/src/utils/aura_wallet_utils.dart';
import 'package:aura_wallet_core/storage_util.dart';
import 'package:aura_wallet_core/src/config_options/currency_conversion_config.dart';

import '../services/currency_conversion_service.dart';

class Storehouse {
  Storehouse._();

  static late AuraWalletCoreEnvironment environment;
  static late NetworkInfo networkInfo;
  static late AuraInternalStorage storage;
  static late PaymentProcessingRules paymentRules;
  static late CurrencyConversionService currencyConversionService;

  static void makeDI(
    AuraWalletCoreEnvironment environment,
    BiometricOptions? biometricOptions,
    PaymentProcessingRules paymentRules,
    CurrencyConversionConfig currencyConversionConfig,
  ) {
    Storehouse.environment = environment;
    Storehouse.networkInfo = AuraWalletUtil.getNetworkInfo(environment);
    Storehouse.storage = AuraInternalStorage(biometricOptions);
    Storehouse.paymentRules = paymentRules;
    Storehouse.currencyConversionService = CurrencyConversionService(
      config: currencyConversionConfig,
    );
  }
}
