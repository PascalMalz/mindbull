import 'dart:async';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;

  VideoPlayerWidget({Key? key, this.videoFile, this.videoUrl})
      : assert(videoFile != null || videoUrl != null,
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
        : VideoPlayerController.networkUrl(
            Uri.parse(widget.videoUrl!)); // Use Uri.parse for String URLs

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
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Chewie video player
                Container(
                  height: MediaQuery.of(context).size.height *
                      0.5, // Set a fixed height
                  child: Chewie(controller: _chewieController!),
                ),
                // Footer or slider
/*                 Slider(
                  value: _controller.value.position.inMilliseconds.toDouble(),
                  min: 0.0,
                  max: _controller.value.duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    _controller.seekTo(Duration(milliseconds: value.toInt()));
                  },
                ),
                Container(
                  height: 50.0,
                  color: Colors.red,
                  child: Center(
                      child: Text("Footer",
                          style: TextStyle(color: Colors.white))),
                ), */
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
