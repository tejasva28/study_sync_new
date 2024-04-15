import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_sync/Pages/video_add.dart';
import 'package:study_sync/Pages/video_page.dart';
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
  List<VideoModel> videos = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  String? errorMessage;
  int currentPage = 1;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tokenStorageService = TokenService('http://10.0.2.2:4000/api');
    _apiService = ApiService('http://10.0.2.2:4000/api', _tokenStorageService);
    _fetchData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchData({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      videos.clear();
    }
    try {
      String? token = await _tokenStorageService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }
      List<VideoModel> fetchedVideos =
          await _apiService.fetchVideos(page: currentPage);
      setState(() {
        currentPage++;
        videos.addAll(fetchedVideos);
        isLoading = false;
        isFetchingMore = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        isFetchingMore = false;
        errorMessage = error.toString();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isFetchingMore) {
      setState(() => isFetchingMore = true);
      _fetchData();
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

  Widget _videosWidget() {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled Videos')),
      body: RefreshIndicator(
        onRefresh: () => _fetchData(isRefresh: true),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: videos.length + (isFetchingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= videos.length) {
              return Center(child: CircularProgressIndicator());
            }
            final video = videos[index];
            return _buildScheduledVideo(context, video);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoAdd(),
            ),
          );
        },
        tooltip: 'Add Video',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _emptyWidget() {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled Videos')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No scheduled videos found'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoAdd(),
                  ),
                );
              },
              child: const Text('Add Video'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledVideo(BuildContext context, VideoModel video) {
    // Assume video.duration is an int representing seconds; convert it to a Duration object
    String formattedDuration = formatDuration(video.duration);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDetailsPage(video: video),
          ),
        );
      },
      child: Card(
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
