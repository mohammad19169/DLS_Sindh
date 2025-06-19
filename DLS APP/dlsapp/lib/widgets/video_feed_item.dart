// widgets/video_feed_item.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import '../repositories/video_repository.dart';
import 'video_player_widget.dart';

class VideoFeedItem extends StatefulWidget {
  final Video video;
  final String currentUserId;

  const VideoFeedItem({
    Key? key,
    required this.video,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _VideoFeedItemState createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> {
  bool _isLiked = false;
  bool _isSaved = false;
  bool _showFullCaption = false;

  @override
  void initState() {
    super.initState();
    // Initialize like/save state based on user data
    // You would typically fetch this from Firestore
    _isLiked = false;
    _isSaved = false;
  }

  void _toggleLike() async {
    final videoRepo = Provider.of<VideoRepository>(context, listen: false);
    setState(() => _isLiked = !_isLiked);
    
    if (_isLiked) {
      await videoRepo.likeVideo(widget.video.id, widget.currentUserId);
    } else {
      await videoRepo.unlikeVideo(widget.video.id, widget.currentUserId);
    }
  }

  void _toggleSave() async {
    final videoRepo = Provider.of<VideoRepository>(context, listen: false);
    setState(() => _isSaved = !_isSaved);
    
    if (_isSaved) {
      await videoRepo.saveVideo(widget.video.id, widget.currentUserId);
    } else {
      await videoRepo.unsaveVideo(widget.video.id, widget.currentUserId);
    }
  }

  Future<void> _downloadVideo() async {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading video...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video Player
        VideoPlayerWidget(videoUrl: widget.video.videoUrl, autoPlay: true),

        // Gradient Overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Video Info
        Positioned(
          bottom: 20,
          left: 16,
          right: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${widget.video.creatorUsername}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _showFullCaption = !_showFullCaption),
                child: Text(
                  widget.video.caption,
                  style: const TextStyle(color: Colors.white),
                  maxLines: _showFullCaption ? null : 2,
                  overflow: _showFullCaption ? null : TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Right Side Action Buttons
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              // Like Button
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.white,
                  size: 32,
                ),
                onPressed: _toggleLike,
              ),
              Text(
                widget.video.likes.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Save Button
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: _isSaved ? Colors.blue : Colors.white,
                  size: 32,
                ),
                onPressed: _toggleSave,
              ),
              const Text('Save', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 20),

              // Download Button
              IconButton(
                icon: const Icon(Icons.download, color: Colors.white, size: 32),
                onPressed: _downloadVideo,
              ),
              const Text('Download', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}