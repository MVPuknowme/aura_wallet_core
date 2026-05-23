import 'dart:convert';
import 'dart:math';

const String kTreasuryWallet = '0xbAA5A03bC268546194550a427d3F1d5787c15403';
const int kDefaultChainId = 8453;
const String kDefaultChainName = 'Base Mainnet';
const String kBaseUsdc = '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913';

enum OnRampStatus {
  created,
  quoted,
  awaitingWalletSignature,
  awaitingPayment,
  submitted,
  confirmed,
  expired,
  failed,
}

class OnRampSession {
  OnRampSession({
    required this.onRampId,
    required this.paymentRef,
    required this.proofId,
    required this.pathway,
    required this.chainId,
    required this.chainName,
    required this.receiverWallet,
    required this.tokenSymbol,
    required this.tokenAddress,
    required this.expectedAmount,
    required this.expiresAt,
    required this.status,
    this.fromWallet,
    this.transactionHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  final String onRampId;
  final String paymentRef;
  final String proofId;
  final String pathway;
  final int chainId;
  final String chainName;
  final String receiverWallet;
  final String tokenSymbol;
  final String tokenAddress;
  final double expectedAmount;
  final DateTime expiresAt;
  final DateTime createdAt;
  DateTime updatedAt;
  OnRampStatus status;
  String? fromWallet;
  String? transactionHash;

  Map<String, dynamic> toJson() => {
        'onRampId': onRampId,
        'paymentRef': paymentRef,
        'proofId': proofId,
        'pathway': pathway,
        'chainId': chainId,
        'chainName': chainName,
        'receiverWallet': receiverWallet,
        'tokenSymbol': tokenSymbol,
        'tokenAddress': tokenAddress,
        'expectedAmount': expectedAmount,
        'expiresAt': expiresAt.toUtc().toIso8601String(),
        'status': _statusToApi(status),
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        if (fromWallet != null) 'fromWallet': fromWallet,
        if (transactionHash != null) 'transactionHash': transactionHash,
      };

  static String _statusToApi(OnRampStatus status) {
    switch (status) {
      case OnRampStatus.awaitingWalletSignature:
        return 'awaiting_wallet_signature';
      case OnRampStatus.awaitingPayment:
        return 'awaiting_payment';
      default:
        return status.name;
    }
  }
}

class SkyGridOnRampService {
  final Random _random;
  final Map<String, OnRampSession> _sessions = {};

  SkyGridOnRampService({Random? random}) : _random = random ?? Random.secure();

  OnRampSession createQuote({
    required String pathway,
    required double amount,
    required int chainId,
    required String tokenAddress,
  }) {
    _validate(pathway, amount, chainId, tokenAddress);

    final now = DateTime.now().toUtc();
    final session = OnRampSession(
      onRampId: _makeId('onramp'),
      paymentRef: _makePaymentRef(now),
      proofId: _makeId('proof'),
      pathway: pathway,
      chainId: chainId,
      chainName: kDefaultChainName,
      receiverWallet: kTreasuryWallet,
      tokenSymbol: _resolveTokenSymbol(tokenAddress),
      tokenAddress: tokenAddress,
      expectedAmount: amount,
      expiresAt: now.add(const Duration(minutes: 30)),
      status: OnRampStatus.quoted,
    );

    _sessions[session.onRampId] = session;
    return session;
  }

  OnRampSession submitTx(String onRampId, String fromWallet, String txHash) {
    final session = _sessions[onRampId];
    if (session == null) throw ArgumentError('onRampId not found');
    if (!_isValidHexAddress(fromWallet)) throw ArgumentError('Invalid from wallet');
    if (!_isValidTxHash(txHash)) throw ArgumentError('Invalid txHash');

    session.fromWallet = fromWallet;
    session.transactionHash = txHash;
    session.status = OnRampStatus.submitted;
    session.updatedAt = DateTime.now().toUtc();
    return session;
  }

  Map<String, dynamic> proofPacket(String onRampId) {
    final session = _sessions[onRampId];
    if (session == null) throw ArgumentError('onRampId not found');
    return session.toJson();
  }

  static bool _isValidHexAddress(String value) =>
      RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(value);

  bool _isValidTxHash(String value) => RegExp(r'^0x[a-fA-F0-9]{64}$').hasMatch(value);

  String _resolveTokenSymbol(String tokenAddress) =>
      tokenAddress.toLowerCase() == kBaseUsdc.toLowerCase() ? 'USDC' : 'ETH';

  void _validate(String pathway, double amount, int chainId, String tokenAddress) {
    const supportedPathways = {
      'node_hosting',
      'endpoint_health',
      'contributor_intake',
      'local_failover_support',
      'base_usdc_payment',
      'partner_onboarding',
    };

    if (!supportedPathways.contains(pathway)) throw ArgumentError('Unsupported pathway');
    if (amount <= 0) throw ArgumentError('Amount must be positive');
    if (chainId != kDefaultChainId) throw ArgumentError('Unsupported chainId');

    final normalized = tokenAddress.toLowerCase();
    if (normalized != 'eth' && normalized != kBaseUsdc.toLowerCase()) {
      throw ArgumentError('Unsupported tokenAddress');
    }
  }

  String _makeId(String prefix) {
    final bytes = List<int>.generate(10, (_) => _random.nextInt(256));
    final short = base64Url.encode(bytes).replaceAll('=', '').substring(0, 12);
    return '$prefix-$short';
  }

  String _makePaymentRef(DateTime now) {
    final date =
        '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final short = List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
    return 'SG-$date-$short';
  }
}
