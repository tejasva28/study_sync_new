import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_sync/Pages/video_add.dart';
import 'package:study_sync/service.dart';
import 'package:study_sync/token_service.dart';
import '../Models/video_model.dart';

class MonthDateRow extends StatefulWidget {
  const MonthDateRow({Key? key}) : super(key: key);

  @override
  _MonthDateRowState createState() => _MonthDateRowState();
}

class _MonthDateRowState extends State<MonthDateRow> {
  late ApiService _apiService;
  late TokenService _tokenStorageService;
  List<VideoModel>? videos;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tokenStorageService = TokenService('http://10.0.2.2:4000/api');
    _apiService = ApiService('http://10.0.2.2:4000/api', _tokenStorageService);
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      String? token = await _tokenStorageService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }
      List<VideoModel> fetchedVideos = await _apiService.fetchVideos();
      setState(() {
        videos = fetchedVideos;
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
      count,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _loadingWidget();
    } else if (errorMessage != null) {
      return _errorWidget();
    } else if (videos == null || videos!.isEmpty) {
      return _emptyWidget();
    } else {
      return _videosWidget();
    }
  }

  Widget _loadingWidget() {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled Videos')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _errorWidget() {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage!,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _emptyWidget() {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled Videos')),
      body: const Center(child: Text('No scheduled videos found')),
    );
  }

  Widget _videosWidget() {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled Videos')),
      body: ListView.builder(
        itemCount: videos?.length ?? 0,
        itemBuilder: (context, index) {
          final video = videos![index];
          return _buildScheduledVideo(context, video);
        },
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VideoAdd()), // Replace `VideoAddPage` with the actual class name of your add video page
        );
      },
      child: const Icon(Icons.add),
      tooltip: 'Add Video',
    ),
  );
  }

  Widget _buildScheduledVideo(BuildContext context, VideoModel video) {
    // Assume video.duration is an int representing seconds; convert it to a Duration object
    String formattedDuration = formatDuration(video.duration);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      clipBehavior: Clip.antiAlias, // Added for better UI effect
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            video.thumbnailUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              video.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              "${DateFormat('MMM d, yyyy').format(video.scheduledDate)} - $formattedDuration",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}h ${twoDigitMinutes}m";
    } else {
      return "${twoDigitMinutes}m ${twoDigitSeconds}s";
    }
  }
}
