import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_table/models/models.dart';
import 'package:sketch_table/services/quiz_service.dart';
import 'package:sketch_table/utils/app_config.dart';

void main() {
  group('StoryQuizTemplate Swagger & Quiz Tests', () {
    test('StoryQuizTemplate fromJson and toJson serialization (Child View & Play Only)', () {
      final json = {
        'id': 'quiz-uuid-1',
        'storyTemplateId': 'story-uuid-10',
        'questionText': 'Bạn nhỏ đã học được đức tính gì sau chuyến đi?',
        'questionPicUrl': '/seed/quizzes/clue1.png',
        'questionAudioUrl': '/seed/audio/quiz1.mp3',
        'options': [
          'Dũng cảm vượt qua nỗi sợ',
          'Biết chia sẻ cùng bạn bè',
          'Lắng nghe lời cha mẹ',
          'Cả 3 điều trên đều đúng!',
        ],
        'correctOptionIndex': 3,
        'status': 1,
        'createdAt': '2026-10-15T12:00:00Z',
        'createBy': 'parent-user-1',
      };

      final quizTemplate = StoryQuizTemplate.fromJson(json);

      expect(quizTemplate.id, 'quiz-uuid-1');
      expect(quizTemplate.storyTemplateId, 'story-uuid-10');
      expect(quizTemplate.questionText.contains('đức tính gì'), true);
      expect(quizTemplate.options.length, 4);
      expect(quizTemplate.correctOptionIndex, 3);
      expect(quizTemplate.fullPicUrl.contains('/seed/quizzes/clue1.png'), true);
      expect(quizTemplate.fullAudioUrl.contains('/seed/audio/quiz1.mp3'), true);

      final encoded = quizTemplate.toJson();
      expect(encoded['id'], 'quiz-uuid-1');
      expect(encoded['correctOptionIndex'], 3);
      expect(encoded['options'], isA<List<String>>());
    });

    test('StoryQuizTemplate parses optionsJson fallback when options array is null', () {
      final json = {
        'id': 'quiz-uuid-2',
        'storyTemplateId': 'story-uuid-10',
        'questionText': 'Ai là người giúp bạn Rồng thắp sáng?',
        'optionsJson': '["Chiếc Đèn Lồng", "Bé Đom Đóm", "Ngôi Sao"]',
        'correctOptionIndex': 1,
      };

      final quizTemplate = StoryQuizTemplate.fromJson(json);

      expect(quizTemplate.options.length, 3);
      expect(quizTemplate.options[1], 'Bé Đom Đóm');
      expect(quizTemplate.correctOptionIndex, 1);
    });

    test('StoryQuizTemplate converts to interactive QuizQuestion correctly', () {
      const template = StoryQuizTemplate(
        id: 'quiz-uuid-3',
        storyTemplateId: 'story-uuid-10',
        questionText: 'Món quà ý nghĩa nhất là gì?',
        options: ['Vàng bạc', 'Tình bạn', 'Đồ chơi'],
        correctOptionIndex: 1,
      );

      final quizQuestion = template.toQuizQuestion(rewardStars: 15);

      expect(quizQuestion.questionText, 'Món quà ý nghĩa nhất là gì?');
      expect(quizQuestion.correctIndex, 1);
      expect(quizQuestion.rewardStars, 15);
      expect(quizQuestion.optionDetails.length, 3);
      expect(quizQuestion.optionDetails[1].title.contains('Tình bạn'), true);
      expect(quizQuestion.optionDetails[1].letter, 'B');
    });

    test('AppConfig Swagger Quiz URLs generation', () {
      const storyId = 'story-template-abc';
      const quizId = 'quiz-xyz';

      // 1. GET /api/story-template/{storyId}/quizzes
      expect(
        AppConfig.storyQuizzesUrl(storyId),
        '${AppConfig.baseUrl}/api/story-template/$storyId/quizzes',
      );

      // 2. GET /api/story-quizz/{id} / GET /api/story-quiz/{id}
      expect(
        AppConfig.storyQuizUrl(quizId),
        '${AppConfig.baseUrl}/api/story-quizz/$quizId',
      );
      expect(
        AppConfig.storyQuizAltUrl(quizId),
        '${AppConfig.baseUrl}/api/story-quiz/$quizId',
      );
    });

    test('QuizService provides rich contextual quizzes for story titles', () {
      final fireflyQuizzes = QuizService.getDefaultQuizzesForStory('story-1', 'Bí Mật Rừng Đom Đóm');
      expect(fireflyQuizzes.length, greaterThanOrEqualTo(2));
      expect(fireflyQuizzes.first.questionText.contains('đêm tối'), true);

      final picnicQuizzes = QuizService.getDefaultQuizzesForStory('story-2', 'Picnic Chia Sẻ');
      expect(picnicQuizzes.any((q) => q.questionText.contains('dã ngoại')), true);

      final defaultQuizzes = QuizService.getDefaultQuizzesForStory('story-3', 'Chuyện Khác');
      expect(defaultQuizzes.isNotEmpty, true);
    });
  });
}
