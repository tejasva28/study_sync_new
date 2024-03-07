class VideoModel {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final Duration duration;
  final DateTime? scheduledDate;

  VideoModel({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    this.scheduledDate,
  });


  factory VideoModel.fromJson(Map<String, dynamic> json) {
    // Parse duration from a string if necessary, or use a default value
    var durationSeconds = json['duration'] as int? ?? 0; // Example, adjust according to your JSON

    return VideoModel(
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '', // Ensure this is provided in JSON
      duration: Duration(seconds: durationSeconds), // Adjust parsing as needed
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate']) : null,
    );
  }

  toJson() {}
}

class Note {
  String id;
  String content;

  Note({
    required this.id,
    required this.content,
  });
}

