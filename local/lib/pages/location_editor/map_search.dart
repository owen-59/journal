import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_journal/logger.dart";
import "package:local_journal/providers/osm_reverse_geocode.dart";
import "package:local_journal/utils/location.dart";
import "package:maplibre_gl/maplibre_gl.dart";
import "package:permission_handler/permission_handler.dart";
import "package:url_launcher/link.dart";

@RoutePage()
class MapSearchPage extends ConsumerStatefulWidget {
  final void Function(Location) onLocationPicked;
  const MapSearchPage({super.key, required this.onLocationPicked});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapSearchState();
}

class _MapSearchState extends ConsumerState<MapSearchPage> {
  LatLng? _lastClicked;
  bool _hasLocationPermissions = false;
  late MapLibreMapController controller;

  @override
  void initState() {
    super.initState();
    () async {
      final locationPermissionsGranted =
          await Permission.locationWhenInUse.isGranted;
      setState(() => _hasLocationPermissions = locationPermissionsGranted);
    }();
  }

  @override
  Widget build(BuildContext context) {
    final reverseResults = ref.watch(osmReverseGeocodeProvider(_lastClicked));

    return SafeArea(
      child: Stack(
        alignment: AlignmentGeometry.bottomStart,
        children: [
          MapLibreMap(
            styleString: "https://tiles.openfreemap.org/styles/bright",
            myLocationEnabled: _hasLocationPermissions,
            onMapClick: (point, latlng) {
              logger.i("$point, $latlng");
              setState(() => _lastClicked = latlng);
            },
            onMapCreated: (controller) =>
                setState(() => this.controller = controller),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsetsGeometry.only(right: 4.0, bottom: 4.0),
                child: IconButton.filled(
                  icon: Icon(Icons.location_pin),
                  onPressed: () async {
                    final isGranted = await Permission.locationWhenInUse
                        .request()
                        .isGranted;
                    setState(() => _hasLocationPermissions = isGranted);
                    final location = await controller.requestMyLocationLatLng();

                    if (isGranted && location != null) {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: location, zoom: 12.0),
                        ),
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.0),
                color: Theme.of(context).colorScheme.inverseSurface,
                child: Link(
                  uri: Uri.parse("https://openstreetmap.org/copyright"),
                  target: LinkTarget.blank,
                  builder: (context, followLink) => Text(
                    "\u2764 © OpenStreetMap contributors",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsetsGeometry.symmetric(
                  horizontal: 4.0,
                  vertical: 6.0,
                ),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(switch (reverseResults) {
                        AsyncData(:final value) =>
                          value != null
                              ? (value.name?.isNotEmpty ?? false
                                        ? value.name
                                        : null) ??
                                    (value.displayName?.isNotEmpty ?? false
                                        ? value.displayName
                                        : null) ??
                                    "${value.latitude}, ${value.longitude}"
                              : "",
                        _ => "",
                      }, style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    ?reverseResults.hasValue
                        ? IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () =>
                                widget.onLocationPicked(reverseResults.value!),
                          )
                        : null,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
