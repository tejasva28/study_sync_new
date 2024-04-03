import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String authApiUrl;

  TokenService(this.authApiUrl);

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token');
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = base64Url.decode(normalized);
      final payloadMap = json.decode(utf8.decode(resp));

      if (payloadMap is! Map<String, dynamic>) {
        throw Exception('Invalid payload');
      }

      final exp = payloadMap['exp'];
      if (exp is! int) {
        throw Exception('Invalid expiration time');
      }

      final currentTime = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      return currentTime >= exp;
    } catch (e) {
      print('Error checking token expiry: $e');
      return true; // Assume expired on error to prevent unauthorized access
    }
  }

  Future<void> refreshToken() async {
    try {
      String? refreshToken =
          await getToken(); // Assume refresh token is stored as a token, change as needed
      final response = await http.post(
        Uri.parse('$authApiUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final String? newToken = json.decode(response.body)['token'];
        if (newToken != null) {
          await saveToken(newToken);
        }
      } else {
        print('Token refresh failed: ${response.body}');
      }
    } catch (error) {
      print('Token refresh error: $error');
    }
  }
}
