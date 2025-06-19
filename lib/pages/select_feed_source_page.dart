import 'package:flutter/material.dart';
import 'camera_stream_page.dart';

class SelectFeedSourcePage extends StatelessWidget {
  final String feedType; // 'bowler' or 'batsman'
  const SelectFeedSourcePage({super.key, required this.feedType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Source for $feedType feed")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Use Camera"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraStreamPage(feedType: feedType),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.folder),
              label: const Text("Browse from Device"),
              onPressed: () {
                // Add video picker flow here later
              },
            ),
          ],
        ),
      ),
    );
  }
}
