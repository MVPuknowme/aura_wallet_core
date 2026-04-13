import 'dart:convert';

class PlaidVerificationPayload {
  final String linkedAccountLabel;
  final String institutionName;
  final String ownershipStatus;
  final String balanceCheckStatus;
  final String payoutCheckStatus;
  final DateTime timestamp;
  final String referenceId;

  const PlaidVerificationPayload({
    required this.linkedAccountLabel,
    required this.institutionName,
    required this.ownershipStatus,
    required this.balanceCheckStatus,
    required this.payoutCheckStatus,
    required this.timestamp,
    required this.referenceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'linked_account_label': linkedAccountLabel,
      'institution_name': institutionName,
      'ownership_status': ownershipStatus,
      'balance_check_status': balanceCheckStatus,
      'payout_check_status': payoutCheckStatus,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'reference_id': referenceId,
    };
  }
}

class PlaidVerificationService {
  const PlaidVerificationService();

  PlaidVerificationPayload buildStarterVerification({
    required DateTime timestamp,
    required String referenceId,
  }) {
    return PlaidVerificationPayload(
      linkedAccountLabel: 'primary-linked-account',
      institutionName: 'linked-institution',
      ownershipStatus: 'verified',
      balanceCheckStatus: 'passed',
      payoutCheckStatus: 'pending_receipt_review',
      timestamp: timestamp,
      referenceId: referenceId,
    );
  }

  String encodeVerification(PlaidVerificationPayload payload) {
    return jsonEncode(payload.toJson());
  }
}
