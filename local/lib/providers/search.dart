import "package:drift/drift.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/database.dart";
import "package:local_journal/main.dart";

typedef SearchParams = ({String query, List<String> tags});

final searchProvider = FutureProvider.autoDispose
    .family<List<EntriesCacheData>, SearchParams>((
      ref,
      SearchParams params,
    ) async {
      if (params.query.trim().isEmpty && params.tags.isEmpty) return [];
      final db = ref.watch(appDatabaseProvider);

      final dbQuery = db.select(db.entriesCache);
      if (params.query.trim().isNotEmpty) {
        dbQuery.where((u) => u.body.like("%${params.query}%"));
      }

      final results = await dbQuery.get();
      if (params.tags.isEmpty) return results;
      final tagFilteredResults = results
          .where((e) => e.tags.any((t) => params.tags.contains(t)))
          .toList();
      return tagFilteredResults;
    });
