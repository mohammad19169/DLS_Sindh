// models/video_model.dart
class Video {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  final String creatorUid;
  final String creatorUsername;
  final int likes;
  final int comments;
  final DateTime timestamp;

  Video({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.creatorUid,
    required this.creatorUsername,
    this.likes = 0,
    this.comments = 0,
    required this.timestamp,
  });

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'],
      videoUrl: map['videoUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      caption: map['caption'],
      creatorUid: map['creatorUid'],
      creatorUsername: map['creatorUsername'],
      likes: map['likes'],
      comments: map['comments'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'creatorUid': creatorUid,
      'creatorUsername': creatorUsername,
      'likes': likes,
      'comments': comments,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}