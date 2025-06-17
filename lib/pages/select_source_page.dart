import 'package:flutter/material.dart';

class SelectSourcePage extends StatelessWidget {
  const SelectSourcePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Source"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to camera feed page
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("Use Camera"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to file picker (not implemented yet)
              },
              icon: const Icon(Icons.folder),
              label: const Text("Browse from Device"),
            ),
          ],
        ),
      ),
    );
  }
}
