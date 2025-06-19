import 'package:flutter/material.dart';
import 'select_feed_source_page.dart';

class WideDetectionOptionPage extends StatelessWidget {
  const WideDetectionOptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wide Detection Feed Type")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SelectFeedSourcePage(feedType: 'bowler'),
                  ),
                );
              },
              child: const Text("Bowler Feed"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SelectFeedSourcePage(feedType: 'batsman'),
                  ),
                );
              },
              child: const Text("Batsman Feed"),
            ),
          ],
        ),
      ),
    );
  }
}
