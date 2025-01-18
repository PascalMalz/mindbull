import 'package:audio_service/audio_service.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerHandler extends BaseAudioHandler {
  final VideoPlayerController videoPlayerController;

  VideoPlayerHandler(this.videoPlayerController) {
    // Listen to video player state changes and update the playback state
    videoPlayerController.addListener(() {
      final videoValue = videoPlayerController.value;

      print("VideoPlayerController Listener Triggered");
      print(
          "isPlaying: ${videoValue.isPlaying}, isBuffering: ${videoValue.isBuffering}");
      print(
          "Position: ${videoValue.position}, Buffered: ${videoValue.buffered}");
      print(
          "Duration: ${videoValue.duration}, isInitialized: ${videoValue.isInitialized}");

      final processingState = videoValue.isInitialized
          ? (videoValue.isBuffering
              ? AudioProcessingState.buffering
              : AudioProcessingState.ready)
          : AudioProcessingState.loading;

      playbackState.add(playbackState.value.copyWith(
        controls: [
          videoValue.isPlaying ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
        playing: videoValue.isPlaying,
        processingState: processingState,
        updatePosition: videoValue.position,
        bufferedPosition: videoValue.buffered.isNotEmpty
            ? videoValue.buffered.last.end
            : Duration.zero,
      ));
    });
  }

  @override
  Future<void> play() async {
    try {
      await videoPlayerController.play();
      playbackState.add(playbackState.value.copyWith(playing: true));
    } catch (e) {
      print("Error during play: $e");
    }
  }

  @override
  Future<void> pause() async {
    try {
      await videoPlayerController.pause();
      playbackState.add(playbackState.value.copyWith(playing: false));
    } catch (e) {
      print("Error during pause: $e");
    }
  }

  @override
  Future<void> stop() async {
    try {
      await videoPlayerController.pause();
      playbackState.add(playbackState.value.copyWith(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.idle,
      ));
      await videoPlayerController.dispose();
    } catch (e) {
      print("Error during stop: $e");
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await videoPlayerController.seekTo(position);
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    } catch (e) {
      print("Error during seek: $e");
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    try {
      videoPlayerController.setPlaybackSpeed(speed);
      playbackState.add(playbackState.value.copyWith(speed: speed));
    } catch (e) {
      print("Error setting playback speed: $e");
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // Implement repeat mode handling if needed
    print("Repeat mode is not supported for this handler.");
  }
}
