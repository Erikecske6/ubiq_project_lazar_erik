import 'package:flutter_test/flutter_test.dart';
import 'package:plant_tracker/main.dart'; // This imports your actual app

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame.
    await tester.pumpWidget(const PlantTrackerApp());

    // 2. Verify that our app successfully boots up and shows the title
    expect(find.text('Plant Tracker 🌿'), findsOneWidget);
  });
}