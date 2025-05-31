// Filename: exercise_card.dart

import 'package:flutter/material.dart';
import 'package:mindbull/pages/exercise_playback_screen.dart';
import '../models/exercise.dart';
import '../services/favorite_service.dart';

class ExerciseCardWithFavorite extends StatefulWidget {
  final Exercise exercise;
  final bool autoplayEnabled;

  const ExerciseCardWithFavorite({
    super.key,
    required this.exercise,
    required this.autoplayEnabled,
  });

  @override
  State<ExerciseCardWithFavorite> createState() =>
      _ExerciseCardWithFavoriteState();
}

class _ExerciseCardWithFavoriteState extends State<ExerciseCardWithFavorite> {
  bool? isFavorite;
  int favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    await FavoriteService.syncFavoriteStatus(
      context: context,
      objectId: widget.exercise.exerciseUuid,
      contentType: 'exercise',
    );

    setState(() {
      isFavorite = FavoriteService.isFavorited(widget.exercise.exerciseUuid);
      favoriteCount =
          FavoriteService.getFavoriteCount(widget.exercise.exerciseUuid);
    });
  }

  void _toggleFavorite() async {
    await FavoriteService.toggleFavorite(
      context: context,
      objectId: widget.exercise.exerciseUuid,
      contentType: 'exercise',
    );

    setState(() {
      isFavorite = FavoriteService.isFavorited(widget.exercise.exerciseUuid);
      favoriteCount =
          FavoriteService.getFavoriteCount(widget.exercise.exerciseUuid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    const String defaultImage = 'assets/background_sky.jpg';
    final String imageUrl = exercise.thumbnail ?? defaultImage;

    Duration duration;
    try {
      duration = Duration(
        hours: int.parse(exercise.duration.split(':')[0]),
        minutes: int.parse(exercise.duration.split(':')[1]),
        seconds: int.parse(exercise.duration.split(':')[2]),
      );
    } catch (_) {
      duration = Duration.zero;
    }

    String formatDuration(Duration d) {
      if (d.inSeconds < 60) return "${d.inSeconds} sec";
      if (d.inMinutes < 60) return "${d.inMinutes} min";
      return "${d.inHours} hr";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExercisePlaybackScreen(
              exercise: exercise,
              tabCategory: exercise.exerciseType,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
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

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("+${exercise.xp} XP",
                          style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(exercise.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(exercise.description,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              formatDuration(duration),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Favorite button + count
                // Favorite button + count
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.deepPurple,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    Text(
                      '$favoriteCount',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
