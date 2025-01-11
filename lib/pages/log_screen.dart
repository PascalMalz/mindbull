// screens/log_screen.dart

import 'package:flutter/material.dart';
import '../services/log_service.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final _logService = LogService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs')),
      body: FutureBuilder<String>(
        future: _logService.readLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final logs = snapshot.data!.trim().split('\n');
              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(logs[index]),
                  );
                },
              );
            } else {
              return const Center(child: Text('No logs available.'));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
