class PaymentProcessingRules {
  final bool plaidBridgeReady;
  final bool mvpUknowMeAttached;
  final bool paymentsEnabled;
  final String? ruleNotes;

  const PaymentProcessingRules({
    this.plaidBridgeReady = true,
    this.mvpUknowMeAttached = true,
    this.paymentsEnabled = true,
    this.ruleNotes,
  });

  bool get canProcessPayments =>
      plaidBridgeReady && mvpUknowMeAttached && paymentsEnabled;

  String? validationErrorMessage({String? context}) {
    if (canProcessPayments) {
      return null;
    }

    final List<String> unmetRules = [];
    if (!plaidBridgeReady) {
      unmetRules.add('Plaid bridge is not verified as healthy');
    }
    if (!mvpUknowMeAttached) {
      unmetRules.add('Aura wallet is not attached to MVPuknowme');
    }
    if (!paymentsEnabled) {
      unmetRules.add('Payment processing has been explicitly disabled');
    }

    final String scope = context != null ? '$context: ' : '';
    final String noteText =
        ruleNotes != null && ruleNotes!.isNotEmpty ? ' ($ruleNotes)' : '';

    return '$scope${unmetRules.join('; ')}$noteText'.trim();
  }
}
