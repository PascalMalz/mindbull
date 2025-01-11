// Filename: exercise_card.dart

import 'package:flutter/material.dart';
import 'package:mindbull/pages/exercise_playback_screen.dart';
import '../models/exercise.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required bool autoplayEnabled,
  });

  @override
  Widget build(BuildContext context) {
    // Default fallback image
    const String defaultImage =
        'assets/background_sky.jpg'; // Replace with your asset path
    final String imageUrl = exercise.thumbnail ?? defaultImage;

    // Format duration based on value
    String formatDuration(Duration duration) {
      int totalSeconds = duration.inSeconds;
      if (totalSeconds < 60) {
        return "$totalSeconds sec";
      } else if (totalSeconds < 3600) {
        int minutes = totalSeconds ~/ 60;
        return "$minutes min";
      } else {
        int hours = totalSeconds ~/ 3600;
        return "$hours hr";
      }
    }

    // Parse duration string to Duration object
    Duration duration;
    try {
      duration = Duration(
        hours: int.parse(exercise.duration.split(':')[0]),
        minutes: int.parse(exercise.duration.split(':')[1]),
        seconds: int.parse(exercise.duration.split(':')[2]),
      );
    } catch (e) {
      print("Error parsing duration: ${exercise.duration}");
      duration = Duration.zero; // Fallback to 0 seconds
    }

    print(
        "Parsed duration: ${duration.inSeconds} seconds for ${exercise.name}");

    return GestureDetector(
      onTap: () {
        // Navigate to the dedicated playback screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExercisePlaybackScreen(exercise: exercise),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          elevation: 4, // Shadow effect
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section with error handling
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: imageUrl.isNotEmpty &&
                              Uri.tryParse(imageUrl)?.hasAbsolutePath == true
                          ? NetworkImage(imageUrl)
                          : AssetImage(defaultImage) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Text Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // XP Points
                      Text(
                        "+${exercise.xp} XP",
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1, // Limit to 1 line
                        overflow: TextOverflow.ellipsis, // Truncate long text
                      ),
                      const SizedBox(height: 4),

                      // Subtitle
                      Text(
                        exercise.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2, // Limit to 2 lines
                        overflow: TextOverflow.ellipsis, // Truncate long text
                      ),
                      const SizedBox(height: 8),

                      // Duration Row
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              formatDuration(duration),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow
                                  .ellipsis, // Truncate text if needed
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
