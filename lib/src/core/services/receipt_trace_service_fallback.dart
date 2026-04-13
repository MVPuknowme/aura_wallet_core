String buildReceiptTraceFallback({
  required String routeName,
  required String asset,
  required String network,
  required String source,
  required String target,
  required String amount,
  required DateTime timestamp,
}) {
  final payload = [
    routeName,
    asset,
    network,
    source,
    target,
    amount,
    timestamp.toUtc().toIso8601String(),
  ].join('|');

  int hash = 0xcbf29ce484222325;
  const int prime = 0x100000001b3;
  const int mask = 0xFFFFFFFFFFFFFFFF;

  for (final codeUnit in payload.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * prime) & mask;
  }

  return hash.toRadixString(16).padLeft(16, '0');
}
