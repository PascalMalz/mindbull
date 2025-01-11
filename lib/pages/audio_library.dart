import 'package:flutter/material.dart';
import 'package:mindbull/pages/records_screen_library.dart';
import 'mixes_screen_library.dart';

class AudioLibrary extends StatelessWidget {
  const AudioLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Audio Library'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: <Widget>[
          _buildSectionCard(context, 'Favorites', Icons.favorite),
          _buildSectionCard(context, 'Records', Icons.mic_rounded, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RecordsScreenLibrary()),
            );
          }),
          _buildSectionCard(context, 'Mixes', Icons.queue_music),
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
              if (title == 'Mixes') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MixesScreenLibrary()),
                );
              } else {
                print('$title tapped!');
              }
            },
      ),
    );
  }
}
