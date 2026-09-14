import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_table/main.dart';

void main() {
  testWidgets('SketchTaleApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SketchTaleApp());
    await tester.pump(const Duration(milliseconds: 200));

    // Verify that title SketchTale is rendered
    expect(find.text('SketchTale'), findsOneWidget);
    // Verify that Thư viện truyện is rendered
    expect(find.text('Thư Viện Truyện'), findsOneWidget);
  });
}
