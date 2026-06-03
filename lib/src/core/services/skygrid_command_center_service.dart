import '../type_data/skygrid_dashboard_models.dart';

class SkyGridCommandCenterService {
  static const List<String> _secretIndicators = <String>[
    'private_key',
    'privatekey',
    'secret',
    'mnemonic',
    'api_key',
    'apikey',
    'password',
    'token',
  ];

  const SkyGridCommandCenterService();

  SkyGridCommandCenterPreview buildPreview({
    SkyGridOperatingMode mode = SkyGridOperatingMode.draft,
    Map<String, dynamic> operatorIntent = const <String, dynamic>{},
  }) {
    final payload = _redactSensitiveValues(operatorIntent);

    return SkyGridCommandCenterPreview(
      mode: mode,
      helmStatus: const HelmChartStatus(
        chartPath: 'helm/aura-core-autodrill',
        releaseName: 'aura-core-autodrill',
        namespace: 'aura-core',
        dryRunRequired: true,
        reviewCommands: <String>[
          'helm lint helm/aura-core-autodrill',
          'helm template aura-core-autodrill helm/aura-core-autodrill --namespace aura-core',
          'kubectl apply --dry-run=server -f <rendered-manifest.yaml>',
        ],
      ),
      l2Scripts: const <L2ScriptArtifact>[
        L2ScriptArtifact(
          name: 'prepareRoute',
          path: 'scripts/l2/prepareRoute.js',
          purpose: 'Builds a reviewable L2 route intent without submitting it.',
          requiresWalletApproval: false,
          autoExecutes: false,
        ),
        L2ScriptArtifact(
          name: 'signIntent',
          path: 'scripts/l2/signIntent.js',
          purpose: 'Requests explicit wallet signature for a reviewed intent.',
          requiresWalletApproval: true,
          autoExecutes: false,
        ),
        L2ScriptArtifact(
          name: 'submitIntent',
          path: 'scripts/l2/submitIntent.js',
          purpose: 'Submits only an already signed transaction package.',
          requiresWalletApproval: true,
          autoExecutes: false,
        ),
        L2ScriptArtifact(
          name: 'verifyReceipt',
          path: 'scripts/l2/verifyReceipt.js',
          purpose: 'Verifies and formats transaction receipts for dashboard review.',
          requiresWalletApproval: false,
          autoExecutes: false,
        ),
      ],
      validationChecks: const <SkyGridValidationCheck>[
        SkyGridValidationCheck(
          name: 'Helm lint',
          command: 'helm lint helm/aura-core-autodrill',
          requiredBeforeExecution: true,
        ),
        SkyGridValidationCheck(
          name: 'Helm render',
          command:
              'helm template aura-core-autodrill helm/aura-core-autodrill --namespace aura-core',
          requiredBeforeExecution: true,
        ),
        SkyGridValidationCheck(
          name: 'Kubernetes dry run',
          command: 'kubectl apply --dry-run=server -f <rendered-manifest.yaml>',
          requiredBeforeExecution: true,
        ),
        SkyGridValidationCheck(
          name: 'L2 payload review',
          command: 'node scripts/l2/prepareRoute.js --review-only',
          requiredBeforeExecution: true,
        ),
      ],
      operatorPayload: payload,
      walletSigningAllowed: mode == SkyGridOperatingMode.execute,
      containsSecrets: _containsSensitiveKey(operatorIntent),
    );
  }

  SkyGridReceiptRecord buildReceiptRecord({
    required String transactionHash,
    required String status,
    required String network,
    required DateTime observedAt,
    String reviewUrl = '',
  }) {
    return SkyGridReceiptRecord(
      transactionHash: transactionHash,
      status: status,
      network: network,
      observedAt: observedAt,
      reviewUrl: reviewUrl,
    );
  }

  Map<String, dynamic> _redactSensitiveValues(Map<String, dynamic> payload) {
    return payload.map((key, value) {
      if (_isSensitiveKey(key)) {
        return MapEntry(key, '[REDACTED]');
      }

      if (value is Map<String, dynamic>) {
        return MapEntry(key, _redactSensitiveValues(value));
      }

      return MapEntry(key, value);
    });
  }

  bool _containsSensitiveKey(Map<String, dynamic> payload) {
    for (final entry in payload.entries) {
      if (_isSensitiveKey(entry.key)) {
        return true;
      }

      final value = entry.value;
      if (value is Map<String, dynamic> && _containsSensitiveKey(value)) {
        return true;
      }
    }

    return false;
  }

  bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll('-', '_');
    return _secretIndicators.any(normalized.contains);
  }
}
