from pathlib import Path

path = Path("lib/src/entities/aura_wallet_impl.dart")
text = path.read_text(encoding="utf-8")
marker = "  @override\n  Future<bool> verifyTxHash({required String txHash}) async {"
start = text.index(marker)
class_close = text.rfind("\n}")
if class_close <= start:
    raise RuntimeError("Could not locate AuraWalletImpl class closing brace")

replacement = r'''  @override
  Future<bool> verifyTxHash({required String txHash}) async {
    final String baseUrl = AuraWalletUtil.getBaseUrl(environment);
    final String chainId = AuraWalletUtil.getChainId(environment);
    final HttpClient client = HttpClient();

    try {
      final Uri uri = Uri.parse('$baseUrl/api/v1/transaction').replace(
        queryParameters: <String, String>{
          'txHash': txHash,
          'chainid': chainId,
        },
      );
      final HttpClientRequest request = await client.getUrl(uri);
      final HttpClientResponse response = await request.close();
      final String body = await response.transform(utf8.decoder).join();

      if (response.statusCode != HttpStatus.ok) {
        final String compactBody = body.replaceAll(RegExp(r'\s+'), ' ').trim();
        final String bodySummary = compactBody.length > 256
            ? '${compactBody.substring(0, 256)}...'
            : compactBody;
        throw AuraInternalError(
          ErrorCode.TransactionVerificationError,
          'Unexpected status code: ${response.statusCode}. Body: $bodySummary',
        );
      }

      final dynamic decoded;
      try {
        decoded = jsonDecode(body);
      } on FormatException catch (error) {
        throw AuraInternalError(
          ErrorCode.TransactionVerificationError,
          'Invalid JSON response: ${error.message}',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw AuraInternalError(
          ErrorCode.TransactionVerificationError,
          'Invalid response format: expected object',
        );
      }

      final dynamic data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw AuraInternalError(
          ErrorCode.TransactionVerificationError,
          'Invalid response format: missing data object',
        );
      }

      final dynamic transactions = data['transactions'];
      if (transactions is! List<dynamic>) {
        throw AuraInternalError(
          ErrorCode.TransactionVerificationError,
          'Invalid response format: transactions must be a list',
        );
      }
      if (transactions.isEmpty) {
        throw AuraInternalError(
          ErrorCode.NoTransactionsFound,
          'No transactions found',
        );
      }

      final dynamic first = transactions.first;
      if (first is! Map<String, dynamic>) {
        throw AuraInternalError(
          ErrorCode.TransactionVerificationError,
          'Invalid response format: transaction is not an object',
        );
      }

      final dynamic txResponse = first['tx_response'];
      if (txResponse is! Map<String, dynamic>) {
        throw AuraInternalError(
          ErrorCode.TransactionVerificationError,
          'Invalid response format: missing tx_response object',
        );
      }

      final dynamic code = txResponse['code'];
      if (code is int) {
        return code == 0;
      }
      if (code is String) {
        return code == '0';
      }

      throw AuraInternalError(
        ErrorCode.TransactionVerificationError,
        'Invalid response format: unexpected code value',
      );
    } on AuraInternalError {
      rethrow;
    } catch (error) {
      final String errorMessage = error is PlatformException
          ? '[${error.code}] ${error.message}'
          : error.toString();
      throw AuraInternalError(
        ErrorCode.TransactionVerificationError,
        errorMessage,
      );
    } finally {
      client.close(force: true);
    }
  }
'''

path.write_text(text[:start] + replacement + text[class_close:], encoding="utf-8")

test_path = Path("test/transaction_verification_test.dart")
test_text = test_path.read_text(encoding="utf-8")
invalid_test = "      final String body = '${'A' * 300}SENSITIVE_TAIL';"
valid_test = "      final String body = \"${List<String>.filled(300, 'A').join()}SENSITIVE_TAIL\";"
if invalid_test not in test_text:
    raise RuntimeError("Could not locate transaction test body generator")
test_text = test_text.replace(invalid_test, valid_test)
fixture_before = "final AuraWalletImpl _wallet = AuraWalletImpl("
fixture_after = "const AuraWalletImpl _wallet = AuraWalletImpl("
if fixture_before not in test_text:
    raise RuntimeError("Could not locate transaction test wallet fixture")
test_path.write_text(test_text.replace(fixture_before, fixture_after), encoding="utf-8")
