import '../../config_options/token_analytics_config.dart';
import '../../constants/error_constants.dart';
import '../exceptions/aura_internal_exception.dart';
import '../type_data/token_analytics_models.dart';

class TokenAnalyticsService {
  final TokenAnalyticsConfig config;

  const TokenAnalyticsService({required this.config});

  TokenGeoAnalysis analyzeGeoDistribution(List<TokenHolding> holdings) {
    final String? validation = config.validationMessage();
    if (validation != null) {
      throw AuraInternalError(ErrorCode.TokenAnalyticsUnavailable, validation);
    }

    if (holdings.isEmpty) {
      throw AuraInternalError(
        ErrorCode.TokenAnalyticsUnavailable,
        'Token analytics requires at least one holding',
      );
    }

    final Map<String, List<TokenHolding>> grouped =
        <String, List<TokenHolding>>{};
    for (final TokenHolding holding in holdings) {
      final String geography = holding.geography.trim().toUpperCase();
      grouped.putIfAbsent(geography, () => <TokenHolding>[]).add(holding);
    }

    final double totalMarketValue = holdings.fold<double>(
      0,
      (double sum, TokenHolding holding) => sum + holding.marketValue,
    );

    if (totalMarketValue <= 0) {
      throw AuraInternalError(
        ErrorCode.TokenAnalyticsUnavailable,
        'Token analytics requires positive market value',
      );
    }

    final List<TokenRegionBreakdown> regions = grouped.entries.map((entry) {
      final double marketValue = entry.value.fold<double>(
        0,
        (double sum, TokenHolding holding) => sum + holding.marketValue,
      );
      return TokenRegionBreakdown(
        geography: entry.key,
        marketValue: marketValue,
        allocation: marketValue / totalMarketValue,
        tokenCount: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => b.marketValue.compareTo(a.marketValue));

    final List<TokenRegionBreakdown> limitedRegions =
        regions.take(config.topRegionsLimit).toList(growable: false);

    final double concentration = regions.fold<double>(
      0,
      (double sum, TokenRegionBreakdown region) =>
          sum + (region.allocation * region.allocation),
    );
    final double diversificationScore = 1 - concentration;
    final String dominantRegion = regions.first.geography;

    final String insight = _buildInsight(
      dominantRegion: dominantRegion,
      dominantAllocation: regions.first.allocation,
      regionCount: regions.length,
      diversificationScore: diversificationScore,
    );

    return TokenGeoAnalysis(
      totalMarketValue: totalMarketValue,
      dominantRegion: dominantRegion,
      regions: limitedRegions,
      diversificationScore: diversificationScore,
      insight: insight,
    );
  }

  String _buildInsight({
    required String dominantRegion,
    required double dominantAllocation,
    required int regionCount,
    required double diversificationScore,
  }) {
    final String concentrationLabel = dominantAllocation >= 0.60
        ? 'highly concentrated'
        : dominantAllocation >= 0.40
            ? 'moderately concentrated'
            : 'well distributed';

    return 'Portfolio is $concentrationLabel in $dominantRegion across '
        '$regionCount geographies with diversification score '
        '${diversificationScore.toStringAsFixed(2)}.';
  }
}
