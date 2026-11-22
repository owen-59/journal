import "dart:async";

import "package:drift/drift.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/database.dart";
import "package:local_journal/main.dart";
import "package:local_journal/utils/location.dart";

final locationPresetProvider =
    AsyncNotifierProvider.autoDispose<
      LocationPresetNotifier,
      List<LocationPreset>
    >(LocationPresetNotifier.new);

class LocationPresetNotifier extends AsyncNotifier<List<LocationPreset>> {
  @override
  Future<List<LocationPreset>> build() async {
    final database = ref.watch(appDatabaseProvider);
    final presets = await database.managers.locationPresets.get();
    return presets;
  }

  Future<void> addPreset(Location location) async {
    final database = ref.watch(appDatabaseProvider);

    final locationCompanion = LocationPresetsCompanion.insert(
      latitude: location.latitude,
      longitude: location.longitude,
      name: Value(location.name),
      displayName: Value(location.displayName),
    );

    await database.into(database.locationPresets).insert(locationCompanion);

    ref.invalidateSelf();
  }

  Future<void> editPreset(int id, Location location) async {
    final database = ref.read(appDatabaseProvider);

    final preset = LocationPreset(
      id: id,
      name: location.name,
      displayName: location.displayName,
      longitude: location.longitude,
      latitude: location.latitude,
    );

    await database.update(database.locationPresets).replace(preset);
    ref.invalidateSelf();
  }
}
