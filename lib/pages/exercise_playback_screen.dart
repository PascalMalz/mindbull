import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../models/audio.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/seek_new_try/audio_player_single_audio_widget.dart';
import '../widgets/journal_widget.dart';
import '../provider/journal_provider.dart';

class ExercisePlaybackScreen extends StatefulWidget {
  final Exercise exercise;
  final String tabCategory;

  const ExercisePlaybackScreen({
    super.key,
    required this.exercise,
    required this.tabCategory,
  });

  @override
  _ExercisePlaybackScreenState createState() => _ExercisePlaybackScreenState();
}

class _ExercisePlaybackScreenState extends State<ExercisePlaybackScreen> {
  bool _isInstructionsExpanded = false;

  void _showJournalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return JournalWidget(category: widget.tabCategory);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const String defaultImage = 'assets/background_sky.jpg';
    final String imageUrl = widget.exercise.thumbnail ?? defaultImage;

    // Determine media type
    bool isAudio = widget.exercise.media?.endsWith('.mp3') ?? false;
    bool isVideo = widget.exercise.media?.endsWith('.mp4') ?? false;

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Details
                  Text(
                    widget.exercise.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                ],
              ),
            ),
          ),

          // Journal Trigger Button
          GestureDetector(
            onTap: () => _showJournalBottomSheet(context),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                      color: Colors.grey.shade300, width: 1), // Top border
                  left: BorderSide(
                      color: Colors.grey.shade300, width: 1), // Left border
                  right: BorderSide(
                      color: Colors.grey.shade300, width: 1), // Right border
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.edit, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text(
                    "Open Journal",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
