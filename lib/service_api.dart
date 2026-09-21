import 'dart:convert';
import 'package:http/http.dart' as http;

class ServiceApi {
  static const String baseUrl = 'https://dummyjson.com';

  /// Generic GET request
  static Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, String>? queryParams,
      }) async {
    final uri = Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = response.body.trim();

      if (body.isEmpty) {
        throw Exception('API returned an empty response.');
      }

      if (body.startsWith('<')) {
        throw Exception(
          'API returned an unexpected HTML response.',
        );
      }

      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Unexpected API response format.');
    }

    throw Exception(
      'GET $endpoint failed '
          '(${response.statusCode}): ${response.body}',
    );
  }
}
