import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null &&
        !message.contains('CCodecConfig') &&
        !message.contains('BufferQueueProducer') &&
        !message.contains('SurfaceControl')) {
      print(message);
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chewie with JustAudio',
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
  late final VideoPlayerController _videoController;
  ChewieController? _chewieController;
  late final AudioPlayer _audioPlayer;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideoController();
  }

  void _initializeVideoController() {
    print("Initializing video controller...");
    _videoController = VideoPlayerController.network(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    )..initialize().then((_) {
        print("Video controller initialized.");
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: false,
        );
        print("Chewie controller initialized.");
        setState(() {});

        // Initialize audio after video is ready
        _initializeAudioPlayer();
      });

    // Listen to video state changes
    _videoController.addListener(() async {
      final videoValue = _videoController.value;
      print("Video listener triggered: "
          "isPlaying=${videoValue.isPlaying}, "
          "position=${videoValue.position}, "
          "buffered=${videoValue.buffered}, "
          "duration=${videoValue.duration}");

      // Sync audio when video is paused
      if (!videoValue.isPlaying && !_isPlayingAudio) {
        print("Video paused, syncing audio player...");
        await _audioPlayer.seek(videoValue.position);
        await _audioPlayer.pause();
      }
    });
  }

  void _initializeAudioPlayer() {
    print("Initializing audio player...");
    _audioPlayer = AudioPlayer();

    print("Setting up audio player with URL...");
    _audioPlayer.setUrl(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print("App moved to background.");
      _playAudioInBackground();
    } else if (state == AppLifecycleState.resumed) {
      print("App moved to foreground.");
      _resumeVideoPlayback();
    }
  }

  Future<void> _playAudioInBackground() async {
    if (!_isPlayingAudio) {
      print("Switching to audio playback...");
      _isPlayingAudio = true;

      print("Pausing video...");
      await _videoController.pause();

      final currentPosition = _videoController.value.position;
      print("Syncing audio player to video position: $currentPosition...");
      await _audioPlayer.seek(currentPosition);

      print("Starting audio playback...");
      await _audioPlayer.play();

      setState(() {});
    }
  }

  Future<void> _resumeVideoPlayback() async {
    if (_isPlayingAudio) {
      print("Resuming video playback...");
      _isPlayingAudio = false;

      print("Pausing audio playback...");
      await _audioPlayer.pause();

      final currentPosition = _audioPlayer.position;
      print("Syncing video player to audio position: $currentPosition...");
      await _videoController.seekTo(currentPosition);

      print("Starting video playback...");
      await _videoController.play();

      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print("Disposing resources...");
    _audioPlayer.dispose();
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chewie with Background Audio'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  if (_isPlayingAudio) {
                    print("User pressed video mode button.");
                    await _resumeVideoPlayback();
                  } else {
                    print("User pressed audio mode button.");
                    await _playAudioInBackground();
                  }
                },
                icon: Icon(
                  _isPlayingAudio ? Icons.tv : Icons.headset,
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (_videoController.value.isPlaying) {
                    print("User pressed pause button.");
                    await _videoController.pause();
                  } else {
                    print("User pressed play button.");
                    await _videoController.play();
                  }
                  setState(() {});
                },
                icon: Icon(
                  _videoController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
