import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/service.dart';
import '../Models/video_model.dart';
import '../Provider/auth_provider.dart';
import '../models/time_scheduling_model.dart';

class MonthDateRow extends StatefulWidget {
  @override
  _MonthDateRowState createState() => _MonthDateRowState();
}

class _MonthDateRowState extends State<MonthDateRow> {
  List<VideoModel>? videos;
  bool isLoading = true;
  String? errorMessage;
  late ApiService _apiService;
  late TokenStorageService _tokenStorageService;

  @override
  void initState() {
    super.initState();
    _tokenStorageService = TokenStorageService();
    _apiService = ApiService('https://fe00-117-220-236-245.ngrok-free.app/api',
        _tokenStorageService);
    fetchData();
  }
  

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await _tokenStorageService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }
      final fetchedVideos = await _apiService.fetchVideos();

       // Debug print for checking video titles
    for (var video in fetchedVideos) {
        print("Video title: ${video.title}");
    }
      setState(() {
        videos = fetchedVideos.cast<VideoModel>();
        print("Videos fetched: ${fetchedVideos.length}");
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  List<DateTime> _getNextDates(int count) {
    return List.generate(
        count, (index) => DateTime.now().add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Scheduled Videos')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text(errorMessage!)),
      );
    }

    if (videos == null || videos!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Scheduled Videos')),
        body: Center(child: Text('No scheduled videos found')),
      );
    }

    List<DateTime> dateList = _getNextDates(20);
    int videoIndex = 0;

    return Scaffold(
      appBar: AppBar(title: Text('Scheduled Videos')),
      body: ListView.builder(
        itemCount: dateList.length,
        itemBuilder: (context, index) {
          DateTime date = dateList[index];
          VideoModel video = videos![videoIndex % videos!.length];
          videoIndex++;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  DateFormat('EEEE, MMMM d').format(date),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildScheduledVideo(context, video),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScheduledVideo(BuildContext context, VideoModel video) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.video_library),
        title: Text(video.title,
            style: TextStyle(
                fontWeight: FontWeight.bold)), // Ensure title is displayed
        subtitle: Text(video.videoUrl),
        trailing: Text(DateFormat.jm().format(video.scheduledDate)),
      ),
    );
  }
  
  
}
