import "package:auto_route/auto_route.dart";
import "package:local_journal/router.gr.dart";

@AutoRouterConfig(replaceInRouteName: "Page,Route")
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.custom(
    transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 150)
  );

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: EntryEditorRoute.page)
  ];
}
