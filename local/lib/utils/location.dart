import "package:local_journal/database.dart";

class Location {
  final double latitude;
  final double longitude;
  final String? name;
  final String? displayName;

  Location({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.displayName,
  });

  Location copyWith({
    double? latitude,
    double? longitude,
    String? name,
    String? displayName,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
    );
  }

  static Location fromPreset(LocationPreset preset) {
    return Location(
      latitude: preset.latitude,
      longitude: preset.longitude,
      name: preset.name,
      displayName: preset.displayName,
    );
  }
}
