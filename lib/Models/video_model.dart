class VideoModel {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final Duration duration;
  final DateTime scheduledDate;

  VideoModel({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.scheduledDate,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    var durationSeconds = json['duration'] as int? ?? 0;
    DateTime parsedDate;

    try {
      // Ensure the scheduledDate includes time
      parsedDate = DateTime.parse(json['scheduledDate'] ?? '2000-01-01T00:00:00Z');
    } catch (_) {
      parsedDate = DateTime.now(); // Fallback if parsing fails
    }

    return VideoModel(
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      duration: Duration(seconds: durationSeconds),
      scheduledDate: parsedDate,
    );
  }

  map(VideoModel Function(dynamic v) param0) {}
}

class Note {
  String id;
  String content;

  Note({
    required this.id,
    required this.content,
  });
}