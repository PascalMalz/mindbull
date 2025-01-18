import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mindbull/services/video_player_handler.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoScreen(),
    );
  }
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _videoPlayerController;
  AudioHandler? _audioHandler;
  bool _isAudioServiceInitialized = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoAndAudioService();
  }

  Future<void> _initializeVideoAndAudioService() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      print("Initializing VideoPlayerController...");
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        ),
      );

      _videoPlayerController.addListener(() {
        final videoValue = _videoPlayerController.value;
        print("Video Listener Triggered");
        print("Position: ${videoValue.position}");
        print("Buffered: ${videoValue.buffered}");
        print("Duration: ${videoValue.duration}");
        print(
            "isPlaying: ${videoValue.isPlaying}, isBuffering: ${videoValue.isBuffering}");
      });

      print("Initializing video player...");
      await _videoPlayerController.initialize();
      print(
          "VideoPlayerController initialized: ${_videoPlayerController.value.isInitialized}");

      setState(() {}); // Force UI update

      print("Starting video playback...");
      await _videoPlayerController.play();

      print("Initializing AudioService...");
      _audioHandler = await AudioService.init(
        builder: () => VideoPlayerHandler(_videoPlayerController),
        config: AudioServiceConfig(
          androidNotificationChannelName: 'Video Playback',
          androidNotificationIcon: 'mipmap/ic_launcher',
          androidShowNotificationBadge: true,
        ),
      );
      print("AudioService initialized.");

      setState(() {
        _isAudioServiceInitialized = true;
      });
    } catch (e, stacktrace) {
      print("Error initializing services: $e");
      print("Stacktrace: $stacktrace");
    } finally {
      _isInitializing = false;
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _audioHandler?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Playback Test')),
      body: Center(
        child: _videoPlayerController.value.isInitialized
            ? Container(
                color: Colors.black, // Ensure background visibility
                child: AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                ),
              )
            : CircularProgressIndicator(), // Fallback if not initialized
      ),
      floatingActionButton: _isAudioServiceInitialized
          ? StreamBuilder<PlaybackState>(
              stream: _audioHandler!.playbackState,
              builder: (context, snapshot) {
                final playbackState = snapshot.data;
                final isPlaying = playbackState?.playing ?? false;
                return FloatingActionButton(
                  child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (isPlaying) {
                      _audioHandler?.pause();
                    } else {
                      _audioHandler?.play();
                    }
                  },
                );
              },
            )
          : null,
    );
  }
}
