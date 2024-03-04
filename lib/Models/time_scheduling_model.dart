import '../models/video_model.dart';

class PlaylistSchedule {
  final String playlistLink;
  final String playlistTitle;
  final String thumbnailUrl;
  final DateTime selectedDateTime;
  final int videoCount;
  final Duration totalDuration;
  final List<VideoModel> videos;

  PlaylistSchedule({
    required this.playlistLink,
    required this.playlistTitle,
    required this.thumbnailUrl,
    required this.selectedDateTime,
    required this.videoCount,
    required this.totalDuration,
    required this.videos,
  });

  factory PlaylistSchedule.fromJson(Map<String, dynamic> json) {
    var durationSeconds = json['totalDuration'] as int; // Assuming the total duration in seconds is directly available
    List<VideoModel> videosList = (json['videos'] as List)
        .map((videoJson) => VideoModel.fromJson(videoJson))
        .toList();

    return PlaylistSchedule(
      playlistLink: json['playlistLink'],
      playlistTitle: json['playlistTitle'],
      thumbnailUrl: json['thumbnailUrl'],
      selectedDateTime: DateTime.parse(json['selectedDateTime']),
      videoCount: json['videoCount'],
      totalDuration: Duration(seconds: durationSeconds),
      videos: videosList,
    );
  }
}
