import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/video_model.dart';
// Adjust the import according to your file structure
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_service.dart';

class ApiService {
  final String apiURL;
  final TokenService tokenService;

  ApiService(this.apiURL, this.tokenService);

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
          await tokenService.saveToken(token);
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

  Future<List<VideoModel>> fetchVideos() async {
    try {
        String? token = await tokenService.getToken();
        if (token == null) {
            throw Exception('Token not found or expired');
        }

        final response = await http.get(
            Uri.parse('$apiURL/playlistSchedule/videos'),
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
            },
        );

        if (response.statusCode == 200) {
            List<dynamic> videosData = jsonDecode(response.body);
            // Directly mapping the list to VideoModel objects
            return videosData.map<VideoModel>((item) => VideoModel.fromJson(item as Map<String, dynamic>)).toList();
        } else {
            throw Exception('Failed to fetch videos. Server responded with ${response.statusCode}');
        }
    } catch (e) {
        throw Exception('Failed to load videos: $e');
    }
}

}
