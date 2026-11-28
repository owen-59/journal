import "dart:async";
import "dart:io";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_keyboard_controller/flutter_keyboard_controller.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";
import "package:intl/intl.dart";
import "package:local_journal/models/entry.dart";
import "package:local_journal/logger.dart";
import "package:local_journal/providers/entry.dart";
import "package:local_journal/router.gr.dart";
import "package:local_journal/utils/exif.dart";
import "package:local_journal/utils/location.dart";
import "package:local_journal/widgets/confirm_dialogue.dart";
import "package:local_journal/widgets/error_card.dart";
import "package:local_journal/widgets/images_list.dart";
import "package:local_journal/widgets/location_card.dart";
import "package:local_journal/widgets/preset_location_chooser.dart";
import "package:local_journal/widgets/tags_editor.dart";
import "package:local_journal/widgets/text_input.dialogue.dart";
import "package:markdown_editor_live/markdown_editor_live.dart";
import "package:path/path.dart" as path;

@RoutePage()
class EntryEditorPage extends ConsumerStatefulWidget {
  final DateTime dt;
  const EntryEditorPage({super.key, required this.dt});

  @override
  ConsumerState<EntryEditorPage> createState() => _EntryEditorState();
}

class _EntryEditorState extends ConsumerState<EntryEditorPage> {
  String body = "";
  bool hasBeenEdited = false;
  var saveTimer = Timer(const Duration(), () {});

  @override
  Widget build(BuildContext context) {
    final entry = ref.watch(entryProvider(widget.dt));

    ref.listen(entryProvider(widget.dt), (prev, next) {
      next.whenOrNull(data: (data) => body = data.body);
    });

    return switch (entry) {
      AsyncData(:final value) => Scaffold(
        appBar: AppBar(
          title: Text(DateFormat("dd MMMM HH:mm").format(widget.dt)),
        ),
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (innerContext) => PopScope(
            onPopInvokedWithResult: (didPop, object) =>
                onGoBack(didPop, context, object, value),
            child: SafeArea(
              child: KeyboardAvoidingView(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MarkdownEditor(
                              initialValue: value.body,
                              autofocus: true,
                              onChanged: (text) => setState(() {
                                body = text;
                                hasBeenEdited = true;
                                saveTimer.cancel();
                                saveTimer = Timer(
                                  Duration(milliseconds: 100),
                                  () => save(value),
                                );
                              }),
                            ),

                            if (value.location != null)
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ) +
                                    EdgeInsets.only(top: 4),
                                child: LocationCard(location: value.location!),
                              ),

                            Padding(
                              padding: EdgeInsetsGeometry.all(8),
                              child: Wrap(
                                spacing: 8,
                                children: [
                                  for (final tag in value.tags)
                                    Chip(label: Text(tag)),
                                ],
                              ),
                            ),
                            ImagesList(
                              entryDt: value.datetime,
                              names: value.images,
                              removeCallback: (imageData) =>
                                  onRemoveImageLink(value, imageData),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(8.0),
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.label_outline),
                            onPressed: () => onAddTagsClicked(context, value),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            onPressed: () => onAddImageClicked(context, value),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.schedule),
                            onPressed: () => onSetTimeClicked(context, value),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () => onSetDateClicked(context, value),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.edit_location_outlined),
                            onPressed: () =>
                                onSetLocationClicked(context, value),
                            onLongPress: () =>
                                onSetPresetLocationClicked(context, value),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => onDeleteClicked(context, value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      AsyncError(:final error, :final stackTrace) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: ErrorCard(error: error, stackTrace: stackTrace),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  void onGoBack(
    bool didPop,
    BuildContext context,
    Object? popObject,
    Entry entry,
  ) {
    if (!didPop || popObject == "DO_NOT_WRITE" || !hasBeenEdited) return;
    save(entry);
  }

  void save(Entry entry) {
    ref
        .read(entryProvider(widget.dt).notifier)
        .writeWith(body: getCurrentContents(entry));
  }

  Future<void> setDatetime(
    DateTime datetime,
    Entry entry,
    BuildContext context,
  ) async {
    final newEntry = await ref
        .read(entryProvider(widget.dt).notifier)
        .writeWith(body: getCurrentContents(entry), datetime: datetime);

    if (context.mounted) {
      context.replaceRoute(EntryEditorRoute(dt: newEntry.datetime));
    } else {
      logger.w("Updating time took too long, context unmounted.");
    }
  }

  Future<void> onSetDateClicked(BuildContext context, Entry entry) async {
    final DateTime? datetime = await showDatePicker(
      context: context,
      initialDate: entry.datetime,
      firstDate: DateTime.now().subtract(Duration(days: 365000)),
      lastDate: DateTime.now().add(Duration(days: 365000)),
    );
    if (datetime == null) return;
    await setDatetime(
      datetime.copyWith(
        hour: entry.datetime.hour,
        minute: entry.datetime.minute,
      ),
      entry,
      // ignore: use_build_context_synchronously - because it's checked in setDatetime
      context,
    );
  }

  Future<void> onSetTimeClicked(BuildContext context, Entry entry) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(entry.datetime),
    );

    if (time == null) return;
    await setDatetime(
      entry.datetime.copyWith(hour: time.hour, minute: time.minute),
      entry,
      // ignore: use_build_context_synchronously - because it's checked in setDatetime
      context,
    );
  }

  Future<void> onAddTagsClicked(BuildContext context, Entry entry) async {
    final tags = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TagsEditor(initialTags: entry.tags),
    );
    if (tags == null) {
      logger.w("Tags editor did not return a list?");
      return;
    }
    await ref
        .read(entryProvider(widget.dt).notifier)
        .writeWith(body: getCurrentContents(entry), tags: tags);
  }

  Future<void> onDeleteClicked(BuildContext context, Entry entry) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialogue(
        titleText: "Delete?",
        description: "Are you sure you want to delete this entry?",
        cancelText: "Cancel",
        confirmText: "Delete",
        isDestructive: true,
      ),
    );

    if (result == true) {
      ref.read(entryProvider(widget.dt).notifier).delete();
      if (context.mounted) context.pop("DO_NOT_WRITE");
    }
  }

  Future<void> onAddImageClicked(BuildContext context, Entry entry) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    if (context.mounted) {
      final name = await showDialog<String>(
        context: context,
        builder: (context) => TextInputDialog(),
      );
      if (name == null) return;

      final bytes = await image.readAsBytes();
      final imageDt = await datetimeFromExif(bytes);

      final shouldUseImageDt =
          imageDt != null &&
          context.mounted &&
          (await showDialog<bool>(
                context: context,
                builder: (context) => ConfirmDialogue(
                  titleText: "Use image date?",
                  description: "Should this date be changed to $imageDt?",
                  cancelText: "No",
                  confirmText: "Yes",
                  isDestructive: false,
                ),
              ) ==
              true);

      if (shouldUseImageDt) {
        final newEntry = await ref
            .read(entryProvider(widget.dt).notifier)
            .writeWith(datetime: imageDt, body: getCurrentContents(entry));
        await ref
            .read(entryProvider(newEntry.datetime).notifier)
            .addImage(bytes, name, path.extension(image.path));
        await ref.read(entryProvider(newEntry.datetime).notifier).writeWith();
        if (context.mounted) {
          context.replaceRoute(EntryEditorRoute(dt: newEntry.datetime));
        }
      } else {
        await ref
            .read(entryProvider(widget.dt).notifier)
            .addImage(bytes, name, path.extension(image.path));
      }
    }
  }

  Future<void> onRemoveImageLink(Entry entry, String imageData) async {
    logger.d("Removing $imageData from ${entry.datetime}");
    await ref.read(entryProvider(widget.dt).notifier).removeImage(imageData);
  }

  Future<void> onSetLocationClicked(BuildContext context, Entry entry) async {
    final location = await context.pushRoute<Location>(LocationEditorRoute());

    if (location == null) return;
    await ref
        .read(entryProvider(widget.dt).notifier)
        .writeWith(body: getCurrentContents(entry), location: location);
  }

  Future<void> onSetPresetLocationClicked(
    BuildContext context,
    Entry entry,
  ) async {
    final location = await showModalBottomSheet<Location>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PresetLocationChooser(),
    );

    await ref
        .read(entryProvider(widget.dt).notifier)
        .writeWith(body: getCurrentContents(entry), location: location);
  }

  String getCurrentContents(Entry entry) {
    saveTimer.cancel();
    if (hasBeenEdited) return body;
    return entry.body;
  }
}
