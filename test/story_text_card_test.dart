import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_table/widgets/story_player/story_text_card.dart';

void main() {
  group('StoryTextCard Karaoke Audio Highlighting Tests', () {
    test('parseStoryWordTokens tokenizes words and handles speech pause weights', () {
      const text = 'Sáng ấy, chú thỏ nhảy chân sáo. Rất vui!';
      final paragraphs = parseStoryWordTokens(text);

      expect(paragraphs.length, 1);
      final words = paragraphs.first.words;
      expect(words.length, 9); // Sáng, ấy,, chú, thỏ, nhảy, chân, sáo., Rất, vui!

      expect(words.first.text, 'Sáng');
      expect(words.first.startPct, closeTo(0.0, 0.001));
      expect(words.last.text, 'vui!');
      expect(words.last.endPct, closeTo(1.0, 0.001));

      // Words with punctuation should have higher weight than identical length plain words
      final sangWord = words.firstWhere((w) => w.text == 'Sáng');
      final ayWord = words.firstWhere((w) => w.text == 'ấy,');
      // 'ấy,' has length 3 + 2.5 comma pause = 5.5 weight
      expect(ayWord.weight, greaterThan(sangWord.weight));
    });

    testWidgets('StoryTextCard renders normal styling when audio is not playing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StoryTextCard(
              textContent: 'Bobby đang nằm trong vườn hoa xinh xắn.',
              showEnglish: false,
              isPlayingAudio: false,
              audioPosition: Duration.zero,
              audioDuration: Duration(seconds: 10),
            ),
          ),
        ),
      );

      // Verify narrator name is displayed
      expect(find.textContaining('Người kể: Chú Gấu Pô 🐻'), findsOneWidget);

      // Verify read-along pill is NOT visible when stopped
      expect(find.textContaining('Dõi theo giọng đọc'), findsNothing);

      // Extract all leaf word TextSpans
      final wordSpans = <TextSpan>[];
      final richWidget = tester.firstWidget<RichText>(
        find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Bobby')),
      );
      richWidget.text.visitChildren((span) {
        if (span is TextSpan && span.text != null && span.text!.trim().isNotEmpty) {
          wordSpans.add(span);
        }
        return true;
      });

      expect(wordSpans, isNotEmpty);
      // None of the words should have background highlight
      for (final span in wordSpans) {
        expect(span.style?.backgroundColor, isNull);
      }
    });

    testWidgets('StoryTextCard highlights active word when audio is playing', (tester) async {
      const text = 'Một hai ba bốn năm sáu bảy tám chín mười';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StoryTextCard(
              textContent: text,
              showEnglish: false,
              isPlayingAudio: true,
              audioPosition: Duration(milliseconds: 2500),
              audioDuration: Duration(milliseconds: 10000),
            ),
          ),
        ),
      );

      // Verify read-along pill IS visible
      expect(find.textContaining('Dõi theo giọng đọc • Đang phát'), findsOneWidget);

      final wordSpans = <TextSpan>[];
      final richWidget = tester.firstWidget<RichText>(
        find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Một')),
      );
      richWidget.text.visitChildren((span) {
        if (span is TextSpan && span.text != null && span.text!.trim().isNotEmpty) {
          wordSpans.add(span);
        }
        return true;
      });

      expect(wordSpans.length, 10);

      // Exactly one word span should have the active highlight background Color(0xFFFEF08A)
      final highlightedSpans = wordSpans.where((s) => s.style?.backgroundColor == const Color(0xFFFEF08A)).toList();
      expect(highlightedSpans.length, 1);

      final activeSpan = highlightedSpans.first;
      expect(activeSpan.style?.fontWeight, FontWeight.w900);
      expect(activeSpan.style?.color, const Color(0xFF78350F));
    });

    testWidgets('StoryTextCard advances highlight as audio position changes', (tester) async {
      const text = 'Hôm nay trời rất đẹp và nắng rực rỡ';

      // At start (0.1s out of 10s) -> first word 'Hôm' is highlighted
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StoryTextCard(
              textContent: text,
              showEnglish: false,
              isPlayingAudio: true,
              audioPosition: Duration(milliseconds: 100),
              audioDuration: Duration(milliseconds: 10000),
            ),
          ),
        ),
      );

      final startWordSpans = <TextSpan>[];
      var richWidget = tester.firstWidget<RichText>(
        find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Hôm')),
      );
      richWidget.text.visitChildren((span) {
        if (span is TextSpan && span.text != null && span.text!.trim().isNotEmpty) {
          startWordSpans.add(span);
        }
        return true;
      });

      expect(startWordSpans.first.text?.trim(), 'Hôm');
      expect(startWordSpans.first.style?.backgroundColor, const Color(0xFFFEF08A));

      // Re-pump at near end (9.8s out of 10s) -> last word 'rỡ' is highlighted
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StoryTextCard(
              textContent: text,
              showEnglish: false,
              isPlayingAudio: true,
              audioPosition: Duration(milliseconds: 9800),
              audioDuration: Duration(milliseconds: 10000),
            ),
          ),
        ),
      );

      final endWordSpans = <TextSpan>[];
      richWidget = tester.firstWidget<RichText>(
        find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Hôm')),
      );
      richWidget.text.visitChildren((span) {
        if (span is TextSpan && span.text != null && span.text!.trim().isNotEmpty) {
          endWordSpans.add(span);
        }
        return true;
      });

      final lastWordSpan = endWordSpans.last;
      expect(lastWordSpan.text?.trim(), 'rỡ');
      expect(lastWordSpan.style?.backgroundColor, const Color(0xFFFEF08A));

      // First word is now past -> backgroundColor is null
      expect(endWordSpans.first.style?.backgroundColor, isNull);
    });

    testWidgets('StoryTextCard supports English subtitle synchronization', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StoryTextCard(
              textContent: 'Chú thỏ nhảy vui vẻ.',
              englishSubtitle: 'The bunny hops happily.',
              showEnglish: true,
              isPlayingAudio: true,
              audioPosition: Duration(milliseconds: 2000),
              audioDuration: Duration(milliseconds: 4000),
            ),
          ),
        ),
      );

      // Verify English translation container is present
      expect(find.byIcon(Icons.translate_rounded), findsOneWidget);

      final engWordSpans = <TextSpan>[];
      final engRich = tester.firstWidget<RichText>(
        find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('bunny')),
      );
      engRich.text.visitChildren((span) {
        if (span is TextSpan && span.text != null && span.text!.trim().isNotEmpty) {
          engWordSpans.add(span);
        }
        return true;
      });

      final highlightedEng = engWordSpans.where((s) => s.style?.backgroundColor == const Color(0xFFBBF7D0)).toList();
      expect(highlightedEng.length, 1);
    });
  });
}
