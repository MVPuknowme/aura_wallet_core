class TokenHolding {
  final String symbol;
  final double amount;
  final double unitPrice;
  final String geography;

  const TokenHolding({
    required this.symbol,
    required this.amount,
    required this.unitPrice,
    required this.geography,
  });

  double get marketValue => amount * unitPrice;
}

class TokenRegionBreakdown {
  final String geography;
  final double marketValue;
  final double allocation;
  final int tokenCount;

  const TokenRegionBreakdown({
    required this.geography,
    required this.marketValue,
    required this.allocation,
    required this.tokenCount,
  });
}

class TokenGeoAnalysis {
  final double totalMarketValue;
  final String dominantRegion;
  final List<TokenRegionBreakdown> regions;
  final double diversificationScore;
  final String insight;

  const TokenGeoAnalysis({
    required this.totalMarketValue,
    required this.dominantRegion,
    required this.regions,
    required this.diversificationScore,
    required this.insight,
  });
}
