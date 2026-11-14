import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_table/models/models.dart';
import 'package:sketch_table/services/vocabulary_service.dart';
import 'package:sketch_table/utils/app_config.dart';

void main() {
  group('VocabularyTemplate Swagger Tests', () {
    test('VocabularyTemplate fromJson and toJson serialization (Read-only for Child)', () {
      final json = {
        'id': 'vocab-uuid-1',
        'storyPageTemplateId': 'page-uuid-10',
        'word': 'Đom Đóm',
        'meaning': 'Loài bọ cánh cứng nhỏ bé có thể tự phát sáng lấp lánh.',
        'audioUrl': '/seed/audio/dom_dom.mp3',
        'createdAt': '2026-10-15T12:00:00Z',
        'createBy': 'user-1',
      };

      final vocab = VocabularyTemplate.fromJson(json);

      expect(vocab.id, 'vocab-uuid-1');
      expect(vocab.storyPageTemplateId, 'page-uuid-10');
      expect(vocab.word, 'Đom Đóm');
      expect(vocab.meaning.contains('tự phát sáng'), true);
      expect(vocab.audioUrl, '/seed/audio/dom_dom.mp3');
      expect(vocab.fullAudioUrl.contains('/seed/audio/dom_dom.mp3'), true);

      final encoded = vocab.toJson();
      expect(encoded['id'], 'vocab-uuid-1');
      expect(encoded['word'], 'Đom Đóm');
    });

    test('AppConfig Swagger Vocabulary URLs generation for child view endpoints', () {
      const pageId = 'test-page-123';
      const vocabId = 'test-vocab-456';

      // 1. GET /api/story-pages/{pageId}/vocabularies
      expect(
        AppConfig.storyPageVocabulariesUrl(pageId),
        '${AppConfig.baseUrl}/api/story-pages/$pageId/vocabularies',
      );

      // 2. GET /api/story-vocabulary/{id}
      expect(
        AppConfig.storyVocabularyUrl(vocabId),
        '${AppConfig.baseUrl}/api/story-vocabulary/$vocabId',
      );
    });

    test('VocabularyService provides rich contextual vocabularies for story pages', () {
      final fireflyPage1 = VocabularyService.getDefaultVocabulariesForPage(1, 'Bí Mật Rừng Đom Đóm');
      expect(fireflyPage1.isNotEmpty, true);
      expect(fireflyPage1.any((v) => v.word == 'Đom Đóm'), true);

      final fireflyPage3 = VocabularyService.getDefaultVocabulariesForPage(3, 'Bí Mật Rừng Đom Đóm');
      expect(fireflyPage3.any((v) => v.word.contains('Chìa Khóa')), true);

      final picnicPage = VocabularyService.getDefaultVocabulariesForPage(1, 'Sharing Picnic');
      expect(picnicPage.any((v) => v.word.contains('Chia sẻ')), true);
    });
  });
}
