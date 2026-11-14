import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../role_assignment/role_assignment_screen.dart';
import '../story_player/story_player_screen.dart';

/// 🧠 Controller Quản Lý Logic Thư Viện Truyện (LibraryController)
/// Tương đương React Hook `useLibraryScreen`:
/// Quản lý lọc truyện theo chủ đề & độ tuổi, điều hướng mở truyện và gán vai.
class LibraryController extends ChangeNotifier {
  bool isOpeningStory = false;

  static const String recommendedCategory = 'Đề Xuất Cho Bé';

  List<String> getThemeCategories(AppState state) {
    final categories = <String>['Tất Cả', recommendedCategory];
    for (final theme in state.educationThemes) {
      final name = theme.displayName;
      if (!categories.contains(name)) {
        categories.add(name);
      }
    }
    return categories;
  }

  List<StoryTemplate> getFilteredTemplates(AppState state) {
    List<StoryTemplate> templates = List.from(state.storyTemplates);

    if (state.selectedCategory == recommendedCategory) {
      // 1. Lọc theo độ tuổi phù hợp của bé (ẩn nhãn độ tuổi trên UI)
      templates = templates
          .where((t) => t.ageGroup == state.currentChildAgeGroup)
          .toList();
    } else if (state.selectedCategory != 'Tất Cả') {
      // 2. Lọc theo chủ đề giáo dục
      templates = templates.where((t) {
        final themeName = t.educationTheme?.name ?? '';
        final displayName = t.educationTheme?.displayName ?? '';
        return state.selectedCategory.contains(themeName) ||
            state.selectedCategory == displayName;
      }).toList();
    }

    // 3. Ưu tiên độ tuổi đúng lên đầu
    final targetAge = state.currentChildAgeGroup;
    templates.sort((a, b) {
      final aMatch = (a.ageGroup == targetAge) ? 0 : 1;
      final bMatch = (b.ageGroup == targetAge) ? 0 : 1;
      if (aMatch != bMatch) return aMatch.compareTo(bMatch);
      final aDist = (a.ageGroup - targetAge).abs();
      final bDist = (b.ageGroup - targetAge).abs();
      if (aDist != bDist) return aDist.compareTo(bDist);
      return a.title.compareTo(b.title);
    });

    return templates;
  }

  void openStoryFromTemplate(
    BuildContext context,
    AppState appState,
    StoryTemplate template,
  ) {
    if (isOpeningStory) return;
    isOpeningStory = true;
    notifyListeners();

    final matched = appState.storyTemplates.firstWhere(
      (t) => t.id == template.id,
      orElse: () => template,
    );
    final resolvedTemplate = matched.pages.isNotEmpty ? matched : template;
    final story = resolvedTemplate.toStory();
    appState.setCurrentStory(story);

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) =>
                StoryPlayerScreen(appState: appState, story: story),
          ),
        )
        .then((_) {
          isOpeningStory = false;
          notifyListeners();
        });

    if (template.id.isNotEmpty &&
        (template.pages.isEmpty ||
            template.pages.length < template.totalPageNumbers)) {
      appState.loadStoryTemplatePages(template);
    }
  }

  void openRoleAssignmentForTemplate(
    BuildContext context,
    AppState appState,
    StoryTemplate template,
  ) {
    final matched = appState.storyTemplates.firstWhere(
      (t) => t.id == template.id,
      orElse: () => template,
    );
    final resolvedTemplate = matched.pages.isNotEmpty ? matched : template;
    final story = resolvedTemplate.toStory();
    appState.setCurrentStory(story);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoleAssignmentScreen(appState: appState),
      ),
    );

    if (template.id.isNotEmpty &&
        (template.pages.isEmpty ||
            template.pages.length < template.totalPageNumbers)) {
      appState.loadStoryTemplatePages(template);
    }
  }
}

