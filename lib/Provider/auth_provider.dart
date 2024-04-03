import 'package:flutter/foundation.dart';
import '../token_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  final TokenService _tokenService;

  AuthProvider() : _tokenService = TokenService('http://10.0.2.2:4000/api');

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  Future<void> login(String token) async {
    _token = token;
    await _tokenService.saveToken(token);  // Save token using TokenService
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    await _tokenService.deleteToken();  // Delete token using TokenService
    notifyListeners();
  }

  Future<void> checkTokenValidity() async {
    String? storedToken = await _tokenService.getToken();
    if (storedToken != null && !_tokenService.isTokenExpired(storedToken)) {
      _token = storedToken;
    } else {
      logout();
    }
  }
}