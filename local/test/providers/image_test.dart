import "dart:io";
import "dart:typed_data";

import "package:file/memory.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:local_journal/main.dart";
import "package:local_journal/providers/image.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:saf/saf.dart";

import "../mocks/path_provider.dart";
import "entry_list_test.mocks.dart";

@GenerateMocks([], customMocks: [MockSpec<Saf>(as: #MockSafClient)])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("ImageNotifier", () {
    test("loads cache if available", () async {
      final fs = MemoryFileSystem.test();
      final saf = MockSafClient();
      PathProviderPlatform.instance = FakePathProviderPlatform("/fake/cache/");

      final cachePath =
          "/fake/cache/images/${DateTime(1970)}-image.jpg-${QualityLevel.thumbnailSmall}.jpg";
      fs.file(cachePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync([1, 2, 3]);

      await IOOverrides.runZoned(
        () async {
          final container = ProviderContainer.test(
            retry: (_, _) => null,
            overrides: [safProvider.overrideWithValue(saf)],
          );

          container.listen(
            imageProvider(
              DateTime(1970),
              "image.jpg",
              QualityLevel.thumbnailSmall,
            ).future,
            (_, _) {},
          );

          final image = await container.read(
            imageProvider(
              DateTime(1970),
              "image.jpg",
              QualityLevel.thumbnailSmall,
            ).future,
          );

          expect(image, Uint8List.fromList([1, 2, 3]));
        },
        createFile: (path) => fs.file(path),
        createDirectory: (path) => fs.directory(path),
        fseGetType: (path, followLinks) =>
            fs.type(path, followLinks: followLinks),
        fseGetTypeSync: (path, followLinks) =>
            fs.typeSync(path, followLinks: followLinks),
      );

      verifyZeroInteractions(saf);
    });
  });
}
