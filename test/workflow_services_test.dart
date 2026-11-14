import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_table/models/models.dart';
import 'package:sketch_table/services/character_mapping_service.dart';
import 'package:sketch_table/services/char_type_service.dart';
import 'package:sketch_table/services/content_report_service.dart';
import 'package:sketch_table/services/upload_service.dart';
import 'package:sketch_table/utils/app_config.dart';

void main() {
  group('Workflow & Backend Services Integration Tests', () {
    test('AppConfig provides all new backend endpoints correctly', () {
      expect(AppConfig.uploadAvatarUrl, contains('/api/upload/avatar'));
      expect(AppConfig.uploadBackgroundImageUrl, contains('/api/upload/background-image'));
      expect(AppConfig.userStoryCharacterMappingsUrl, contains('/api/user-story-character-mappings'));
      expect(AppConfig.userStoryCharacterMappingUrl('map-123'), contains('/api/user-story-character-mappings/map-123'));
      expect(AppConfig.userStoryCharacterMappingsByCharUrl('char-123'), contains('/api/user-story-character-mappings/character/char-123'));
      expect(AppConfig.userStoryCharacterMappingsByStoryUrl('story-123'), contains('/api/user-story-character-mappings/generate-story/story-123'));
      expect(AppConfig.charTypesUrl, contains('/api/char-types'));
      expect(AppConfig.contentReportsUrl, contains('/api/content-reports'));
      expect(AppConfig.creditCostsUrl, contains('/api/credit-costs'));
    });

    test('ChildProfile parses remainingTimeLimit and supports limit helpers', () {
      final json = {
        'id': 'child-uuid',
        'nickName': 'Bé Bắp',
        'targetAgeGroup': 'Age8to10',
        'readingLevel': 'Intermediate',
        'dailyTimeLimit': 60,
        'remainingTimeLimit': 40,
        'dailyCharacterLimit': 5,
        'remainingCharacterLimit': 2,
      };

      final profile = ChildProfile.fromJson(json);
      expect(profile.id, 'child-uuid');
      expect(profile.nickName, 'Bé Bắp');
      expect(profile.dailyTimeLimit, 60);
      expect(profile.remainingTimeLimit, 40);
      expect(profile.hasRemainingTime, true);
      expect(profile.dailyCharacterLimit, 5);
      expect(profile.remainingCharacterLimit, 2);
      expect(profile.canCreateCharacter, true);

      // Test exhausted limits
      final exhaustedProfile = profile.copyWith(
        remainingTimeLimit: 0,
        remainingCharacterLimit: 0,
      );
      expect(exhaustedProfile.hasRemainingTime, false);
      expect(exhaustedProfile.canCreateCharacter, false);

      final updateDto = profile.toUpdateDto();
      expect(updateDto['remainingTimeLimit'], 40);
      expect(updateDto['remainingCharacterLimit'], 2);
    });

    test('UserStoryCharacterMapping serialization and deserialization', () {
      final json = {
        'id': 'map-999',
        'generatedStoryId': 'story-111',
        'storyRoleTemplateId': 'role-222',
        'characterId': 'char-333',
        'parentApprovalStatus': 1, // Pending
        'createdAt': '2026-10-27T08:00:00Z',
      };

      final mapping = UserStoryCharacterMapping.fromJson(json);
      expect(mapping.id, 'map-999');
      expect(mapping.generatedStoryId, 'story-111');
      expect(mapping.storyRoleTemplateId, 'role-222');
      expect(mapping.characterId, 'char-333');
      expect(mapping.parentApprovalStatus, ParentApprovalStatus.pending);
      expect(mapping.isPending, true);
      expect(mapping.isApproved, false);

      final outJson = mapping.toJson();
      expect(outJson['parentApprovalStatus'], 1);
    });

    test('CharacterMappingService returns successful offline fallback when server offline', () async {
      final res = await CharacterMappingService.assignCharacterToRole(
        generatedStoryId: 'story-1',
        storyRoleTemplateId: 'role-hero',
        characterId: 'char-1',
      );
      expect(res, isNotNull);
      expect(res!.generatedStoryId, 'story-1');
      expect(res.storyRoleTemplateId, 'role-hero');
    });

    test('CharacterMappingService fetchMappingsByCharacter handles responses cleanly', () async {
      final list = await CharacterMappingService.fetchMappingsByCharacter('char-123');
      expect(list, isA<List<UserStoryCharacterMapping>>());
    });

    test('CharType serialization and emoji helpers', () {
      final json = {
        'id': 'type-hero',
        'name': 'Dũng Sĩ Rừng Xanh',
        'description': 'Bảo vệ muôn loài',
        'status': 2, // Active
      };

      final charType = CharType.fromJson(json);
      expect(charType.name, 'Dũng Sĩ Rừng Xanh');
      expect(charType.status, CommonStatus.active);
      expect(charType.emoji, '⚔️');
    });

    test('ContentReport serialization matching Luồng 8', () {
      final json = {
        'id': 'report-123',
        'targetType': 1, // Story
        'targetId': 'story-abc',
        'reason': 'Hình ảnh làm bé sợ',
        'status': 0, // Pending
      };

      final report = ContentReport.fromJson(json);
      expect(report.id, 'report-123');
      expect(report.targetType, ReportTargetType.story);
      expect(report.reason, 'Hình ảnh làm bé sợ');
      expect(report.status, ContentReportStatus.pending);
    });

    test('CreditCost model handles AI character creation cost', () {
      final json = {
        'id': 'credit-1',
        'featureKey': 'characterGeneration',
        'cost': 50,
        'featureNameVi': 'Tạo nhân vật AI',
        'featureNameEn': 'AI Character Generation',
        'isActive': true,
      };

      final cost = CreditCost.fromJson(json);
      expect(cost.featureKey, 'characterGeneration');
      expect(cost.cost, 50);
      expect(cost.isActive, true);
    });

    test('CharTypeService provides rich default character types offline', () async {
      final types = CharTypeService.defaultCharTypes;
      expect(types, isNotEmpty);
      expect(types.any((t) => t.name.contains('Dũng Sĩ')), true);
      expect(types.any((t) => t.name.contains('Thú Cưng')), true);
      expect(types.any((t) => t.name.contains('Phù Thủy')), true);
    });

    test('UploadService fallback resilience handles offline data', () async {
      // Mock dummy bytes
      final dummyBytes = Uint8List.fromList([0, 1, 2, 3]);
      final result = await UploadService.uploadAvatar(bytes: dummyBytes);
      // Either online success or offline graceful failure without exception
      expect(result, isNotNull);
      expect(result.message, isNotEmpty);
    });

    test('ContentReportService provides safety confirmation', () async {
      final result = await ContentReportService.reportContent(
        targetType: ReportTargetType.story,
        targetId: 'story-test',
        reason: 'Hình ảnh làm bé giật mình sợ hãi',
      );
      expect(result.isSuccess, true);
      expect(result.message, contains('tiếp nhận'));
    });
  });
}
