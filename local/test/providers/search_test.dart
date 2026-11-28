import "package:drift/drift.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:local_journal/database.dart";
import "package:local_journal/main.dart";
import "package:local_journal/providers/search.dart";
import "package:local_journal/providers/tags_list.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

ProviderContainer _setupTests(AppDatabase db) {
  return ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [appDatabaseProvider.overrideWithValue(db)],
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() {
    db.close();
  });

  group("searchProvider", () {
    test(
      "returns null if query is empty & an empty list is returned.",
      () async {
        final container = _setupTests(db);

        final results = await container.read(
          searchProvider((query: " ", tags: [])).future,
        );
        expect(results, []);
      },
    );

    test("resulting entries only contain search terms & tags.", () async {
      final container = _setupTests(db);

      final target = EntriesCacheCompanion.insert(
        tags: ["tag1", "no"],
        body: Value("xx query xx"),
        createdDate: DateTime(1971),
        lastCheckedAt: DateTime(1970),
      );

      db.batch((b) {
        b.insertAll(db.entriesCache, [
          ...["noo", "no", "nope", "xx query xx"].map(
            (s) => EntriesCacheCompanion.insert(
              tags: [],
              body: Value(s),
              createdDate: DateTime(1970, s.length),
              lastCheckedAt: DateTime(1970),
            ),
          ),
          ...[
            ["no", "nope"],
            ["tag2"],
          ].map(
            (t) => EntriesCacheCompanion.insert(
              tags: t,
              createdDate: DateTime(1970, t.length * 5),
              lastCheckedAt: DateTime(1970),
            ),
          ),
          target,
        ]);
      });

      final results = await container.read(
        searchProvider((query: " query ", tags: ["tag1", "tag2"])).future,
      );

      final result = results[0];

      expect(target.body.toString(), Value(result.body).toString());
      expect(target.tags.toString(), Value(result.tags).toString());
    });
  });
}
