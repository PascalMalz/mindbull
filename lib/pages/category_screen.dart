import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
//import of models
import 'package:mindbull/models/audio.dart';
import 'package:path_provider/path_provider.dart';
//APIs
import '../api/api_audio.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;

  const CategoryScreen({super.key, required this.categoryName});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiAudio _musicApi = ApiAudio();
  List<Audio> _audioFiles = [];

  @override
  void initState() {
    super.initState();
    _fetchAudioFilesForCategory();
  }

  Future<void> _fetchAudioFilesForCategory() async {
    final audioFiles =
        await _musicApi.fetchAudioFilesForCategory(widget.categoryName);
    setState(() {
      _audioFiles = audioFiles;
    });
  }

  double _downloadProgress = 0.0; // Initialize with 0 progress

  Future<void> _downloadAudioFile(String filePath, String title) async {
    const String baseUrl = 'http://82.165.125.163';
    final downloadUrl = '$baseUrl/download/$filePath';
    print(downloadUrl);

    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/$title';

      Dio dio = Dio();

      await dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = (received / total) * 100;
            });
          }
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File downloaded to $savePath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset progress once done
      setState(() {
        _downloadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Center(
        child: _audioFiles.isEmpty
            ? const Text('No audio files available')
            : ListView.builder(
                itemCount: _audioFiles.length,
                itemBuilder: (context, index) {
                  final audioFile = _audioFiles[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/pascalmalz.jpg"),
                    ),
                    title: Text(
                      '${audioFile.title},${audioFile.username}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    subtitle: Text(
                      '${audioFile.id},${audioFile.userTimeStamp}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _downloadAudioFile(audioFile.id, audioFile.title);
                      },
                      child: const Text('Download'),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: _downloadProgress > 0
          ? LinearProgressIndicator(
              value: _downloadProgress /
                  100, // Divide by 100 to get a value between 0 and 1
              backgroundColor: Colors.grey,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            )
          : null, // Only show progress bar if there's a download in progress
    );
  }
}
