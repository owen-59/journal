import "package:flutter/material.dart";
import "package:local_journal/providers/cache_entries.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

part "day_info.g.dart";

class DayInfo {
  final bool hasEntries;

  const DayInfo({required this.hasEntries});
}

@riverpod
Future<DayInfo?> dayInfo(Ref ref, DateTime dt) async {
  final entries = await ref.watch(cacheEntriesProvider.future);
  final dayEntries = entries.where(
    (entry) => DateUtils.isSameDay(entry.createdDate, dt),
  );

  final hasEntries = dayEntries.isNotEmpty;
  return DayInfo(hasEntries: hasEntries);
}
