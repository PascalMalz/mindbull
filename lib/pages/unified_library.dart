import 'package:flutter/material.dart';

class UnifiedLibraryScreen extends StatelessWidget {
  const UnifiedLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Library'),
        //backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Your Library',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          _buildSectionCard(context, 'Favorites', Icons.favorite),
          _buildSectionCard(context, 'Records', Icons.mic_rounded, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RecordsScreenLibrary()),
            );
          }),
          _buildSectionCard(context, 'Mixes', Icons.queue_music, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MixesScreenLibrary()),
            );
          }),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Explore Library',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
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

  Widget _buildSectionCard(BuildContext context, String title, IconData icon,
      [VoidCallback? onTap]) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        onTap: onTap ??
            () {
              print('$title tapped!');
            },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        onTap: () {
          print('$title tapped!');
        },
      ),
    );
  }
}

// Dummy classes for navigation purposes
class RecordsScreenLibrary extends StatelessWidget {
  const RecordsScreenLibrary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records Library'),
      ),
      body: Center(child: Text('Records content here')),
    );
  }
}

class MixesScreenLibrary extends StatelessWidget {
  const MixesScreenLibrary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mixes Library'),
      ),
      body: Center(child: Text('Mixes content here')),
    );
  }
}
