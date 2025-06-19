import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _videoFile;
  final TextEditingController _captionController = TextEditingController();
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    try {
      final pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );

      if (pickedFile != null) {
        setState(() {
          _videoFile = File(pickedFile.path);
          _uploadProgress = 0.0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: ${e.toString()}')),
      );
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video first')),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final uploadService = Provider.of<UploadService>(context, listen: false);

    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to upload videos')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      await uploadService.uploadVideo(
        videoFile: _videoFile!,
        userId: authService.currentUser!.uid,
        username: authService.currentUser!.displayName ?? 'Anonymous',
        caption: _captionController.text,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully!')),
      );

      // Clear form and return to home
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isUploading ? null : () => Navigator.pop(context),
        ),
        actions: [
          if (_videoFile != null && !_isUploading)
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _uploadVideo,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Preview Section
            AspectRatio(
              aspectRatio: 9/16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: _videoFile != null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          // Would normally use a video preview here
                          const Icon(Icons.videocam, size: 50, color: Colors.white),
                          if (_isUploading)
                            LinearProgressIndicator(
                              value: _uploadProgress,
                              backgroundColor: Colors.grey[800],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                              minHeight: 5,
                            ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.video_library, size: 50, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No video selected',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Select Video Button
            ElevatedButton(
              onPressed: _isUploading ? null : _pickVideo,
              child: const Text('Select Video'),
            ),
            const SizedBox(height: 20),

            // Caption Input
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Add a caption...',
              ),
              maxLines: 3,
              enabled: !_isUploading,
            ),
            const SizedBox(height: 20),

            // Upload Button
            if (_videoFile != null)
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upload Video'),
              ),
          ],
        ),
      ),
    );
  }
}