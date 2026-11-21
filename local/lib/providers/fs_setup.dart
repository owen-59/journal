import "package:local_journal/data_folder.dart";
import "package:local_journal/logger.dart";
import "package:local_journal/main.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:shared_preferences/shared_preferences.dart";

part "fs_setup.g.dart";

@Riverpod(keepAlive: true)
class FsSetup extends _$FsSetup {
  @override
  Future<bool> build() async {
    logger.d("Checking file system permissions.");
    final prefs = SharedPreferencesAsync();
    final saf = ref.watch(safProvider);
    final String? cachedUri = await prefs.getString("saf_authorised_uri");

    final permissions = await saf.persistedPermissions();
    if (permissions.isEmpty) return false;
    final matchingPermissions = permissions
        .where((permission) => cachedUri?.startsWith(permission.uri) ?? false)
        .toList();
    if (matchingPermissions.isNotEmpty) {
      DataFolder().setFolder(matchingPermissions[0].uri);
      logger.i("fsSetup: true and uri was set.");
      return true;
    }
    logger.w(
      "Permissions was not empty, but no permissions matched $cachedUri: $permissions",
    );

    return false;
  }

  Future<void> setUri(String uri) async {
    final prefs = SharedPreferencesAsync();
    prefs.setString("saf_authorised_uri", uri);
    DataFolder().setFolder(uri);
  }
}
