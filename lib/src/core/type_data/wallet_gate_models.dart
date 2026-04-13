class AssetRef {
  final String symbol;
  final String network;
  final String contract;
  final int decimals;
  final String kind;

  const AssetRef({
    required this.symbol,
    required this.network,
    required this.contract,
    required this.decimals,
    required this.kind,
  });
}

class PayoutTarget {
  final String name;
  final String address;
  final String network;
  final String role;

  const PayoutTarget({
    required this.name,
    required this.address,
    required this.network,
    required this.role,
  });
}

class WalletRoute {
  final String name;
  final String source;
  final String asset;
  final String network;
  final String target;
  final String mode;

  const WalletRoute({
    required this.name,
    required this.source,
    required this.asset,
    required this.network,
    required this.target,
    required this.mode,
  });
}

class WalletLedgerEntry {
  final String routeName;
  final String asset;
  final String network;
  final String source;
  final String target;
  final String amount;
  final String status;
  final DateTime timestamp;
  final String? referenceId;

  const WalletLedgerEntry({
    required this.routeName,
    required this.asset,
    required this.network,
    required this.source,
    required this.target,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.referenceId,
  });
}
