import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../story_player/story_player_screen.dart';

/// Logic & Controller cho HomeScreen
/// Đảm nhiệm mở truyện (instant load + background fetch) và tính toán truyện đề xuất
class HomeController {
  static bool _isOpeningStory = false;

  static void openStory(BuildContext context, AppState appState, Story story) {
    if (_isOpeningStory) return;
    _isOpeningStory = true;

    final template = appState.storyTemplates.firstWhere(
      (t) => t.id == story.id,
      orElse: () => const StoryTemplate(
        id: '',
        educationThemeId: '',
        title: '',
        description: '',
        ageGroup: 1,
        coverImageUrl: '',
        totalPageNumbers: 0,
        status: 0,
      ),
    );

    // Resolve active story immediately with fallback pages for instant rendering
    final Story activeStory;
    if (template.pages.isNotEmpty) {
      activeStory = template.toStory();
    } else if (story.pages.isNotEmpty) {
      activeStory = story;
    } else if (template.id.isNotEmpty) {
      activeStory = template.toStory();
    } else {
      activeStory = appState.stories.firstWhere(
        (s) => s.id == story.id,
        orElse: () => story,
      );
    }

    appState.setCurrentStory(activeStory);

    // Navigate immediately without blocking on network (<50ms response)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryPlayerScreen(
          appState: appState,
          story: activeStory,
        ),
      ),
    ).then((_) {
      _isOpeningStory = false;
    });

    // Asynchronously fetch latest remote template pages in background if needed
    if (template.id.isNotEmpty &&
        (template.pages.isEmpty ||
            template.pages.length < template.totalPageNumbers)) {
      appState.loadStoryTemplatePages(template);
    }
  }

  static ({Story story1, Story story2}) getFeaturedStories(AppState state) {
    final recStories = state.recommendedStories;
    final s1 = recStories.isNotEmpty ? recStories.first : state.currentStory;
    final s2 = recStories.length > 1
        ? recStories[1]
        : (state.stories.length > 1 ? state.stories[1] : state.currentStory);
    return (story1: s1, story2: s2);
  }
}

