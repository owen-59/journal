import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/logger.dart";
import "package:local_journal/pages/entry_list.dart";
import "package:local_journal/pages/search.dart";
import "package:local_journal/providers/cache_entries.dart";
import "package:local_journal/providers/entry_list.dart";
import "package:local_journal/router.gr.dart";

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomePage> {
  final _pageController = PageController();
  final GlobalKey<EntryListState> _entryListKey = GlobalKey();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
        EntryListRoute(key: _entryListKey),
        MapRoute(),
        CalendarRoute(
          goToDate: (dt, BuildContext context) {
            final tabsRouter = AutoTabsRouter.of(context);
            tabsRouter.setActiveIndex(0);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _entryListKey.currentState?.jumpToDate(dt);
            });
          },
        ),
        ExtrasRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          appBar: AppBar(
            title: Text("Journal"),
            actions: [
              ?switch (tabsRouter.activeIndex) {
                0 => IconButton(
                  icon: Icon(Icons.calendar_month),
                  onPressed: () => onDateClicked(context, ref),
                ),
                1 || 2 => IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    ref.invalidate(cacheEntriesProvider);
                  },
                ),
                _ => null,
              },
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SearchPage()),
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: (index) => tabsRouter.setActiveIndex(index),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home),
                label: "Home",
              ),
              NavigationDestination(icon: const Icon(Icons.map), label: "Map"),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month),
                label: "Calendar",
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu),
                label: "Menu",
              ),
            ],
          ),
          floatingActionButton: tabsRouter.activeIndex == 0
              ? FloatingActionButton(
                  onPressed: () => createEntry(context, ref),
                  child: const Icon(Icons.create),
                )
              : null,
        );
      },
    );
  }

  Future<void> createEntry(BuildContext context, WidgetRef ref) async {
    final entryDatetime = await ref.read(entryListProvider.notifier).newEntry();

    if (context.mounted) {
      context.pushRoute(EntryEditorRoute(dt: entryDatetime));
    } else {
      logger.w("Created an entry, but the context was no longer valid.");
    }
  }

  void onDateClicked(BuildContext context, WidgetRef ref) {
    ref.read(entryListProvider).whenData((entries) async {
      final chosenDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now().isAfter(entries.first)
            ? entries.first
            : DateTime.now().isBefore(entries.last)
            ? entries.last
            : DateTime.now(),
        firstDate: entries.last,
        lastDate: entries.first,
      );
      if (chosenDate == null) return;

      _entryListKey.currentState?.jumpToDate(chosenDate);
    });
  }
}
