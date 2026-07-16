import 'dart:convert';

import 'package:http/http.dart' as http;

class PlaidApiException implements Exception {
  PlaidApiException({
    required this.statusCode,
    required this.message,
    this.response,
  });

  final int statusCode;
  final String message;
  final Map<String, dynamic>? response;

  @override
  String toString() {
    return 'PlaidApiException(statusCode: $statusCode, message: $message)';
  }
}

class PlaidLinkToken {
  PlaidLinkToken({
    required this.token,
    this.expiration,
    this.requestId,
  });

  final String token;
  final DateTime? expiration;
  final String? requestId;

  factory PlaidLinkToken.fromJson(Map<String, dynamic> json) {
    return PlaidLinkToken(
      token: json['link_token'] as String,
      expiration: json['expiration'] != null
          ? DateTime.tryParse(json['expiration'] as String)
          : null,
      requestId: json['request_id'] as String?,
    );
  }
}

class PlaidClient {
  PlaidClient({
    required this.baseUrl,
    required this.clientId,
    required this.secret,
    Map<String, String> headers = const {},
    http.Client? httpClient,
  }) : _headers = Map<String, String>.unmodifiable(headers),
        _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String clientId;
  final String secret;
  final http.Client _httpClient;
  final Map<String, String> _headers;

  static const Map<String, String> _jsonHeaders = {
    'content-type': 'application/json',
  };

  Uri _buildUri(String path) {
    final Uri baseUri = Uri.parse(
      baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
    );
    final String resolvedPath = path.startsWith('/') ? path.substring(1) : path;
    return baseUri.resolve(resolvedPath);
  }

  Map<String, String> _buildHeaders() {
    return <String, String>{
      ..._jsonHeaders,
      ..._headers,
    };
  }

  Future<PlaidLinkToken> createLinkToken({
    required String userId,
    required List<String> products,
    String clientName = 'Aura Wallet',
    List<String> countryCodes = const ['US'],
    String language = 'en',
  }) async {
    final response = await _httpClient.post(
      _buildUri('/link/token/create'),
      headers: _buildHeaders(),
      body: jsonEncode(<String, dynamic>{
        'client_id': clientId,
        'secret': secret,
        'client_name': clientName,
        'language': language,
        'country_codes': countryCodes,
        'products': products,
        'user': <String, dynamic>{
          'client_user_id': userId,
        },
      }),
    );

    final Map<String, dynamic> decoded = _decodeResponse(response);
    final String? linkToken = decoded['link_token'] as String?;
    if (linkToken == null || linkToken.isEmpty) {
      throw PlaidApiException(
        statusCode: response.statusCode,
        message: 'Missing link token in Plaid response.',
        response: decoded,
      );
    }

    return PlaidLinkToken.fromJson(decoded);
  }

  Future<String> exchangePublicToken(String publicToken) async {
    final response = await _httpClient.post(
      _buildUri('/item/public_token/exchange'),
      headers: _buildHeaders(),
      body: jsonEncode(<String, dynamic>{
        'client_id': clientId,
        'secret': secret,
        'public_token': publicToken,
      }),
    );

    final Map<String, dynamic> decoded = _decodeResponse(response);
    final String? accessToken = decoded['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw PlaidApiException(
        statusCode: response.statusCode,
        message: 'Missing access token in Plaid response.',
        response: decoded,
      );
    }

    return accessToken;
  }

  Future<List<Map<String, dynamic>>> fetchAccounts(String accessToken) async {
    final response = await _httpClient.post(
      _buildUri('/accounts/get'),
      headers: _buildHeaders(),
      body: jsonEncode(<String, dynamic>{
        'client_id': clientId,
        'secret': secret,
        'access_token': accessToken,
      }),
    );

    final Map<String, dynamic> decoded = _decodeResponse(response);
    final List<dynamic>? accounts = decoded['accounts'] as List<dynamic>?;
    if (accounts == null) {
      throw PlaidApiException(
        statusCode: response.statusCode,
        message: 'Missing accounts array in Plaid response.',
        response: decoded,
      );
    }

    final List<Map<String, dynamic>> accountList = [];
    for (final account in accounts) {
      if (account is Map<String, dynamic>) {
        accountList.add(account);
      } else {
        throw PlaidApiException(
          statusCode: response.statusCode,
          message: 'Unexpected account payload in Plaid response.',
          response: decoded,
        );
      }
    }

    return List<Map<String, dynamic>>.unmodifiable(accountList);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final Object? decodedBody = _tryDecodeJson(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      throw PlaidApiException(
        statusCode: response.statusCode,
        message: 'Unexpected Plaid response payload.',
        response: const {},
      );
    }
    final Map<String, dynamic> decoded = decodedBody;
    if (response.statusCode >= 400) {
      final String errorMessage = decoded['error_message'] as String? ??
          decoded['message'] as String? ??
          'Plaid request failed with status ${response.statusCode}.';
      throw PlaidApiException(
        statusCode: response.statusCode,
        message: errorMessage,
        response: decoded,
      );
    }

    return decoded;
  }

  Object? _tryDecodeJson(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  void close() {
    _httpClient.close();
  }
}
