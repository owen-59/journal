import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/database.dart";
import "package:local_journal/providers/location_preset_provider.dart";
import "package:local_journal/router.gr.dart";
import "package:local_journal/utils/location.dart";
import "package:local_journal/widgets/error_card.dart";
import "package:local_journal/widgets/location_preset_edit_dialogue.dart";

@RoutePage()
class LocationPresetEditorPage extends ConsumerStatefulWidget {
  const LocationPresetEditorPage({super.key});

  @override
  ConsumerState<LocationPresetEditorPage> createState() =>
      _LocationPresetEditorState();
}

class _LocationPresetEditorState
    extends ConsumerState<LocationPresetEditorPage> {
  @override
  Widget build(BuildContext context) {
    final locationPresets = ref.watch(locationPresetProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Location presets")),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddLocationClicked,
        child: const Icon(Icons.create),
      ),
      body: switch (locationPresets) {
        AsyncData(value: final locationPresets)
            when locationPresets.isNotEmpty =>
          ListView(
            children: locationPresets
                .map(
                  (preset) => Card.outlined(
                    child: ListTile(
                      contentPadding: const EdgeInsetsDirectional.only(
                        start: 16.0,
                        end: 8.0,
                      ),
                      title: Text(
                        preset.name ??
                            preset.displayName ??
                            "${preset.latitude}, ${preset.longitude}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEditPresetClicked(preset),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        AsyncData() => const Center(
          child: Text("No presets have been created."),
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error, :final stackTrace) => ErrorCard(
          error: error,
          stackTrace: stackTrace,
        ),
      },
    );
  }

  Future<void> onAddLocationClicked() async {
    final location = await context.pushRoute<Location>(LocationEditorRoute());

    if (location == null) return;

    ref.read(locationPresetProvider.notifier).addPreset(location);
  }

  Future<void> onEditPresetClicked(LocationPreset preset) async {
    final newLocation = await showDialog<Location>(
      context: context,
      builder: (_) => LocationPresetEditDialogue(
        initialLocation: Location(
          displayName: preset.displayName,
          name: preset.name,
          longitude: preset.longitude,
          latitude: preset.latitude,
        ),
      ),
    );

    if (newLocation == null) return;

    ref
        .read(locationPresetProvider.notifier)
        .editPreset(preset.id, newLocation);
  }
}
