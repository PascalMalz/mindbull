import 'package:flutter/material.dart';

class SoundReelsPage extends StatefulWidget {
  const SoundReelsPage({super.key});

  @override
  _SoundReelsPageState createState() => _SoundReelsPageState();
}

class _SoundReelsPageState extends State<SoundReelsPage> {
  List<String> soundFiles = [
    'sound1.mp3',
    'sound2.mp3',
    'sound3.mp3',
    'sound4.mp3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Reels'),
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView.builder(
          itemCount: soundFiles.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                playSoundFile(soundFiles[index]);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.blueGrey,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.music_note),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Sound ${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.play_circle_filled),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void playSoundFile(String soundFile) {
    // Implement your logic to play the sound file here
    // You can use a package like audioplayers for audio playback
    print('Playing $soundFile');
  }
}
