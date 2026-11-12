import "package:auto_route/auto_route.dart";
import "package:web_frontend/router.gr.dart";

@AutoRouterConfig(replaceInRouteName: "Screen|Page,Route")
class AppRouter extends RootStackRouter {
  RouteType get defaultRootType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, path: "/"),
    AutoRoute(page: EntryRoute.page, path: "/entry/:id"),
    AutoRoute(page: NotFoundRoute.page, path: "*"),
  ];
}
