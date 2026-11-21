import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/logger.dart";

base class RiverpodErrorLoggerObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace
  ) {
    logger.e(
      "Provider ${context.provider.name ?? context.provider.runtimeType} failed.",
      error: error,
      stackTrace: stackTrace
    );
  }
}
