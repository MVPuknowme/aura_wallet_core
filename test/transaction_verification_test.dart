import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aura_wallet_core/aura_environment.dart';
import 'package:aura_wallet_core/src/constants/error_constants.dart';
import 'package:aura_wallet_core/src/core/exceptions/aura_internal_exception.dart';
import 'package:aura_wallet_core/src/entities/aura_wallet_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _FakeHttpClientResponse(this.statusCode, String body)
    : _bytes = utf8.encode(body);

  @override
  final int statusCode;
  final List<int> _bytes;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_bytes).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this.response);

  final HttpClientResponse response;

  @override
  Future<HttpClientResponse> close() async => response;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
  Uri? requestedUri;
  bool closed = false;
  bool forceClosed = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    requestedUri = url;
    return _FakeHttpClientRequest(_FakeHttpClientResponse(statusCode, body));
  }

  @override
  void close({bool force = false}) {
    closed = true;
    forceClosed = force;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const AuraWalletImpl _wallet = AuraWalletImpl(
  walletName: 'test-wallet',
  bech32Address: 'aura1testaddress',
  environment: AuraWalletCoreEnvironment.mainNet,
);

Future<({bool? value, AuraInternalError? error, _FakeHttpClient client})>
_verify({
  required String body,
  int statusCode = HttpStatus.ok,
  String txHash = 'ABC123',
}) async {
  final _FakeHttpClient client = _FakeHttpClient(
    statusCode: statusCode,
    body: body,
  );

  bool? value;
  AuraInternalError? error;
  try {
    value = await HttpOverrides.runZoned(
      () => _wallet.verifyTxHash(txHash: txHash),
      createHttpClient: (_) => client,
    );
  } on AuraInternalError catch (caught) {
    error = caught;
  }

  expect(client.closed, isTrue, reason: 'HttpClient must always close');
  expect(client.forceClosed, isTrue, reason: 'HttpClient must force close');
  return (value: value, error: error, client: client);
}

String _responseWithCode(Object code) => jsonEncode(<String, Object>{
  'data': <String, Object>{
    'transactions': <Object>[
      <String, Object>{
        'tx_response': <String, Object>{'code': code},
      },
    ],
  },
});

void main() {
  group('AuraWalletImpl.verifyTxHash', () {
    test('accepts integer success code', () async {
      final result = await _verify(body: _responseWithCode(0));
      expect(result.error, isNull);
      expect(result.value, isTrue);
    });

    test('accepts string success code', () async {
      final result = await _verify(body: _responseWithCode('0'));
      expect(result.error, isNull);
      expect(result.value, isTrue);
    });

    test('returns false for nonzero integer and string codes', () async {
      final integerResult = await _verify(body: _responseWithCode(7));
      final stringResult = await _verify(body: _responseWithCode('7'));
      expect(integerResult.error, isNull);
      expect(integerResult.value, isFalse);
      expect(stringResult.error, isNull);
      expect(stringResult.value, isFalse);
    });

    test('encodes tx hash and chain id as query parameters', () async {
      const String txHash = 'hash /?&=雪';
      final result = await _verify(body: _responseWithCode(0), txHash: txHash);
      expect(result.error, isNull);
      expect(result.client.requestedUri?.queryParameters['txHash'], txHash);
      expect(
        result.client.requestedUri?.queryParameters['chainid'],
        'xstaxy-1',
      );
    });

    test('rejects non-200 responses with a bounded body summary', () async {
      final String body =
          "${List<String>.filled(300, 'A').join()}SENSITIVE_TAIL";
      final result = await _verify(
        body: body,
        statusCode: HttpStatus.internalServerError,
      );
      expect(result.error?.errorCode, ErrorCode.TransactionVerificationError);
      expect(result.error?.message, contains('Unexpected status code: 500'));
      expect(result.error?.message, isNot(contains('SENSITIVE_TAIL')));
      expect(result.error!.message.length, lessThan(340));
    });

    test('rejects malformed JSON and top-level non-object JSON', () async {
      final malformed = await _verify(body: '{');
      final list = await _verify(body: '[]');
      expect(
        malformed.error?.errorCode,
        ErrorCode.TransactionVerificationError,
      );
      expect(malformed.error?.message, contains('Invalid JSON response'));
      expect(list.error?.errorCode, ErrorCode.TransactionVerificationError);
      expect(list.error?.message, contains('expected object'));
    });

    test('rejects missing or malformed data', () async {
      final missing = await _verify(body: '{}');
      final malformed = await _verify(body: '{"data":[]}');
      expect(missing.error?.errorCode, ErrorCode.TransactionVerificationError);
      expect(
        malformed.error?.errorCode,
        ErrorCode.TransactionVerificationError,
      );
    });

    test('distinguishes malformed transactions from no transactions', () async {
      final malformed = await _verify(body: '{"data":{"transactions":{}}}');
      final empty = await _verify(body: '{"data":{"transactions":[]}}');
      expect(
        malformed.error?.errorCode,
        ErrorCode.TransactionVerificationError,
      );
      expect(empty.error?.errorCode, ErrorCode.NoTransactionsFound);
    });

    test('rejects malformed transaction and tx_response objects', () async {
      final transaction = await _verify(
        body: '{"data":{"transactions":["bad"]}}',
      );
      final response = await _verify(
        body: '{"data":{"transactions":[{"tx_response":[]}]}}',
      );
      expect(
        transaction.error?.errorCode,
        ErrorCode.TransactionVerificationError,
      );
      expect(response.error?.errorCode, ErrorCode.TransactionVerificationError);
    });

    test('rejects unexpected code types', () async {
      final result = await _verify(
        body: '{"data":{"transactions":[{"tx_response":{"code":true}}]}}',
      );
      expect(result.error?.errorCode, ErrorCode.TransactionVerificationError);
      expect(result.error?.message, contains('unexpected code value'));
    });
  });
}
