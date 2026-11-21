import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:local_journal/logger.dart";
import "package:saf/saf.dart";

@RoutePage()
class FolderSelectionPage extends StatelessWidget {
  final Saf saf;
  final void Function(String) onGranted;

  FolderSelectionPage({
    super.key,
    required this.onGranted,
    Saf? saf
  }) : saf = saf ?? Saf();

  Future<void> _requestFolder(BuildContext context) async {
    try {
      final SafDocumentFile? dir = await saf.pickDirectory();

      if (dir != null) {
        onGranted(dir.uri);
      }
    } catch (e) {
      logger.e("Error when getting a choosing a directory.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_shared, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  "Access Required",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Please select a folder where your Markdown files are stored. The app requires this to function.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _requestFolder(context),
                  child: const Text("Grant Folder Access"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
