import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayerWidgetV2 extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;
  final bool enablePlaybackSpeed;

  const VideoPlayerWidgetV2({
    super.key,
    this.videoFile,
    this.videoUrl,
    this.enablePlaybackSpeed = false,
  }) : assert(videoFile != null || videoUrl != null,
            'A video file or a video URL must be provided.');

  @override
  _VideoPlayerWidgetV2State createState() => _VideoPlayerWidgetV2State();
}

class _VideoPlayerWidgetV2State extends State<VideoPlayerWidgetV2> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  @override
  void didUpdateWidget(VideoPlayerWidgetV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoFile != oldWidget.videoFile ||
        widget.videoUrl != oldWidget.videoUrl) {
      _reinitializeVideoPlayer();
    }
  }

  void _initVideoPlayer() {
    _controller = widget.videoFile != null
        ? VideoPlayerController.file(widget.videoFile!)
        : VideoPlayerController.network(widget.videoUrl!);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    });
  }

  Future<void> _reinitializeVideoPlayer() async {
    await _controller.pause();
    await _controller.dispose();
    setState(() {
      _initVideoPlayer();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const screenHeight = 550.0;
    final maxWidth = screenWidth - 60;
    final maxHeight = screenHeight - 10;

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller.value.isInitialized) {
          final aspectRatio = _controller.value.aspectRatio;
          return Center(
            child: Container(
              width: maxWidth,
              height: maxHeight,
              color: Colors.transparent,
              child: Center(
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller),
                      _ControlsOverlay(
                        controller: _controller,
                        enablePlaybackSpeed: widget.enablePlaybackSpeed,
                      ),
                      _SeekBar(controller: _controller),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final bool enablePlaybackSpeed;

  const _ControlsOverlay({
    super.key,
    required this.controller,
    required this.enablePlaybackSpeed,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = controller.value.isPlaying;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
          },
        ),
        if (enablePlaybackSpeed)
          Positioned(
            top: 10,
            right: 10,
            child: DropdownButton<double>(
              value: controller.value.playbackSpeed,
              items: [0.5, 1.0, 1.5, 2.0].map((speed) {
                return DropdownMenuItem(
                  value: speed,
                  child: Text("${speed}x"),
                );
              }).toList(),
              onChanged: (speed) {
                if (speed != null) {
                  controller.setPlaybackSpeed(speed);
                }
              },
            ),
          ),
      ],
    );
  }
}

class _SeekBar extends StatefulWidget {
  final VideoPlayerController controller;

  const _SeekBar({super.key, required this.controller});

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  late Duration _currentPosition;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          _currentPosition = widget.controller.value.position;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentPosition.inMilliseconds.toDouble(),
      min: 0,
      max: widget.controller.value.duration.inMilliseconds.toDouble(),
      onChanged: (value) {
        widget.controller.seekTo(Duration(milliseconds: value.toInt()));
      },
    );
  }
}
