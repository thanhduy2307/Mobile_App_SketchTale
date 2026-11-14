import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_table/models/models.dart';
import 'package:sketch_table/services/story_service.dart';
import 'package:sketch_table/utils/app_config.dart';

void main() {
  group('StoryTemplate and StoryRoleTemplate Child Role Tests', () {
    test('AppConfig Swagger Child Role endpoints generation', () {
      const storyId = 'story-uuid-123';
      const themeId = 'theme-uuid-456';
      const roleId = 'role-uuid-789';

      // 1. GET /api/story-template/stories (Actived stories for child role)
      expect(
        AppConfig.storyTemplatesUrl,
        '${AppConfig.baseUrl}/api/story-template/stories',
      );

      // 2. GET /api/story-template/stories/education-theme/{id}
      expect(
        AppConfig.storyTemplatesByThemeUrl(themeId),
        '${AppConfig.baseUrl}/api/story-template/stories/education-theme/$themeId',
      );

      // 3. GET /api/story-template/stories/{id}
      expect(
        AppConfig.storyTemplateDetailUrl(storyId),
        '${AppConfig.baseUrl}/api/story-template/stories/$storyId',
      );

      // 4. GET /api/storypage-template/pages/{storyId}
      expect(
        AppConfig.storyTemplatePagesUrl(storyId),
        '${AppConfig.baseUrl}/api/storypage-template/pages/$storyId',
      );

      // 5. GET /api/story-template/{storyId}/roles
      expect(
        AppConfig.storyRolesUrl(storyId),
        '${AppConfig.baseUrl}/api/story-template/$storyId/roles',
      );

      // 6. GET /api/role/{id}
      expect(
        AppConfig.storyRoleUrl(roleId),
        '${AppConfig.baseUrl}/api/role/$roleId',
      );
    });

    test('StoryRoleTemplate fromJson and toJson serialization for Child Role', () {
      final json = {
        'id': 'role-123',
        'storyTemplateId': 'story-456',
        'storyRoleType': 0, // mainCharacter
        'roleName': 'Hiệp Sĩ Rồng',
        'description': 'Dũng cảm vượt qua thử thách',
        'allowCustomCharacter': true,
        'requiresParentApproval': false,
        'defaultAssetUrl': '/seed/characters/dragon.png',
        'status': 1,
      };

      final role = StoryRoleTemplate.fromJson(json);

      expect(role.id, 'role-123');
      expect(role.storyTemplateId, 'story-456');
      expect(role.storyRoleType, StoryRoleType.mainCharacter);
      expect(role.roleName, 'Hiệp Sĩ Rồng');
      expect(role.roleTitleWithEmoji.contains('🌟'), true);
      expect(role.typeLabel.contains('Nhân Vật Chính'), true);
      expect(role.fullDefaultAssetUrl.contains('/seed/characters/dragon.png'), true);

      final encoded = role.toJson();
      expect(encoded['id'], 'role-123');
      expect(encoded['roleName'], 'Hiệp Sĩ Rồng');
      expect(encoded['storyRoleType'], 0);
    });

    test('StoryService getDefaultRolesForStory provides mainCharacter and companion roles', () {
      final roles = StoryService.getDefaultRolesForStory('story-demo');
      expect(roles.length, 2);

      final hero = roles.firstWhere((r) => r.storyRoleType == StoryRoleType.mainCharacter);
      expect(hero.roleName, 'Nhân Vật Chính');
      expect(hero.allowCustomCharacter, true);

      final companion = roles.firstWhere((r) => r.storyRoleType == StoryRoleType.companion);
      expect(companion.roleName, 'Bạn Đồng Hành');
      expect(companion.allowCustomCharacter, true);
    });

    test('fetchStoriesSortedByAgeGroup returns templates sorted by ageGroup ascending', () async {
      final result = await StoryService.fetchStoriesSortedByAgeGroup();
      expect(result.isSuccess, true);
      expect(result.templates.isNotEmpty, true);
      expect(result.themes.isNotEmpty, true);

      // Verify sorting: ageGroup must be in non-decreasing order (1 <= 2 <= 3)
      for (int i = 0; i < result.templates.length - 1; i++) {
        final current = result.templates[i];
        final next = result.templates[i + 1];
        expect(current.ageGroup <= next.ageGroup, true,
            reason: 'Item $i (${current.title}, ageGroup: ${current.ageGroup}) should be <= Item ${i + 1} (${next.title}, ageGroup: ${next.ageGroup})');
      }

      // Verify education theme mapping: each template has an educationTheme
      for (final template in result.templates) {
        expect(template.educationTheme, isNotNull,
            reason: 'Template ${template.title} should have a mapped educationTheme');
        expect(template.educationTheme!.name.isNotEmpty, true);
      }
    });

    test('Bobby story has 5 pages and toStory maps all 5 pages cleanly', () {
      final bobbyPages = StoryService.getDefaultPagesForStory('21a89526-20b1-471b-bce0-bc23c4fb7418');
      expect(bobbyPages.length, 5);
      expect(bobbyPages[0].pageNumber, 1);
      expect(bobbyPages[4].pageNumber, 5);

      final template = StoryTemplate(
        id: '21a89526-20b1-471b-bce0-bc23c4fb7418',
        educationThemeId: 'theme-nature',
        title: 'Bobby và món quà của khu vườn',
        description: 'Qua năm trang truyện...',
        ageGroup: 0,
        coverImageUrl: 'https://res.cloudinary.com/cover.jpg',
        totalPageNumbers: 5,
        status: 2,
        pages: bobbyPages,
      );

      final story = template.toStory();
      expect(story.totalPages, 5);
      expect(story.pages.length, 5);
      expect(story.pages[0].pageNumber, 1);
      expect(story.pages[4].pageNumber, 5);
      expect(story.pages[4].chapterTitle, 'Trang 5: Bobby và món quà của khu vườn');

      // Test when pages are empty initially, toStory() still produces all 5 pages for Bobby
      const emptyPagesTemplate = StoryTemplate(
        id: '21a89526-20b1-471b-bce0-bc23c4fb7418',
        educationThemeId: 'theme-nature',
        title: 'Bobby và món quà của khu vườn',
        description: 'Qua năm trang truyện...',
        ageGroup: 0,
        coverImageUrl: 'https://res.cloudinary.com/cover.jpg',
        totalPageNumbers: 5,
        status: 2,
        pages: [],
      );
      final generatedStory = emptyPagesTemplate.toStory();
      expect(generatedStory.totalPages, 5);
      expect(generatedStory.pages.length, 5);
      expect(generatedStory.pages[0].pageNumber, 1);
      expect(generatedStory.pages[4].pageNumber, 5);
      expect(generatedStory.pages[0].textContent.contains('Bobby'), true);
    });

    test('toStory generates fallback pages immediately for non-Bobby templates without network delay', () {
      const template = StoryTemplate(
        id: '2a0dc2ef-6212-4ce0-bed2-cb3bd640b5bd',
        educationThemeId: 'theme-friendship',
        title: 'Sharing Picnic',
        description: 'Friends learn that sharing makes the picnic more fun.',
        ageGroup: 1,
        coverImageUrl: '/seed/covers/sharing-picnic.png',
        totalPageNumbers: 3,
        status: 2,
        pages: [],
      );

      final story = template.toStory();
      expect(story.id, template.id);
      expect(story.title, 'Sharing Picnic');
      expect(story.totalPages, 3);
      expect(story.pages.length, 3);
      expect(story.pages[0].pageNumber, 1);
      expect(story.pages[1].pageNumber, 2);
      expect(story.pages[2].pageNumber, 3);
      expect(story.pages[0].textContent.isNotEmpty, true);
    });
  });
}
