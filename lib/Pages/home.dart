import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/video_model.dart'; // Make sure this import is correct
import '../models/time_scheduling_model.dart'; // Ensure you have this model

class MonthDateRow extends StatelessWidget {
  final List<PlaylistSchedule> playlistSchedules;

  const MonthDateRow({Key? key, required this.playlistSchedules})
      : super(key: key);

  Widget _buildScheduledVideo(BuildContext context, VideoModel video) {
    // Default text for when scheduledDate is null
    String scheduledTimeText = 'No scheduled time';

    // Check if scheduledDate is not null before formatting
    if (video.scheduledDate != null) {
      scheduledTimeText = DateFormat.jm().format(video.scheduledDate!);
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.video_library),
        title: Text(video.title),
        subtitle: Text(video.videoUrl), // Display video URL or other detail
        trailing: Text(scheduledTimeText), // Use the conditionally set text
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Schedule'),
        backgroundColor: Colors.blue,
      ),
      body: playlistSchedules.isNotEmpty
          ? ListView.builder(
              itemCount: playlistSchedules.length,
              itemBuilder: (context, index) {
                final schedule = playlistSchedules[index];
                return ExpansionTile(
                  title: Text(schedule.playlistTitle),
                  subtitle: Text(DateFormat('yyyy-MM-dd')
                      .format(schedule.selectedDateTime)),
                  children: schedule.videos
                      .map((video) => _buildScheduledVideo(context, video))
                      .toList(),
                );
              },
            )
          : Center(
              child: Text('No schedules found'),
            ),
    );
  }
}

// Assuming PlaylistSchedule is a model class that looks something like this:
class Playlist_Schedule {
  final String playlistTitle;
  final DateTime selectedDateTime;
  final List<VideoModel> videos;

  Playlist_Schedule({
    required this.playlistTitle,
    required this.selectedDateTime,
    required this.videos,
  });
}

void main() {
  runApp(MaterialApp(
    home: MonthDateRow(playlistSchedules: []), // Example usage
  ));
}
