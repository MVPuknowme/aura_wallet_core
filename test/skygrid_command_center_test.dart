import 'package:flutter_test/flutter_test.dart';
import 'package:aura_wallet_core/aura_wallet_core.dart';

void main() {
  test('builds dashboard-first preview with review-only artifacts', () {
    const service = SkyGridCommandCenterService();
    final preview = service.buildPreview(
      operatorIntent: const <String, dynamic>{
        'route': 'autodrill',
        'private_key': 'should-not-leak',
        'nested': <String, dynamic>{'api_token': 'secret-token'},
      },
    );

    expect(preview.mode, SkyGridOperatingMode.draft);
    expect(preview.helmStatus.chartPath, 'helm/aura-core-autodrill');
    expect(preview.helmStatus.dryRunRequired, isTrue);
    expect(preview.walletSigningAllowed, isFalse);
    expect(preview.containsSecrets, isTrue);
    expect(preview.operatorPayload['private_key'], '[REDACTED]');
    expect(
      (preview.operatorPayload['nested'] as Map<String, dynamic>)['api_token'],
      '[REDACTED]',
    );
    expect(preview.l2Scripts, hasLength(4));
    expect(preview.l2Scripts.every((script) => !script.autoExecutes), isTrue);
  });

  test('allows wallet signing only in execute mode', () {
    const service = SkyGridCommandCenterService();

    final validatePreview = service.buildPreview(
      mode: SkyGridOperatingMode.validate,
    );
    final executePreview = service.buildPreview(
      mode: SkyGridOperatingMode.execute,
    );

    expect(validatePreview.walletSigningAllowed, isFalse);
    expect(executePreview.walletSigningAllowed, isTrue);
  });

  test('formats receipt records for dashboard display', () {
    const service = SkyGridCommandCenterService();
    final receipt = service.buildReceiptRecord(
      transactionHash: '0xabc123',
      status: 'confirmed',
      network: 'base',
      observedAt: DateTime.parse('2026-05-20T12:00:00Z'),
      reviewUrl: 'https://example.test/tx/0xabc123',
    );

    final json = receipt.toJson();

    expect(json['transaction_hash'], '0xabc123');
    expect(json['status'], 'confirmed');
    expect(json['network'], 'base');
    expect(json['observed_at'], '2026-05-20T12:00:00.000Z');
    expect(json['review_url'], 'https://example.test/tx/0xabc123');
  });
}
