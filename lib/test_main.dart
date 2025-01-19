import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio-Video Sync App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const VideoScreen(),
    );
  }
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  late AudioPlayer _audioPlayer;
  bool _isAudioPlaying = false;
  bool _isTransitioning = false; // Prevent race conditions during transitions
  bool _customIsAudioPlaying = false; // Custom flag for audio state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeVideoController().then((_) => _initializeAudioPlayer());
  }

  Future<void> _initializeVideoController() async {
    print("Initializing video controller...");
    _videoController = VideoPlayerController.networkUrl(Uri.parse(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    ));

    await _videoController.initialize();
    print("Video controller initialized.");

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: false,
      looping: false,
    );

    setState(() {});
  }

  Future<void> _initializeAudioPlayer() async {
    print("Initializing audio player...");
    _audioPlayer = AudioPlayer();

    // Set up the audio URL but do not start playing automatically
    await _audioPlayer.setUrl(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    );
    print("Audio player initialized.");
  }

  void _playAudioInBackground() async {
    if (_isTransitioning || !_videoController.value.isInitialized) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _playAudioInBackground());
      return;
    }

    if (!_videoController.value.isPlaying) {
      print("Video is paused; skipping background audio playback.");
      return;
    }

    _isTransitioning = true;
    try {
      print("Switching to audio playback...");
      final videoPosition = _videoController.value.position;
      await _audioPlayer.seek(videoPosition);
      await _audioPlayer.play();
      _customIsAudioPlaying = true; // Update custom flag
      print("Custom audio playing state: $_customIsAudioPlaying");
      await _videoController.pause();
      setState(() => _isAudioPlaying = true);
    } finally {
      _isTransitioning = false;
    }
  }

  void _resumeVideoPlayback() async {
    if (_isTransitioning) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _resumeVideoPlayback());
      return;
    }

    _isTransitioning = true;

    try {
      final isVideoInitialized = _videoController.value.isInitialized;
      final audioPosition = await _audioPlayer.position;

      print(
          "Debug: Custom Audio Playing=$_customIsAudioPlaying, Audio Position=$audioPosition, Video Initialized=$isVideoInitialized");

      if (_customIsAudioPlaying && isVideoInitialized) {
        print("Switching to video playback...");
        if (_videoController.value.isPlaying) {
          await _videoController.pause();
        }

        if (audioPosition != null) {
          print(
              "Calling _retrySeek with actual audio position: $audioPosition");
          await _retrySeek(audioPosition);
        } else {
          print("Audio position is null, skipping seek.");
        }

        await _videoController.play();
        _customIsAudioPlaying = false; // Reset custom flag
        setState(() => _isAudioPlaying = false);
      } else if (!_customIsAudioPlaying && isVideoInitialized) {
        print("Resuming video playback if paused...");
        if (!_videoController.value.isPlaying) {
          await _videoController.play();
        }
        setState(() => _isAudioPlaying = false);
      } else {
        print("No playback action required.");
      }
    } catch (e) {
      print("Error during video playback resume: $e");
      await _initializeVideoController();
      _resumeVideoPlayback();
    } finally {
      _isTransitioning = false;
    }
  }

  Future<void> _retrySeek(Duration position) async {
    print("Entering _retrySeek with position: $position");

    for (int i = 0; i < 3; i++) {
      try {
        print("Seek attempt $i to position: $position");
        await _videoController.seekTo(position);
        final updatedPosition = _videoController.value.position;
        if (updatedPosition.inSeconds == position.inSeconds) {
          print("Seek successful to position: $updatedPosition on attempt $i");
          return;
        } else {
          print("Seek mismatch: expected $position, got $updatedPosition");
        }
      } catch (e) {
        print("Seek attempt $i failed: $e");
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    print("Exiting _retrySeek after 3 failed attempts");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      print("App AppLifecycleState.paused.");
      _playAudioInBackground();
    } else if (state == AppLifecycleState.resumed) {
      print("App AppLifecycleState.resumed.");
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(
            const Duration(milliseconds: 100)); // Add a brief delay
        _resumeVideoPlayback();
      });
    }
  }

  @override
  void dispose() {
    print("Disposing resources...");
    _audioPlayer.dispose();
    _chewieController?.dispose();
    _videoController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio-Video Sync'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const Center(child: CircularProgressIndicator()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_isAudioPlaying) {
                    _resumeVideoPlayback();
                  } else {
                    _playAudioInBackground();
                  }
                },
                icon: Icon(
                  _isAudioPlaying ? Icons.tv : Icons.headset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
