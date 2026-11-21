import "package:local_journal/logger.dart";

class DataFolder {
  String? _state;
  DataFolder._internal();

  static final DataFolder _instance = DataFolder._internal();

  factory DataFolder() => _instance;

  void setFolder(String uri) {
    logger.d("Set data folder uri to $uri.");
    _state = uri;
  }

  String getFolder() {
    if (_state != null) {
      return _state!;
    }
    throw Exception("Accessed folderUri before uri was set.");
  }
}
