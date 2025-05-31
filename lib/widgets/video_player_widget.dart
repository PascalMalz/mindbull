// video_player_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;
  final String? thumbnailUrl;

  const VideoPlayerWidget({
    Key? key,
    this.videoFile,
    this.videoUrl,
    this.thumbnailUrl,
  })  : assert(videoFile != null || videoUrl != null),
        super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.videoFile != null
        ? VideoPlayerController.file(widget.videoFile!)
        : VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));

    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
      _isPlaying = true;
      _startHideControlsTimer();
    });
  }

  void _startHideControlsTimer() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (mounted && _controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
        _showControls = true;
      } else {
        _controller.play();
        _isPlaying = true;
        _showControls = true;
        _startHideControlsTimer();
      }
    });
  }

  void _onTapVideo() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_isPlaying && _showControls) {
      _startHideControlsTimer();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double videoAreaHeight = 360;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: videoAreaHeight,
          width: double.infinity,
          color: Colors.grey.shade300,
          child: _controller.value.isInitialized
              ? GestureDetector(
                  onTap: _onTapVideo,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          iconSize: 100,
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            color: Colors.white60,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepPurple,
                  ),
                ),
        ),
        VideoProgressIndicator(
          _controller,
          colors: const VideoProgressColors(playedColor: Colors.deepPurple),
          allowScrubbing: true,
          padding:
              const EdgeInsets.only(left: 10, right: 10, bottom: 30, top: 0),
        ),
      ],
    );
  }
}
