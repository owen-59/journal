import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/providers/location_preset_provider.dart";
import "package:local_journal/router.gr.dart";
import "package:local_journal/utils/location.dart";
import "package:local_journal/widgets/error_card.dart";

class PresetLocationChooser extends ConsumerWidget {
  const PresetLocationChooser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationPresets = ref.watch(locationPresetProvider);

    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (locationPresets) {
            AsyncData(value: final locationPresets)
                when locationPresets.isNotEmpty =>
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: ListView(
                  children: locationPresets
                      .map(
                        (preset) => Card.outlined(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(
                              preset.name ??
                                  preset.displayName ??
                                  "${preset.latitude}, ${preset.longitude}",
                            ),
                            onTap: () => context.pop<Location>(
                              Location.fromPreset(preset),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            AsyncData() => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("No location presets have been created."),
                  TextButton.icon(
                    icon: const Icon(Icons.create),
                    label: const Text("Create some here."),
                    onPressed: () =>
                        context.navigateTo(LocationPresetEditorRoute()),
                  ),
                ],
              ),
            ),
            AsyncLoading() => const Center(child: CircularProgressIndicator()),
            AsyncError(:final error, :final stackTrace) => ErrorCard(
              error: error,
              stackTrace: stackTrace,
            ),
          },
        ),
      ),
    );
  }
}
