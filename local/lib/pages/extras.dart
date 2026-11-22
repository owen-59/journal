import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:local_journal/router.gr.dart";

@RoutePage()
class ExtrasPage extends StatelessWidget {
  const ExtrasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 4.0),
      child: ListView(
        children: [
          Card.outlined(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.location_pin),
              title: Text("Preset locations"),
              onTap: () => context.pushRoute(LocationPresetEditorRoute()),
            ),
          ),
        ],
      ),
    );
  }
}
