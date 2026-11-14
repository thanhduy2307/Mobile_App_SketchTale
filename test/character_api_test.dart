import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_table/models/models.dart';
import 'package:sketch_table/utils/app_config.dart';

void main() {
  group('Character API endpoints and models', () {
    test('AppConfig generates character endpoints correctly', () {
      const childId = '33333333-3333-4333-8333-333333333333';
      const charId = '44444444-4444-4444-8444-444444444444';

      expect(
        AppConfig.childCharactersUrl(childId),
        '${AppConfig.baseUrl}/api/characters/child-profiles/$childId',
      );
      expect(
        AppConfig.updateCharacterNameUrl(charId),
        '${AppConfig.baseUrl}/api/characters/$charId/name',
      );
      expect(
        AppConfig.charactersPendingApprovalUrl,
        '${AppConfig.baseUrl}/api/characters/pending-approval',
      );
      expect(
        AppConfig.characterApproveUrl(charId),
        '${AppConfig.baseUrl}/api/characters/$charId/approve',
      );
      expect(
        AppConfig.characterRejectUrl(charId),
        '${AppConfig.baseUrl}/api/characters/$charId/reject',
      );
    });

    test('KidCharacter.fromJson parses backend CharacterApprovalDto correctly', () {
      final backendJson = {
        'characterId': '44444444-4444-4444-8444-444444444444',
        'childProfileId': '33333333-3333-4333-8333-333333333333',
        'childNickName': 'Bé Bống',
        'characterName': 'Khủng Long Cam',
        'defaultPronoun': 'Hiệp Sĩ',
        'finalImageUrl': 'https://res.cloudinary.com/demo/image/upload/sample.png',
        'originalDrawingUrl': 'https://res.cloudinary.com/demo/image/upload/drawing.png',
        'aiPromptUsed': 'Một chú khủng long màu cam thân thiện',
        'status': 2, // Approved
        'isFavorite': true,
        'createdAt': '2026-11-14T10:00:00.000Z',
      };

      final char = KidCharacter.fromJson(backendJson);

      expect(char.id, '44444444-4444-4444-8444-444444444444');
      expect(char.name, 'Khủng Long Cam');
      expect(char.title, 'Hiệp Sĩ');
      expect(char.avatar3dUrl, 'https://res.cloudinary.com/demo/image/upload/sample.png');
      expect(char.drawingUrl, 'https://res.cloudinary.com/demo/image/upload/drawing.png');
      expect(char.description, 'Một chú khủng long màu cam thân thiện');
      expect(char.isParentApproved, isTrue);
    });

    test('KidCharacter.fromJson handles pending status', () {
      final backendJson = {
        'characterId': '55555555-5555-4555-8555-555555555555',
        'characterName': 'Sư Tử Lửa',
        'finalImageUrl': 'https://example.com/fire_lion.png',
        'status': 1, // Pending
      };

      final char = KidCharacter.fromJson(backendJson);

      expect(char.id, '55555555-5555-4555-8555-555555555555');
      expect(char.name, 'Sư Tử Lửa');
      expect(char.isParentApproved, isFalse);
    });
  });
}
