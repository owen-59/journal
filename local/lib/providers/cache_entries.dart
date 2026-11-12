import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/database.dart";
import "package:local_journal/main.dart";

final cacheEntriesProvider = FutureProvider<List<EntriesCacheData>>((
  ref,
) async {
  final database = ref.watch(appDatabaseProvider);

  final entries = await database.managers.entriesCache.get();

  return entries;
});
