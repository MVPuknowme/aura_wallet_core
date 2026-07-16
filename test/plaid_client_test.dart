import 'dart:convert';

import 'package:aura_wallet_core/src/integrations/plaid/plaid_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const String baseUrl = 'https://plaid-fork.example.com';
  const String clientId = 'client-id';
  const String secret = 'secret';

  group('PlaidClient', () {
    test('creates link token for provided user id', () async {
      late http.Request capturedRequest;
      final plaidClient = PlaidClient(
        baseUrl: baseUrl,
        clientId: clientId,
        secret: secret,
        headers: const {'plaid-version': '2020-09-14'},
        httpClient: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'link_token': 'token-123',
              'expiration': '2024-01-01T00:00:00Z',
              'request_id': 'req-1',
            }),
            200,
          );
        }),
      );

      final PlaidLinkToken linkToken = await plaidClient.createLinkToken(
        userId: 'user-42',
        products: const ['auth'],
      );

      expect(linkToken.token, 'token-123');
      expect(linkToken.requestId, 'req-1');
      final Map<String, dynamic> payload =
          jsonDecode(capturedRequest.body) as Map<String, dynamic>;
      expect(payload['client_id'], clientId);
      expect(payload['secret'], secret);
      expect(payload['user']['client_user_id'], 'user-42');
      expect(payload['products'], const ['auth']);
      expect(capturedRequest.url.toString(), '$baseUrl/link/token/create');
      expect(capturedRequest.headers['plaid-version'], '2020-09-14');
    });

    test('exchanges public token for access token', () async {
      final plaidClient = PlaidClient(
        baseUrl: baseUrl,
        clientId: clientId,
        secret: secret,
        httpClient: MockClient((request) async {
          expect(request.url.toString(), '$baseUrl/item/public_token/exchange');
          return http.Response(
            jsonEncode(<String, dynamic>{
              'access_token': 'access-123',
            }),
            200,
          );
        }),
      );

      final String accessToken =
          await plaidClient.exchangePublicToken('public-sandbox-1');

      expect(accessToken, 'access-123');
    });

    test('throws PlaidApiException on error responses', () async {
      final plaidClient = PlaidClient(
        baseUrl: baseUrl,
        clientId: clientId,
        secret: secret,
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode(<String, dynamic>{'error_message': 'invalid token'}),
            400,
          );
        }),
      );

      expect(
        () => plaidClient.fetchAccounts('broken-token'),
        throwsA(isA<PlaidApiException>()),
      );
    });

    test('throws PlaidApiException on invalid payloads', () async {
      final plaidClient = PlaidClient(
        baseUrl: baseUrl,
        clientId: clientId,
        secret: secret,
        httpClient: MockClient((request) async {
          return http.Response('not-json', 200);
        }),
      );

      expect(
        () => plaidClient.exchangePublicToken('public-sandbox-1'),
        throwsA(isA<PlaidApiException>()),
      );
    });
  });
}
