import "package:flutter_test/flutter_test.dart";
import "package:local_journal/database.dart";
import "package:local_journal/providers/cache_entries.dart";
import "package:local_journal/providers/tags_list.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

void main() {
  group("tagsProvider", () {
    test("contains all tags", () async {
      final container = ProviderContainer.test(
        retry: (_,_) => null,
        overrides: [
          cacheEntriesProvider.overrideWithValue(AsyncData([
            EntriesCacheData(
              tags: ["tag1", "tag2"],
              createdDate: DateTime(1970),
              lastCheckedAt: DateTime(1970),
            ),
            EntriesCacheData(
              tags: ["tag3", "tag1"],
              createdDate: DateTime(1970),
              lastCheckedAt: DateTime(1970),
            )
          ]))
        ]
      );

      final tags = await container.read(tagsProvider.future);
      expect(tags, [
        TagEntry(
          name: "tag2",
          frequency: 1
        ),
        TagEntry(
          name: "tag3",
          frequency: 1
        ),
        TagEntry(
          name: "tag1",
          frequency: 2
        )
      ]);
    });
  });

  group("TagEntry", () {
    test("same values are equal to equality", () {
      final a = TagEntry(
        name: "tag",
        frequency: 1,
      );
      final b = TagEntry(
        name: "tag",
        frequency: 1,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), b.toString());
    });
  });
}
