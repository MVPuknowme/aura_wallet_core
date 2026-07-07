import 'package:flutter_test/flutter_test.dart';
import 'package:aura_wallet_core/src/core/services/receipt_trace_service_fallback.dart';
import 'package:aura_wallet_core/src/core/services/wallet_ledger_service.dart';
import 'package:aura_wallet_core/src/core/type_data/wallet_gate_models.dart';

void main() {
  test('confirms starter trace-only receipt path with fallback tracer', () {
    final timestamp = DateTime.parse('2026-04-13T07:20:00.000Z');

    final trace = buildReceiptTraceFallback(
      routeName: 'receipt_trace',
      asset: 'USDC',
      network: 'Base',
      source: 'starter-west-01',
      target: '0xbAA5A03bC268546194550a427d3F1d5787c15403',
      amount: '0.35',
      timestamp: timestamp,
    );

    expect(trace, '06ab41e9b25e3fef');

    final ledger = WalletLedgerService();
    ledger.record(
      WalletLedgerEntry(
        routeName: 'receipt_trace',
        asset: 'USDC',
        network: 'Base',
        source: 'starter-west-01',
        target: '0xbAA5A03bC268546194550a427d3F1d5787c15403',
        amount: '0.35',
        status: 'trace_only_confirmed',
        timestamp: timestamp,
        referenceId: trace,
      ),
    );

    expect(ledger.entries.length, 1);
    expect(ledger.entries.first.referenceId, '06ab41e9b25e3fef');
    expect(ledger.entries.first.status, 'trace_only_confirmed');
  });
}
