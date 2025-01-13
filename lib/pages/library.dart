import 'package:flutter/material.dart';

class MusicLibraryHomeScreen extends StatelessWidget {
  const MusicLibraryHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Explore Exercises'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          _buildCategoryCard(context, 'All', Icons.library_music),
          _buildCategoryCard(context, 'Favourites', Icons.favorite),
          _buildCategoryCard(context, 'Recommendations', Icons.star),
          _buildCategoryCard(context, 'Best Reviewed', Icons.thumb_up),
          _buildCategoryCard(context, 'Self Esteem', Icons.self_improvement),
          _buildCategoryCard(context, 'Loose Weight', Icons.fitness_center),
          _buildCategoryCard(context, 'Erotic', Icons.spa),
          _buildCategoryCard(context, 'ASMR', Icons.headset),
          _buildCategoryCard(context, 'Progressive Muscle Relaxation (PMR)',
              Icons.self_improvement),
          _buildCategoryCard(context, 'Sports / Accuracy', Icons.sports),
          _buildCategoryCard(
              context, 'Public Speaking', Icons.record_voice_over),
          _buildCategoryCard(context, 'Confidence', Icons.emoji_emotions),
          _buildCategoryCard(context, 'Be Feminine', Icons.female),
          _buildCategoryCard(context, 'Be Masculine', Icons.male),
          _buildCategoryCard(context, 'While Sleep', Icons.nightlight_round),
          _buildCategoryCard(context, 'Awake', Icons.wb_sunny),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        onTap: () {
          // Logic to navigate to the relevant screen for the category
          print('$title tapped!');
          // Example:
          // Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(title: title)));
        },
      ),
    );
  }
}
