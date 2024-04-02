import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Models/video_model.dart';
import 'Provider/auth_provider.dart'; // Adjust the import according to your file structure
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// TokenStorageService manages the storage of the token securely
class TokenStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

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
}

class ApiService {
  final String apiURL;
  final TokenStorageService tokenStorageService;

  ApiService(this.apiURL, this.tokenStorageService);

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiURL/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final String? token = json.decode(response.body)['token'];
        if (token != null) {
          await tokenStorageService.saveToken(token);
        }
        return token;
      } else {
        print('Login failed: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Login error: $error');
      return null;
    }
  }

  Future<List<VideoModel>> fetchVideos(String token) async {
    String? token = await tokenStorageService.getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await http.get(
        Uri.parse('$apiURL/playlistSchedule/videos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => VideoModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch videos. Server responded with ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load videos: $e');
    }
  }
}

// class ApiService {
//   final String apiURL = 'http://10.0.2.2:4000/api';
//   //BuildContext context;

//   ApiService(this.apiURL);

//   Future<String?> login(String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$apiURL/auth/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'email': email, 'password': password}),
//       );

//       if (response.statusCode == 200) {
//         final token = json.decode(response.body)['token'];
//         if (token != null) {
//           // Save the token using AuthProvider
//           final authProvider =
//               Provider.of<AuthProvider>(context, listen: false);
//           authProvider.login(token);
//           print('Login successful');
//           return token;
//         }
//         return null;
//       } else {
//         print('Login failed: ${response.body}');
//         return null;
//       }
//     } catch (error) {
//       print('Login error: $error');
//       return null;
//     }
//   }

//   Future<List<VideoModel>> fetchVideos(String token) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$apiURL/videos'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         List<dynamic> body = jsonDecode(response.body);
//         return body.map((dynamic item) => VideoModel.fromJson(item)).toList();
//       } else {
//         throw Exception('Failed to fetch videos. Server responded with ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load videos: $e');
//     }
//   }
// }
