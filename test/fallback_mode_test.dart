import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_table/state/app_state.dart';
import 'package:sketch_table/widgets/fallback_indicator.dart';

void main() {
  group('Fallback & Offline Resilience Tests', () {
    test('AppState initially tracks fallback mode for offline safety', () {
      final state = AppState();

      expect(state.isFallbackMode, isTrue);
      expect(state.fallbackStatus['Hồ Sơ Của Bé'], isTrue);
      expect(state.fallbackStatus['Thư Viện Truyện'], isTrue);
      expect(state.fallbackStatus['Chủng Loại Nhân Vật'], isTrue);
      expect(state.activeFallbackFeatures, contains('Hồ Sơ Của Bé'));
    });

    test('AppState setFallbackStatus correctly updates and notifies listeners', () {
      final state = AppState();
      int notifyCount = 0;
      state.addListener(() => notifyCount++);

      state.setFallbackStatus('Hồ Sơ Của Bé', false);
      expect(state.fallbackStatus['Hồ Sơ Của Bé'], isFalse);
      expect(notifyCount, 1);

      state.setFallbackStatus('Thư Viện Truyện', false);
      state.setFallbackStatus('Chủng Loại Nhân Vật', false);
      expect(state.isFallbackMode, isFalse);
      expect(state.activeFallbackFeatures, isEmpty);
      expect(notifyCount, 3);
    });

    testWidgets('FallbackStatusBar shows banner when fallback is active and hides when inactive', (tester) async {
      final state = AppState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FallbackStatusBar(appState: state),
          ),
        ),
      );

      // Should find the fallback status bar
      expect(find.byType(FallbackStatusBar), findsOneWidget);
      expect(find.textContaining('Chế độ Ngoại Tuyến'), findsOneWidget);

      // Turn off fallback mode
      state.setFallbackStatus('Hồ Sơ Của Bé', false);
      state.setFallbackStatus('Thư Viện Truyện', false);
      state.setFallbackStatus('Chủng Loại Nhân Vật', false);
      await tester.pump();

      // Should be hidden (SizedBox.shrink)
      expect(find.textContaining('Chế độ Ngoại Tuyến'), findsNothing);
    });

    testWidgets('FallbackBadgeChip renders label and triggers tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FallbackBadgeChip(
              label: 'Dữ liệu mẫu',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Dữ liệu mẫu'), findsOneWidget);
      await tester.tap(find.byType(FallbackBadgeChip));
      expect(tapped, isTrue);
    });
  });
}

