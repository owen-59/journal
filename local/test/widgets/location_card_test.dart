import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:local_journal/utils/location.dart";
import "package:local_journal/widgets/location_card.dart";

Future<void> _setupTests(WidgetTester tester, Location location) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: LocationCard(
            location: location,
          )
        )
      )
    );

}

void main() {
  group("LocationCard", () {
    testWidgets("Shows name when available.", (tester) async {
      await _setupTests(tester, Location(
        name: "NAME",
        displayName: "DISPLAY",
        longitude: 0,
        latitude: 0
      ));

      expect(find.text("NAME"), findsOne);
    });

    testWidgets("Shows display name when available and name not available.", (tester) async {
      await _setupTests(tester, Location(
        name: null,
        displayName: "DISPLAY",
        longitude: 0,
        latitude: 0,
      ));

      expect(find.text("DISPLAY"), findsOne);
    });

    testWidgets("Shows coordinates when name and display name are not available.", (tester) async {
      await _setupTests(tester, Location(
        name: null,
        displayName: null,
        latitude: 3.5,
        longitude: 1.5,
      ));

      expect(find.text("3.5, 1.5"), findsOne);
    });
  });
}
