import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;
  final String? thumbnailUrl;

  VideoPlayerWidget({
    Key? key,
    this.videoFile,
    this.videoUrl,
    this.thumbnailUrl,
  })  : assert(videoFile != null || videoUrl != null,
            'A video file or a video URL must be provided.'),
        super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoFile != oldWidget.videoFile ||
        widget.videoUrl != oldWidget.videoUrl) {
      _reinitializeVideoPlayer();
    }
  }

  void _initVideoPlayer() {
    _controller = widget.videoFile != null
        ? VideoPlayerController.file(widget.videoFile!)
        : VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: false,
        looping: false,
      );
      setState(() {});
    });
  }

  Future<void> _reinitializeVideoPlayer() async {
    await _controller.pause();
    await _controller.dispose();
    _chewieController?.dispose();
    setState(() {
      _initVideoPlayer();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller.value.isInitialized) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Chewie(
              controller: _chewieController!,
            ),
          );
        } else {
          // Show thumbnail or loading indicator while video is loading
          return AspectRatio(
            aspectRatio: 16 / 9, // Fallback aspect ratio for the thumbnail
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Display thumbnail
                widget.thumbnailUrl != null
                    ? Image.network(
                        widget.thumbnailUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
                // Display loading indicator
                const CircularProgressIndicator(),
              ],
            ),
          );
        }
      },
    );
  }
}
