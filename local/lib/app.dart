import "dart:async";
import "dart:io";

import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:flutter_keyboard_controller/flutter_keyboard_controller.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/logger.dart";
import "package:local_journal/providers/entry_list.dart";
import "package:local_journal/router.dart";
import "package:local_journal/router.gr.dart";
import "package:share_handler/share_handler.dart";

final GlobalKey _providerScopeKey = GlobalKey();

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final _appRouter = AppRouter(ref: ref);
  late final ProviderContainer _providerContainer;

  @override
  void initState() {
    super.initState();
    _initSharingIntent();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initProviderContainer();
  }

  Future<void> _initSharingIntent() async {
    final handler = ShareHandlerPlatform.instance;
    final media = await handler.getInitialSharedMedia();
    if (media != null) _onMediaShared(media);

    handler.sharedMediaStream.listen(_onMediaShared);
  }

  void _initProviderContainer() {
    _providerContainer = ProviderContainer(
      parent: ProviderScope.containerOf(context),
      retry: (_, _) => null,
    );
  }

  Future<void> _onMediaShared(SharedMedia media) async {
    if (media.attachments?.isNotEmpty ?? false) {
      final file = media.attachments![0]!;

      try {
        final entryList = _providerContainer.read(entryListProvider.notifier);
        final entryDt = await entryList.createEntryWithImage(File(file.path));
        logger.d("Going to /entry/$entryDt from sharing intent.");
        _appRouter.push(EntryEditorRoute(dt: entryDt));
      } catch (err, stackTrace) {
        logger.e("$err: $stackTrace", stackTrace: stackTrace);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: _providerContainer,
      key: _providerScopeKey,
      child: DynamicColorBuilder(
        builder: (light, dark) => KeyboardProvider(
          child: MaterialApp.router(
            routerConfig: _appRouter.config(),
            theme: ThemeData(
              colorScheme:
                  light ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              scaffoldBackgroundColor: light?.surface,
              canvasColor: light?.surface,
            ),
            darkTheme: ThemeData(
              colorScheme:
                  dark ??
                  ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.dark,
                  ),
              scaffoldBackgroundColor: dark?.surface,
              canvasColor: dark?.surface,
            ),
          ),
        ),
      ),
    );
  }
}
