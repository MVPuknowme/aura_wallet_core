import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:aura_wallet_core/src/core/services/plaid_verification_service.dart';

void main() {
  test('builds starter Plaid verification payload', () {
    const service = PlaidVerificationService();
    final payload = service.buildStarterVerification(
      timestamp: DateTime.parse('2026-04-13T16:10:00.000Z'),
      referenceId: 'adf6c277ad0c3455',
    );

    expect(payload.linkedAccountLabel, 'primary-linked-account');
    expect(payload.institutionName, 'linked-institution');
    expect(payload.ownershipStatus, 'verified');
    expect(payload.balanceCheckStatus, 'passed');
    expect(payload.payoutCheckStatus, 'pending_receipt_review');
    expect(payload.referenceId, 'adf6c277ad0c3455');

    final encoded = service.encodeVerification(payload);
    final decoded = jsonDecode(encoded) as Map<String, dynamic>;

    expect(decoded['linked_account_label'], 'primary-linked-account');
    expect(decoded['ownership_status'], 'verified');
    expect(decoded['balance_check_status'], 'passed');
    expect(decoded['payout_check_status'], 'pending_receipt_review');
    expect(decoded['reference_id'], 'adf6c277ad0c3455');
  });
}
