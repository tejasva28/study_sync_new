import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/video_model.dart';
import 'token_service.dart';

class ApiService {
  String apiURL;
  final TokenService tokenService;

  init() {
    apiURL = "http://10.0.2.2:4000/api";
  }

  ApiService(this.apiURL, this.tokenService);

  Future<String?> login(String email, String password) async {
    await init();
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

  Future<List<VideoModel>> fetchVideos({required int page}) async {
    await init();
    try {
      String? token = await tokenService.getToken();
      if (token == null) {
        throw Exception('Token not found or expired');
      }

      final response = await http.get(
        Uri.parse('$apiURL/playlistSchedule/videos?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> videosData = jsonDecode(response.body);
        // Directly mapping the list to VideoModel objects
        return videosData
            .map<VideoModel>(
                (item) => VideoModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch videos. Server responded with ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load videos: $e');
    }
  }

  Future<bool> createSchedule(String playlistLink, String scheduleTime) async {
    await init();
    print("$playlistLink $scheduleTime");
    try {
      String? token = await tokenService.getToken();
      if (token == null) {
        print('Token not found or expired');
        return false;
      }

      final response = await http.post(
        Uri.parse('$apiURL/playlistSchedule/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'playlistLink': playlistLink,
          'scheduleTime': scheduleTime,
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create schedule: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error creating schedule: $error');
      return false;
    }
  }
}
