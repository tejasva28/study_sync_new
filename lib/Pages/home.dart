import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/service.dart';
import '../Models/video_model.dart';
import '../Provider/auth_provider.dart';
import '../models/time_scheduling_model.dart';
import 'package:flutter/material.dart';

class MonthDateRow extends StatefulWidget {
  const MonthDateRow({ Key? key }) : super(key: key);
  @override
  State<MonthDateRow> createState() => _MonthDateRowState();
}

class _MonthDateRowState extends State<MonthDateRow> {
  late ApiService _apiService;
  late TokenStorageService _tokenStorageService;
  List<VideoModel>? _videos;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tokenStorageService = TokenStorageService();
    _apiService = ApiService(
      'https://fe00-117-220-236-245.ngrok-free.app/api',
      _tokenStorageService,
    );
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final token = await _tokenStorageService.getToken() ?? '';
      final fetchedVideos = await _apiService.fetchVideos(token);
      setState(() {
        _videos = fetchedVideos.cast<VideoModel>();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
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
  Widget (BuildContext context) {
    if (_isLoading) {
      return _loadingWidget();
    } else if (_errorMessage != null) {
      return _errorWidget();
    } else if (_videos == null || _videos!.isEmpty) {
      return _emptyWidget();
    } else {
      return _videosWidget();
    }
  }

  _loadingWidget() {
    return Scaffold(
      appBar: AppBar(title: Text('Scheduled Videos')),
      body: Center(child: CircularProgressIndicator()),
    );
  }

  _errorWidget() {
    return Scaffold(
      appBar: AppBar(title: Text('Error')),
      body: Center(child: Text(_errorMessage!)),
    );
  }

  _emptyWidget() {
    return Scaffold(
      appBar: AppBar(title: Text('Scheduled Videos')),
      body: Center(child: Text('No scheduled videos found')),
    );
  }

  _videosWidget() {
    final dateList = _getNextDates(20);
    int videoIndex = 0;
    return Scaffold(
      appBar: AppBar(title: Text('Scheduled Videos')),
      body: ListView.builder(
        itemCount: dateList.length,
        itemBuilder: (context, index) {
          final date = dateList[index];
          final video = _videos![videoIndex % _videos!.length];
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

  _buildScheduledVideo(BuildContext context, VideoModel video) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.video_library),
        title: Text(
          video.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(video.videoUrl),
        trailing: Text(DateFormat.jm().format(video.scheduledDate)),
      ),
    );
  }
}
