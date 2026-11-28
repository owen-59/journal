import "package:flutter_test/flutter_test.dart";
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String mockPath;

  FakePathProviderPlatform(this.mockPath);

  @override
  Future<String?> getApplicationCachePath() async {
    return mockPath;
  }
}

