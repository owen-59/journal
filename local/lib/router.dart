import "package:auto_route/auto_route.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/guards/fs_guard.dart";
import "package:local_journal/router.gr.dart";

@AutoRouterConfig(replaceInRouteName: "Page,Route")
class AppRouter extends RootStackRouter {
  final WidgetRef ref;

  AppRouter({required this.ref});

  @override
  RouteType get defaultRouteType => RouteType.custom(
    transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 150),
  );

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: FolderSelectionRoute.page),
    AutoRoute(
      page: HomeRoute.page,
      initial: true,
      children: [
        AutoRoute(page: EntryListRoute.page),
        AutoRoute(page: MapRoute.page),
        AutoRoute(page: CalendarRoute.page),
      ],
    ),
    AutoRoute(page: EntryEditorRoute.page),
    AutoRoute(
      page: LocationEditorRoute.page,
      children: [
        AutoRoute(page: MapSearchRoute.page),
        AutoRoute(page: NameSearchRoute.page),
      ],
    ),
  ];

  @override
  late final List<AutoRouteGuard> guards = [
    FsGuard(ref: ref)
  ];
}
