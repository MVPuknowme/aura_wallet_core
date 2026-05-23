import 'package:aura_wallet_core/src/core/services/skygrid_onramp_service.dart';
import 'package:test/test.dart';

void main() {
  group('SkyGridOnRampService', () {
    test('creates unique ids and treasury assignment', () {
      final service = SkyGridOnRampService();
      final a = service.createQuote(
        pathway: 'node_hosting',
        amount: 10,
        chainId: 8453,
        tokenAddress: 'eth',
      );
      final b = service.createQuote(
        pathway: 'node_hosting',
        amount: 11,
        chainId: 8453,
        tokenAddress: kBaseUsdc,
      );
      expect(a.onRampId, isNot(equals(b.onRampId)));
      expect(a.paymentRef, startsWith('SG-'));
      expect(a.proofId, isNotEmpty);
      expect(a.receiverWallet, equals(kTreasuryWallet));
    });

    test('rejects invalid chain', () {
      final service = SkyGridOnRampService();
      expect(
        () => service.createQuote(
          pathway: 'node_hosting',
          amount: 10,
          chainId: 1,
          tokenAddress: 'eth',
        ),
        throwsArgumentError,
      );
    });

    test('rejects invalid amount', () {
      final service = SkyGridOnRampService();
      expect(
        () => service.createQuote(
          pathway: 'node_hosting',
          amount: 0,
          chainId: 8453,
          tokenAddress: 'eth',
        ),
        throwsArgumentError,
      );
    });

    test('rejects invalid tx hash', () {
      final service = SkyGridOnRampService();
      final quote = service.createQuote(
        pathway: 'node_hosting',
        amount: 12,
        chainId: 8453,
        tokenAddress: 'eth',
      );
      expect(
        () => service.submitTx(quote.onRampId, kTreasuryWallet, '0xdeadbeef'),
        throwsArgumentError,
      );
    });

    test('generates proof packet', () {
      final service = SkyGridOnRampService();
      final quote = service.createQuote(
        pathway: 'node_hosting',
        amount: 22,
        chainId: 8453,
        tokenAddress: kBaseUsdc,
      );
      final tx = '0x${'a' * 64}';
      service.submitTx(quote.onRampId, kTreasuryWallet, tx);
      final proof = service.proofPacket(quote.onRampId);
      expect(proof['onRampId'], equals(quote.onRampId));
      expect(proof['transactionHash'], equals(tx));
      expect(proof['receiverWallet'], equals(kTreasuryWallet));
    });

    test('no private-key exposure in payload', () {
      final service = SkyGridOnRampService();
      final quote = service.createQuote(
        pathway: 'node_hosting',
        amount: 22,
        chainId: 8453,
        tokenAddress: kBaseUsdc,
      );
      final payload = quote.toJson().keys.toList();
      expect(payload, isNot(contains('privateKey')));
      expect(payload, isNot(contains('seedPhrase')));
      expect(payload, isNot(contains('mnemonic')));
    });
  });
}
