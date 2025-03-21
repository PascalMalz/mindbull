//todo video not previewed when recorded (not from phone storage)
import 'package:flutter/material.dart';
import 'package:mindbull/pages/post/post_screen_composition.dart';
import 'package:mindbull/pages/post/post_single_affirmation.dart';
import 'package:mindbull/pages/post/post_video_screen.dart';

class PostTypeSelectionScreen extends StatefulWidget {
  const PostTypeSelectionScreen({super.key});

  @override
  _PostTypeSelectionScreenState createState() =>
      _PostTypeSelectionScreenState();
}

class _PostTypeSelectionScreenState extends State<PostTypeSelectionScreen> {
  String? selectedPostType;

  void _selectPostType(String type) {
    setState(() {
      selectedPostType = type;
    });
  }

  void _proceedToSelectedPage() {
    // Ensure there is a selected post type before navigating
    if (selectedPostType != null) {
      // Navigate to the specific page based on the type
// Example: Navigating to a page directly with its class constructor
      if (selectedPostType == 'Composition') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CompositionPostPage()));
      } else if (selectedPostType == 'Single Affirmation') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PostSingleAffirmation()));
      } else if (selectedPostType == 'Video') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PostVideoScreen()));
      }
    }
  }

  Widget _buildPostTypeOption(String type, IconData icon) {
    bool isSelected = selectedPostType == type;
    return InkWell(
      onTap: () => _selectPostType(type),
      child: Column(
        children: [
          Opacity(
            opacity: isSelected ? 1.0 : 0.5,
            child: CircleAvatar(
              backgroundColor: isSelected ? Colors.deepPurple : Colors.grey,
              radius: 40,
              child: Icon(icon, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            type,
            style: TextStyle(
              color: isSelected ? Colors.deepPurple : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Content To Post'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Select what you want to post',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildPostTypeOption('Composition', Icons.library_music),
              _buildPostTypeOption(
                  'Single Affirmation', Icons.record_voice_over),
              _buildPostTypeOption('Video', Icons.videocam),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: selectedPostType != null ? _proceedToSelectedPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple, // Background color
              foregroundColor:
                  Colors.white, // Text and icon color (replaces onPrimary)
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text('Proceed'),
          ),
        ],
      ),
    );
  }
}
