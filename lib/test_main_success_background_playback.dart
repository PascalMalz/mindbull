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

  @override
  void initState() {
    super.initState();
    _initializeVideoAndAudioService();
  }

  Future<void> _initializeVideoAndAudioService() async {
    // Initialize the VideoPlayerController
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4'),
    );

    await _videoPlayerController.initialize();

    // Initialize AudioService after the video controller is ready
    _audioHandler = await AudioService.init(
      builder: () => VideoPlayerHandler(_videoPlayerController),
      config: AudioServiceConfig(
        androidNotificationChannelName: 'Video Playback',
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidShowNotificationBadge: true,
      ),
    );

    setState(() {
      _isAudioServiceInitialized = true;
      _videoPlayerController.play();
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _audioHandler?.stop(); // Clean up the audio handler
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Playback Test')),
      body: Center(
        child: _videoPlayerController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              )
            : CircularProgressIndicator(),
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
