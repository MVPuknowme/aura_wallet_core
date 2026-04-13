import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:aura_wallet_core/src/core/services/validator_heartbeat_service.dart';

void main() {
  test('builds starter validator heartbeat payload', () {
    const service = ValidatorHeartbeatService();
    final heartbeat = service.buildStarterHeartbeat(
      timestamp: DateTime.parse('2026-04-13T08:15:00.000Z'),
      latencyMs: 238,
    );

    expect(heartbeat.nodeId, 'starter-west-01');
    expect(heartbeat.region, 'west-coast');
    expect(heartbeat.network, 'Base');
    expect(heartbeat.role, 'validator');
    expect(heartbeat.trustScore, 0.70);
    expect(heartbeat.status, 'online');
    expect(heartbeat.latencyMs, 238);
    expect(heartbeat.routeName, 'validators/heartbeat');

    final encoded = service.encodeHeartbeat(heartbeat);
    final decoded = jsonDecode(encoded) as Map<String, dynamic>;

    expect(decoded['node_id'], 'starter-west-01');
    expect(decoded['status'], 'online');
    expect(decoded['latency_ms'], 238);
    expect(decoded['route_name'], 'validators/heartbeat');
  });
}
