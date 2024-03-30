import '../models/video_model.dart'; // Ensure this path is correct

class Video {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final DateTime scheduledDate;

  Video({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.scheduledDate,
  });

  static fromJson(x) {}
}

class PlaylistSchedule {
  final String playlistLink;
  final String playlistTitle;
  final String thumbnailUrl;
  final DateTime selectedDateTime;
  final List<VideoModel> videos;
  final int videoCount; // Assuming you're keeping track of how many videos are in the playlist
  final Duration totalDuration; // Assuming you're calculating the total duration of all videos`

  PlaylistSchedule({
    required this.playlistLink,
    required this.playlistTitle,
    required this.thumbnailUrl,
    required this.selectedDateTime,
    required this.videoCount,
    required this.totalDuration,
    required this.videos, // Include this in your constructor
  });
}
