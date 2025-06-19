// services/upload_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class UploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadVideo({
    required File videoFile,
    required String userId,
    required String username,
    required String caption,
    required Function(double) onProgress,
  }) async {
    try {
      // Generate unique ID for the video
      final videoId = _uuid.v4();
      
      // Get file extension
      final extension = path.extension(videoFile.path);
      
      // Create storage reference
      final ref = _storage.ref().child('videos/$userId/$videoId$extension');
      
      // Create upload task
      final uploadTask = ref.putFile(
        videoFile,
        SettableMetadata(
          contentType: 'video/mp4', // Adjust based on your video type
        ),
      );

      // Listen for progress
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        onProgress(progress);
      });

      // Wait for upload to complete
      final taskSnapshot = await uploadTask.whenComplete(() {});
      
      // Get download URL
      final videoUrl = await taskSnapshot.ref.getDownloadURL();

      // Create thumbnail (you would implement this separately)
      // final thumbnailUrl = await _createThumbnail(videoFile);

      // Store video metadata in Firestore
      await _firestore.collection('videos').doc(videoId).set({
        'id': videoId,
        'videoUrl': videoUrl,
        'thumbnailUrl': '', // Add your thumbnail URL here
        'caption': caption,
        'creatorUid': userId,
        'creatorUsername': username,
        'likes': 0,
        'comments': 0,
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
      });

      return videoId;
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }

  // You would implement this method to create a thumbnail
  // Future<String> _createThumbnail(File videoFile) async { ... }
}