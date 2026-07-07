enum SkyGridOperatingMode {
  draft,
  validate,
  package,
  execute,
}

class HelmChartStatus {
  final String chartPath;
  final String releaseName;
  final String namespace;
  final bool dryRunRequired;
  final List<String> reviewCommands;

  const HelmChartStatus({
    required this.chartPath,
    required this.releaseName,
    required this.namespace,
    required this.dryRunRequired,
    required this.reviewCommands,
  });

  Map<String, dynamic> toJson() {
    return {
      'chart_path': chartPath,
      'release_name': releaseName,
      'namespace': namespace,
      'dry_run_required': dryRunRequired,
      'review_commands': reviewCommands,
    };
  }
}

class L2ScriptArtifact {
  final String name;
  final String path;
  final String purpose;
  final bool requiresWalletApproval;
  final bool autoExecutes;

  const L2ScriptArtifact({
    required this.name,
    required this.path,
    required this.purpose,
    required this.requiresWalletApproval,
    required this.autoExecutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'purpose': purpose,
      'requires_wallet_approval': requiresWalletApproval,
      'auto_executes': autoExecutes,
    };
  }
}

class SkyGridValidationCheck {
  final String name;
  final String command;
  final bool requiredBeforeExecution;

  const SkyGridValidationCheck({
    required this.name,
    required this.command,
    required this.requiredBeforeExecution,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'command': command,
      'required_before_execution': requiredBeforeExecution,
    };
  }
}

class SkyGridCommandCenterPreview {
  final SkyGridOperatingMode mode;
  final HelmChartStatus helmStatus;
  final List<L2ScriptArtifact> l2Scripts;
  final List<SkyGridValidationCheck> validationChecks;
  final Map<String, dynamic> operatorPayload;
  final bool walletSigningAllowed;
  final bool containsSecrets;

  const SkyGridCommandCenterPreview({
    required this.mode,
    required this.helmStatus,
    required this.l2Scripts,
    required this.validationChecks,
    required this.operatorPayload,
    required this.walletSigningAllowed,
    required this.containsSecrets,
  });

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'helm_status': helmStatus.toJson(),
      'l2_scripts': l2Scripts.map((script) => script.toJson()).toList(),
      'validation_checks':
          validationChecks.map((check) => check.toJson()).toList(),
      'operator_payload': operatorPayload,
      'wallet_signing_allowed': walletSigningAllowed,
      'contains_secrets': containsSecrets,
    };
  }
}

class SkyGridReceiptRecord {
  final String transactionHash;
  final String status;
  final String network;
  final DateTime observedAt;
  final String reviewUrl;

  const SkyGridReceiptRecord({
    required this.transactionHash,
    required this.status,
    required this.network,
    required this.observedAt,
    required this.reviewUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'transaction_hash': transactionHash,
      'status': status,
      'network': network,
      'observed_at': observedAt.toUtc().toIso8601String(),
      'review_url': reviewUrl,
    };
  }
}
