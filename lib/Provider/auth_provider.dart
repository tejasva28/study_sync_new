import 'package:flutter/foundation.dart';
import '../token_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  final TokenService _tokenService = TokenService('http://10.0.2.2:4000/api');

  AuthProvider() {
    initializeAuth();
    print(_token);
  }

  Future<void> initializeAuth() async {
    String? storedToken = await _tokenService.getToken();
    if (storedToken != null && !_tokenService.isTokenExpired(storedToken)) {
      _token = storedToken;
      notifyListeners();
    } else if (storedToken != null) {
      await _tokenService.refreshToken();
      _token = await _tokenService.getToken(); // Update token after refresh
      notifyListeners();
    }
  }

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  Future<void> login(String token) async {
    _token = token;
    await _tokenService.saveToken(token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    await _tokenService.deleteToken();
    notifyListeners();
  }
}
