// File: lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'select_source_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cricket Detection Tools'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DetectionCard(
              title: 'Detect Wide Ball',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WideDetectionOptionPage(),
                  ),
                );
              },
              isEnabled: true,
            ),
            const SizedBox(height: 20),
            const DetectionCard(title: 'Detect LBW', isEnabled: false),
            const SizedBox(height: 20),
            const DetectionCard(title: 'Other Feature', isEnabled: false),
          ],
        ),
      ),
    );
  }
}

class DetectionCard extends StatelessWidget {
  final String title;
  final bool isEnabled;
  final VoidCallback? onTap;

  const DetectionCard({
    super.key,
    required this.title,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Card(
        color: isEnabled ? Colors.white : Colors.grey[300],
        elevation: isEnabled ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
