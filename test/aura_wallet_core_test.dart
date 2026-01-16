
import 'package:aura_wallet_core/aura_environment.dart';
import 'package:aura_wallet_core/src/core/repo/store_house.dart';
import 'package:aura_wallet_core/src/entities/aura_wallet_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockStorehouse extends Mock implements Storehouse {}

void main() {
  group('AuraWalletImpl Tests', () {
    late AuraWalletImpl wallet;
    late MockStorehouse mockStorehouse;
    late MockNetworkInfo mockNetworkInfo;
    late MockTxSender mockTxSender;
    late MockServiceClient mockServiceClient;
    late MockGetTxsEventResponse mockGetTxsEventResponse;

    setUp(() {
      mockStorehouse = MockStorehouse();
      mockNetworkInfo = MockNetworkInfo();
      mockTxSender = MockTxSender();
      mockServiceClient = MockServiceClient();
      mockGetTxsEventResponse = MockGetTxsEventResponse();
    });

    test('Test submitTransaction', () async {});

    test('Test checkWalletBalance', () async {});
}

class Network extends implements NetworkInfo {}

class MockTxSender extends implements TxSender {}

class MockServiceClient extends  implements ServiceClient {true}

class MockGetTxsEventResponse implements GetTxsEventResponse {true}

