import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_wallet_core/src/core/exceptions/aura_internal_exception.dart';

void main() {
  group('Token analytics', () {
    test('builds a geo distribution summary for token holdings', () {
      final AuraWalletCore core = AuraWalletCore.create(
        environment: AuraWalletCoreEnvironment.testNet,
        tokenAnalyticsConfig: const TokenAnalyticsConfig(topRegionsLimit: 2),
      );

      final TokenGeoAnalysis analysis = core.analyzeTokenGeography(
        const <TokenHolding>[
          TokenHolding(
            symbol: 'AURA',
            amount: 100,
            unitPrice: 0.5,
            geography: 'APAC',
          ),
          TokenHolding(
            symbol: 'ATOM',
            amount: 10,
            unitPrice: 8,
            geography: 'NA',
          ),
          TokenHolding(
            symbol: 'USDC',
            amount: 20,
            unitPrice: 1,
            geography: 'NA',
          ),
        ],
      );

      expect(analysis.totalMarketValue, closeTo(150, 0.0001));
      expect(analysis.dominantRegion, 'NA');
      expect(analysis.regions, hasLength(2));
      expect(analysis.regions.first.allocation, closeTo(2 / 3, 0.0001));
      expect(analysis.insight, contains('NA'));
    });

    test('throws when analytics are disabled', () {
      final AuraWalletCore core = AuraWalletCore.create(
        environment: AuraWalletCoreEnvironment.testNet,
        tokenAnalyticsConfig: const TokenAnalyticsConfig(enabled: false),
      );

      expect(
        () => core.analyzeTokenGeography(
          const <TokenHolding>[
            TokenHolding(
              symbol: 'AURA',
              amount: 1,
              unitPrice: 1,
              geography: 'GLOBAL',
            ),
          ],
        ),
        throwsA(isA<AuraInternalError>()),
      );
    });
  });
}
