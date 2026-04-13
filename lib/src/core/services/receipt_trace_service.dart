import 'dart:convert';

import 'package:crypto/crypto.dart';

String buildReceiptTrace({
  required String routeName,
  required String asset,
  required String network,
  required String source,
  required String target,
  required String amount,
  required DateTime timestamp,
}) {
  final payload = jsonEncode({
    'amount': amount,
    'asset': asset,
    'network': network,
    'route': routeName,
    'source': source,
    'target': target,
    'timestamp': timestamp.toUtc().toIso8601String(),
  });

  return sha256.convert(utf8.encode(payload)).toString();
}
