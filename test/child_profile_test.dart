import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sketch_table/models/child_profile.dart';
import 'package:sketch_table/state/app_state.dart';
import 'package:sketch_table/utils/app_config.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('ChildProfile Swagger Tests', () {
    test('ChildProfile fromJson and toUpdateDto serialization', () {
      final json = {
        'id': 'child-uuid-1234',
        'nickName': 'Bé Bống',
        'targetAgeGroup': '1',
        'readingLevel': 'Cơ bản',
        'dailyTimeLimit': 45,
        'dailyCharacterLimit': 5,
        'remainingCharacterLimit': 3,
        'avatarEmoji': '👶',
        'stars': 150,
        'streakDays': 4,
      };

      final profile = ChildProfile.fromJson(json);

      expect(profile.id, 'child-uuid-1234');
      expect(profile.nickName, 'Bé Bống');
      expect(profile.targetAgeGroup, '1');
      expect(profile.readingLevel, 'Cơ bản');
      expect(profile.dailyTimeLimit, 45);
      expect(profile.dailyCharacterLimit, 5);
      expect(profile.remainingCharacterLimit, 3);
      expect(profile.avatarEmoji, '👶');
      expect(profile.stars, 150);
      expect(profile.streakDays, 4);

      // Verify toUpdateDto matches UpdateChildProfileDto schema
      final updateDto = profile.toUpdateDto();
      expect(updateDto['nickName'], 'Bé Bống');
      expect(updateDto['targetAgeGroup'], '1');
      expect(updateDto['readingLevel'], 'Cơ bản');
      expect(updateDto['dailyTimeLimit'], 45);
      expect(updateDto['dailyCharacterLimit'], 5);
      expect(updateDto['remainingCharacterLimit'], 3);
    });

    test('AppConfig Swagger ChildProfile URLs generation for all 7 endpoints', () {
      const childId = 'child-profile-uuid';

      // 1. GET /api/child-profiles
      expect(
        AppConfig.childProfilesUrl,
        '${AppConfig.baseUrl}/api/child-profiles',
      );

      // 2 & 3. GET & PUT /api/child-profiles/{id}
      expect(
        AppConfig.childProfileUrl(childId),
        '${AppConfig.baseUrl}/api/child-profiles/$childId',
      );

      // 4. GET /api/child-profiles/{id}/nickname
      expect(
        AppConfig.childProfileNicknameUrl(childId),
        '${AppConfig.baseUrl}/api/child-profiles/$childId/nickname',
      );

      // 5. GET /api/child-profiles/{id}/target-age-group
      expect(
        AppConfig.childProfileTargetAgeGroupUrl(childId),
        '${AppConfig.baseUrl}/api/child-profiles/$childId/target-age-group',
      );

      // 6. GET /api/child-profiles/{id}/daily-time-limit
      expect(
        AppConfig.childProfileDailyTimeLimitUrl(childId),
        '${AppConfig.baseUrl}/api/child-profiles/$childId/daily-time-limit',
      );

      // 7. GET /api/child-profiles/{id}/daily-character-limit
      expect(
        AppConfig.childProfileDailyCharacterLimitUrl(childId),
        '${AppConfig.baseUrl}/api/child-profiles/$childId/daily-character-limit',
      );
    });

    test('ChildProfile targetAgeGroupDisplayName returns kid-friendly description', () {
      const profile0 = ChildProfile(id: '1', nickName: 'Bé', targetAgeGroup: '0');
      const profile1 = ChildProfile(id: '2', nickName: 'Bé', targetAgeGroup: '1');
      const profile2 = ChildProfile(id: '3', nickName: 'Bé', targetAgeGroup: '2');

      expect(profile0.targetAgeGroupDisplayName.contains('3 - 5'), true);
      expect(profile1.targetAgeGroupDisplayName.contains('6 - 8'), true);
      expect(profile2.targetAgeGroupDisplayName.contains('9 - 12'), true);
    });

    test('AppState recommends stories matching active child age group first', () {
      final state = AppState();

      // Khi bé thuộc nhóm tuổi 9-12 (targetAgeGroup: '2' -> ageGroup 3)
      const olderChild = ChildProfile(id: 'c3', nickName: 'Anh Lớn', targetAgeGroup: '2');
      state.selectChildProfile(olderChild);

      expect(state.currentChildAgeGroup, 3);
      expect(state.childAgeGroupLabel, '9 - 12 tuổi');
      final recTemplatesAge3 = state.recommendedStoryTemplates;
      expect(recTemplatesAge3.isNotEmpty, true);
      expect(recTemplatesAge3.first.ageGroup, 3);

      // Khi đổi sang em bé mầm non 3-5 tuổi (targetAgeGroup: '0' -> ageGroup 1)
      const toddlerChild = ChildProfile(id: 'c1', nickName: 'Bé Út', targetAgeGroup: '0');
      state.selectChildProfile(toddlerChild);

      expect(state.currentChildAgeGroup, 1);
      expect(state.childAgeGroupLabel, '3 - 5 tuổi');
      final recTemplatesAge1 = state.recommendedStoryTemplates;
      expect(recTemplatesAge1.isNotEmpty, true);
      expect(recTemplatesAge1.first.ageGroup, 1);
    });
  });
}
