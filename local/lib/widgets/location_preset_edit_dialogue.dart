import "package:flutter/material.dart";
import "package:local_journal/utils/location.dart";

class LocationPresetEditDialogue extends StatefulWidget {
  final Location initialLocation;
  const LocationPresetEditDialogue({super.key, required this.initialLocation});

  @override
  State<LocationPresetEditDialogue> createState() =>
      _LocationPresetEditDialogue();
}

class _LocationPresetEditDialogue extends State<LocationPresetEditDialogue> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.initialLocation.displayName,
    );
    _nameController = TextEditingController(text: widget.initialLocation.name);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: AlertDialog(
        title: const Text("Edit preset"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Name",
                hintText: "Tour Eiffel",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _displayNameController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: "Address",
                hintText: "Eiffel Tower, 5, Avenue Anatole...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final displayName = _displayNameController.text;
              final name = _nameController.text;
              Navigator.pop<Location>(
                context,
                widget.initialLocation.copyWith(
                  displayName: displayName,
                  name: name,
                ),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
