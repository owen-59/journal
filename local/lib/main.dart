import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/database.dart";
import "package:local_journal/logger.dart";
import "package:local_journal/app.dart";
import "package:local_journal/riverpod_error_logger.dart";
import "package:local_journal/worker.dart";
import "package:maplibre_gl/maplibre_gl.dart";
import "package:nominatim_flutter/nominatim_flutter.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:saf/saf.dart";
import "package:saf_stream/saf_stream.dart";

part "main.g.dart";

void main() async {
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message?.contains("IsolateController") ?? false) return;
    debugPrintThrottled(message, wrapWidth: wrapWidth);
  };

  logger.i("Starting main()");
  WidgetsFlutterBinding.ensureInitialized();
  MapLibreMap.preWarm();
  final database = AppDatabase();
  final workerManager = WorkerManager();

  NominatimFlutter.instance.configureNominatim(
    useCacheInterceptor: true,
    maxStale: Duration(days: 14),
    userAgent: "LocalJournal/1.9.3 (owen00064@gmail.com)",
    convertFormData: true,
  );

  runApp(
    ProviderScope(
      observers: [
        RiverpodErrorLoggerObserver()
      ],
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        workerManagerProvider.overrideWithValue(workerManager)
      ],
      retry: (_, _) => null,
      child: App(),
    ),
  );
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  logger.w("Using non-overridden AppDatabase.");
  return AppDatabase();
}

@Riverpod(keepAlive: true)
WorkerManager workerManager(Ref ref) {
  logger.w("Using non-overridden WorkerManager.");
  return WorkerManager();
}

@Riverpod(keepAlive: true)
Saf saf(Ref ref) {
  return Saf();
}

@Riverpod(keepAlive: true)
SafStream safStream(Ref ref) {
  return SafStream();
}
