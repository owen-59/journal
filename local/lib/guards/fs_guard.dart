import "package:auto_route/auto_route.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/providers/fs_setup.dart";
import "package:local_journal/router.gr.dart";

class FsGuard extends AutoRouteGuard {
  final WidgetRef ref;

  FsGuard({required this.ref});

  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    final fsSetup = await ref.read(fsSetupProvider.future);

    if (fsSetup || resolver.routeName == FolderSelectionRoute.name) {
      resolver.next();
    } else {
      resolver.redirectUntil(FolderSelectionRoute(
        onGranted: (uri) {
          ref.read(fsSetupProvider.notifier).setUri(uri);
          resolver.next();
        }
      ));
    }
  }
}
