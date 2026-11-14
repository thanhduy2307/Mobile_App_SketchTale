import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sketch_table/models/models.dart';
import 'package:sketch_table/screens/story_player/story_player_screen.dart';
import 'package:sketch_table/services/quiz_service.dart';
import 'package:sketch_table/state/app_state.dart';
import 'package:sketch_table/utils/app_config.dart';
import 'package:sketch_table/widgets/app_loading.dart';

const _logId = '11111111-1111-4111-8111-111111111111';
const _quizId = '22222222-2222-4222-8222-222222222222';
const _childId = '33333333-3333-4333-8333-333333333333';

void main() {
  tearDown(() => QuizService.httpClient = http.Client());

  group('Reading log quiz models & URLs', () {
    test('AppConfig generates reading-log endpoints', () {
      expect(AppConfig.readingLogsUrl, '${AppConfig.baseUrl}/api/reading-logs');
      expect(AppConfig.childQuizAnswersUrl,
          '${AppConfig.baseUrl}/api/child-quiz-answers');
      expect(AppConfig.readingLogSubmitAnswerUrl,
          '${AppConfig.baseUrl}/api/child-quiz-answers');
      expect(AppConfig.readingLogQuizAnswersUrl(_logId),
          '${AppConfig.baseUrl}/api/child-quiz-answers/reading-logs/$_logId');
      expect(AppConfig.childQuizHistoryUrl(_childId),
          '${AppConfig.baseUrl}/api/child-quiz-answers/child-profiles/$_childId');
      expect(AppConfig.childCompletedStoriesUrl(_childId),
          '${AppConfig.baseUrl}/api/reading-logs/child-profiles/$_childId/completed');
    });

    test('SubmitQuizAnswerResult parses BE response', () {
      final r = SubmitQuizAnswerResult.fromJson({
        'isCorrect': true,
        'correctOptionIndex': 2,
        'selectedOptionIndex': 2,
        'quizScore': 10,
        'currentAnsweredCount': 4,
        'totalQuestions': 4,
        'completionPercentage': 100.0,
        'isQuizCompleted': true,
        'stars': 3,
        'message': 'Xuất sắc!',
      });
      expect(r.isCorrect, isTrue);
      expect(r.stars, 3);
      expect(r.isQuizCompleted, isTrue);
      expect(r.completionPercentage, 100.0);
    });

    test('ReadingLogQuizSummary parses answers list', () {
      final s = ReadingLogQuizSummary.fromJson({
        'readingLogId': _logId,
        'totalQuestions': 2,
        'totalAnswered': 2,
        'totalCorrectAnswers': 1,
        'accuracyPercentage': 50,
        'isQuizCompleted': true,
        'stars': 2,
        'answers': [
          {'questionText': 'Q1', 'options': ['a', 'b'], 'isCorrect': true},
          {'questionText': 'Q2', 'options': ['c'], 'isCorrect': false},
        ],
      });
      expect(s.stars, 2);
      expect(s.accuracyPercentage, 50.0);
      expect(s.answers.length, 2);
      expect(s.answers.first.options, ['a', 'b']);
    });
  });

  group('QuizService reading-log API', () {
    test('submitAnswer posts expected body and parses result', () async {
      late http.Request captured;
      QuizService.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({'isCorrect': true, 'stars': 0, 'currentAnsweredCount': 1, 'totalQuestions': 3}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final result = await QuizService.submitAnswer(
        readingLogId: _logId,
        storyQuizTemplateId: _quizId,
        selectedOptionIndex: 1,
        responseTimeSeconds: 7,
        childProfileId: _childId,
        token: 'tok',
      );

      expect(result, isNotNull);
      expect(result!.isCorrect, isTrue);
      expect(captured.method, 'POST');
      expect(captured.url.toString(), AppConfig.readingLogSubmitAnswerUrl);
      expect(captured.headers['Authorization'], 'Bearer tok');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['readingLogId'], _logId);
      expect(body['storyQuizTemplateId'], _quizId);
      expect(body['selectedOptionIndex'], 1);
      expect(body['responseTimeSeconds'], 7);
      expect(body['childProfileId'], _childId);
    });

    test('submitAnswer returns null on 403/404 or non-uuid ids so UI falls back locally', () async {
      QuizService.httpClient = MockClient((_) async => http.Response('{"message":"no"}', 404));
      expect(
        await QuizService.submitAnswer(
          readingLogId: _logId,
          storyQuizTemplateId: _quizId,
          selectedOptionIndex: 0,
        ),
        isNull,
      );

      var called = false;
      QuizService.httpClient = MockClient((_) async {
        called = true;
        return http.Response('{}', 200);
      });
      expect(
        await QuizService.submitAnswer(
          readingLogId: 'local-log',
          storyQuizTemplateId: 'quiz-default-1',
          selectedOptionIndex: 0,
        ),
        isNull,
      );
      expect(called, isFalse);
    });

    test('fetchReadingLogSummary and fetchChildQuizHistory parse responses', () async {
      QuizService.httpClient = MockClient((request) async {
        if (request.url.path.contains('child-profiles')) {
          return http.Response(
            jsonEncode([
              {'readingLogId': _logId, 'stars': 3, 'isQuizCompleted': true},
            ]),
            200,
          );
        }
        return http.Response(jsonEncode({'readingLogId': _logId, 'stars': 1}), 200);
      });

      final summary = await QuizService.fetchReadingLogSummary(_logId);
      expect(summary?.stars, 1);

      final history = await QuizService.fetchChildQuizHistory(_childId);
      expect(history.length, 1);
      expect(history.first.stars, 3);
    });
  });

  group('Universal App Logo Loading & StoryPlayer Quiz Tab UI', () {
    testWidgets('AppLoadingLogo, AppLoadingOverlay, and appImageLoadingBuilder display SketchTale logo while loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppLoadingOverlay(
              isLoading: true,
              label: 'Đang mở trang truyện...',
              child: Builder(
                builder: (context) => appImageLoadingBuilder(
                  context,
                  const Text('Ảnh đã tải xong'),
                  const ImageChunkEvent(
                    cumulativeBytesLoaded: 25,
                    expectedTotalBytes: 100,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(AppLoadingLogo), findsNWidgets(2));
      expect(find.text('Đang mở trang truyện...'), findsOneWidget);

      final imageFinder = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == kAppLoadingLogoAsset,
      );
      expect(imageFinder, findsNWidgets(2));

      // When loading finishes (loadingProgress == null and isLoading == false), child is shown directly
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppLoadingOverlay(
              isLoading: false,
              child: Builder(
                builder: (context) => appImageLoadingBuilder(
                  context,
                  const Text('Ảnh đã tải xong'),
                  null,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AppLoadingLogo), findsNothing);
      expect(find.text('Ảnh đã tải xong'), findsOneWidget);
    });

    testWidgets('StoryPlayerScreen exposes Đố Vui tab and submits answer to ReadingLog API', (tester) async {
      tester.view.physicalSize = const Size(1024, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const storyUuid = '44444444-4444-4444-8444-444444444444';
      bool postCalled = false;

      QuizService.httpClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path.endsWith('/quizzes')) {
          return http.Response(
            jsonEncode([
              {
                'id': _quizId,
                'storyTemplateId': storyUuid,
                'questionText': 'Rồng Con đã thắp sáng rừng bằng gì?',
                'options': ['Đèn lồng ánh sáng', 'Cục đá'],
                'correctOptionIndex': 0,
              },
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (request.method == 'POST' &&
            request.url.path == '/api/reading-logs/child-quiz-answers') {
          postCalled = true;
          return http.Response(
            jsonEncode({
              'isCorrect': true,
              'correctOptionIndex': 0,
              'selectedOptionIndex': 0,
              'quizScore': 10,
              'currentAnsweredCount': 1,
              'totalQuestions': 1,
              'completionPercentage': 100.0,
              'isQuizCompleted': true,
              'stars': 3,
              'message': 'Hoan hô bé trả lời xuất sắc!',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('[]', 200);
      });

      final appState = AppState();
      final initialStars = appState.stars;
      final testStory = appState.stories.first;
      final uuidStory = Story(
        id: storyUuid,
        title: testStory.title,
        subtitle: testStory.subtitle,
        coverUrl: 'assets/images/sketchtale-widget.png',
        ageRange: testStory.ageRange,
        category: testStory.category,
        totalPages: 1,
        currentPage: 1,
        isCompleted: false,
        pages: const [
          StoryPage(
            pageNumber: 1,
            imageUrl: 'assets/images/sketchtale-widget.png',
            textContent: 'Trang 1 kỳ diệu',
          ),
        ],
        quiz: testStory.quiz,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StoryPlayerScreen(
            appState: appState,
            story: uuidStory,
            readingLogId: _logId,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Switch to Đố Vui tab
      expect(find.text('Đố Vui'), findsOneWidget);
      await tester.tap(find.text('Đố Vui'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Rồng Con đã thắp sáng rừng bằng gì?'), findsOneWidget);

      // Submit answer A (index 0)
      await tester.tap(find.text('KIỂM TRA CÂU TRẢ LỜI 🔍'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(postCalled, isTrue);
      expect(find.text('Hoan hô bé trả lời xuất sắc!'), findsOneWidget);
      expect(appState.stars, initialStars + 3);
    });
  });
}

