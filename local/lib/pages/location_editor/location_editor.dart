import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/router.gr.dart";
import "package:local_journal/utils/location.dart";

@RoutePage()
class LocationEditorPage extends ConsumerStatefulWidget {
  const LocationEditorPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LocationEditorState();
}

class _LocationEditorState extends ConsumerState<LocationEditorPage> {
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
        NameSearchRoute(
          onLocationPicked: (location) => context.pop<Location>(location),
        ),
        MapSearchRoute(
          onLocationPicked: (location) => context.pop<Location>(location),
        ),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final isSearchMode = tabsRouter.activeIndex == 0;

        return Scaffold(
          resizeToAvoidBottomInset: isSearchMode,
          appBar: AppBar(
            actions: [
              IconButton(
                icon: Icon(isSearchMode ? Icons.map : Icons.search),
                onPressed: () =>
                    tabsRouter.setActiveIndex(isSearchMode ? 1 : 0),
              ),
            ],
          ),
          body: child,
        );
      },
    );
  }
}
