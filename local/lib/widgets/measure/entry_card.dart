import "package:flutter/widgets.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/models/entry.dart";
import "package:local_journal/providers/entry.dart";
import "package:local_journal/providers/entry_main_image.dart";
import "package:local_journal/widgets/entry_card.dart";
import "package:measured/measured.dart";

class EntryCardMeasurer extends StatelessWidget {
  final void Function(double) onChanged;
  const EntryCardMeasurer({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Offstage(
      child: ProviderScope(
        overrides: [
          entryProvider.overrideWithBuild(
            (_, _) => Entry(
              location: null,
              images: [],
              tags: [],
              datetime: DateTime.now(),
              body: "",
            ),
          ),
          entryMainImageProvider.overrideWith((_, _) => null),
        ],
        child: Measured(
          onChanged: (size) => onChanged(size.height),
          child: EntryCard(
            entryDt: DateTime.now().copyWith(
              hour: 0,
              minute: 0,
              second: 0,
              millisecond: 0,
              microsecond: 0,
            ),
          ),
        ),
      ),
    );
  }
}
