import 'dart:convert';

class ValidatorHeartbeat {
  final String nodeId;
  final String region;
  final String network;
  final String role;
  final double trustScore;
  final String status;
  final DateTime timestamp;
  final int latencyMs;
  final String routeName;

  const ValidatorHeartbeat({
    required this.nodeId,
    required this.region,
    required this.network,
    required this.role,
    required this.trustScore,
    required this.status,
    required this.timestamp,
    required this.latencyMs,
    required this.routeName,
  });

  Map<String, dynamic> toJson() {
    return {
      'node_id': nodeId,
      'region': region,
      'network': network,
      'role': role,
      'trust_score': trustScore,
      'status': status,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'latency_ms': latencyMs,
      'route_name': routeName,
    };
  }
}

class ValidatorHeartbeatService {
  const ValidatorHeartbeatService();

  ValidatorHeartbeat buildStarterHeartbeat({
    required DateTime timestamp,
    required int latencyMs,
  }) {
    return ValidatorHeartbeat(
      nodeId: 'starter-west-01',
      region: 'west-coast',
      network: 'Base',
      role: 'validator',
      trustScore: 0.70,
      status: 'online',
      timestamp: timestamp,
      latencyMs: latencyMs,
      routeName: 'validators/heartbeat',
    );
  }

  String encodeHeartbeat(ValidatorHeartbeat heartbeat) {
    return jsonEncode(heartbeat.toJson());
  }
}
