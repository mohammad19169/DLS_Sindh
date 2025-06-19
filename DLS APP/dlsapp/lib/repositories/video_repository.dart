// repositories/video_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_model.dart';

class VideoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Video>> getVideos() {
    return _firestore
        .collection('videos')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Video.fromMap(doc.data())).toList();
    });
  }

  Future<void> likeVideo(String videoId, String userId) async {
    await _firestore.collection('videos').doc(videoId).update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> unlikeVideo(String videoId, String userId) async {
    await _firestore.collection('videos').doc(videoId).update({
      'likes': FieldValue.increment(-1),
      'likedBy': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> saveVideo(String videoId, String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'savedVideos': FieldValue.arrayUnion([videoId]),
    });
  }

  Future<void> unsaveVideo(String videoId, String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'savedVideos': FieldValue.arrayRemove([videoId]),
    });
  }
}