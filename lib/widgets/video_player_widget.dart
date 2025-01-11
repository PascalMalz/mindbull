import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayerWidget extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;

  const VideoPlayerWidget({super.key, this.videoFile, this.videoUrl})
      : assert(videoFile != null || videoUrl != null,
            'A video file or a video URL must be provided.');

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = widget.videoFile != null
        ? VideoPlayerController.file(widget.videoFile!)
        : VideoPlayerController.network(widget.videoUrl!);

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {}); // Refresh UI when video is ready
    });
    _controller.setLooping(false); // No looping by default
    _controller.play(); // Auto-play
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        width: screenWidth - 60, // Width with padding
        height: 550.0, // Fixed height
        color: Colors.transparent,
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
