import 'package:flutter/material.dart';
import 'package:mindbull/widgets/seek_new_try/audio_player_single_audio_widget.dart';
import '../models/exercise.dart';
import '../models/audio.dart';
import '../widgets/video_player_widget.dart';

class ExercisePlaybackScreen extends StatefulWidget {
  final Exercise exercise;

  const ExercisePlaybackScreen({super.key, required this.exercise});

  @override
  _ExercisePlaybackScreenState createState() => _ExercisePlaybackScreenState();
}

class _ExercisePlaybackScreenState extends State<ExercisePlaybackScreen> {
  bool _isInstructionsExpanded = false;

  @override
  Widget build(BuildContext context) {
    const String defaultImage = 'assets/background_sky.jpg';
    final String imageUrl = widget.exercise.thumbnail ?? defaultImage;

    // Determine media type
    bool isAudio = widget.exercise.media?.endsWith('.mp3') ?? false;
    bool isVideo = widget.exercise.media?.endsWith('.mp4') ?? false;

    // Log media details
    print("Exercise Media: ${widget.exercise.media}");
    print("Is Audio: $isAudio");
    print("Is Video: $isVideo");

    // Create an Audio object for audio playback
    Audio? audioFile;
    if (isAudio && widget.exercise.media != null) {
      audioFile = Audio(
        clientAppAudioFilePath: widget.exercise.media!,
        title: widget.exercise.name,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Details
            Text(
              widget.exercise.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.exercise.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Expandable Instructions
            GestureDetector(
              onTap: () {
                setState(() {
                  _isInstructionsExpanded = !_isInstructionsExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Instructions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    _isInstructionsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 24,
                  ),
                ],
              ),
            ),
            if (_isInstructionsExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.exercise.instructions,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

            const SizedBox(height: 16),
            // Media Player Section
            if (widget.exercise.media != null)
              if (isVideo)
                VideoPlayerWidget(videoUrl: widget.exercise.media!)
              else if (isAudio && audioFile != null)
                AudioPlayerSingleAudioWidget(
                  audioFile: audioFile,
                  autoplayEnabled: true,
                ),

            const SizedBox(height: 16),

/*             // Additional Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    print("Loop toggled");
                  },
                  icon: Icon(Icons.loop),
                  label: Text("Loop"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    print("Playback started");
                  },
                  icon: Icon(Icons.play_arrow),
                  label: Text("Play"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    print("Repeat toggled");
                  },
                  icon: Icon(Icons.repeat),
                  label: Text("Repeat"),
                ),
              ],
            ),
            SizedBox(height: 16), */

            // Journaling Section
            const Text(
              "Take Notes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts here...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  print("Note saved: $value");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
