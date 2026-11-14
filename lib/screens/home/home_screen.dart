import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../utils/responsive.dart';
import 'components/home_creation_gates.dart';
import 'components/home_daily_tip_card.dart';
import 'components/home_greeting_card.dart';
import 'components/home_hero_story_card.dart';
import 'components/home_today_stories.dart';
import 'home_controller.dart';

export 'home_controller.dart';
export 'home_styles.dart';

/// 🏠 Màn hình Trang Chủ (HomeScreen)
/// Đã tái cấu trúc theo mô hình Component hóa siêu tinh gọn:
/// - Controller: [HomeController]
/// - Stylesheet: [HomeStyles]
/// - Components: [HomeGreetingCard], [HomeHeroStoryCard], [HomeCreationGates], [HomeTodayStories], [HomeDailyTipCard]
class HomeScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onOpenDrawing;
  final VoidCallback onOpenLibrary;

  const HomeScreen({
    super.key,
    required this.appState,
    required this.onOpenDrawing,
    required this.onOpenLibrary,
  });

  @override
  Widget build(BuildContext context) {
    final state = appState;
    final isTablet = Responsive.isTabletOrDesktop(context);
    final featured = HomeController.getFeaturedStories(state);

    // Ưu tiên chọn truyện chưa hoàn thành; nếu tất cả đã đọc xong thì hiển thị truyện hiện tại
    final heroStory = state.stories.firstWhere(
      (s) => !s.isCompleted && !state.completedStoryIds.contains(s.id),
      orElse: () => state.currentStory,
    );
    final isHeroCompleted = heroStory.isCompleted || state.completedStoryIds.contains(heroStory.id);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
        vertical: 14,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.kMaxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Lời chào & Huy hiệu của bé
              HomeGreetingCard(state: state),

              const SizedBox(height: 16),

              // 2. Thẻ Đọc Tiếp Nè / Đã Hoàn Thành (1-Tap Hero Card)
              HomeHeroStoryCard(
                story: heroStory,
                isCompleted: isHeroCompleted,
                onTap: () => HomeController.openStory(context, state, heroStory),
              ),

              const SizedBox(height: 18),

              // 3. Không Gian Sáng Tạo & Thư Viện
              HomeCreationGates(
                isTablet: isTablet,
                onOpenDrawing: onOpenDrawing,
                onOpenLibrary: onOpenLibrary,
              ),

              const SizedBox(height: 22),

              // 4. Khu Vực Truyện Đọc Hôm Nay
              HomeTodayStories(
                story1: featured.story1,
                story2: featured.story2,
                onStorySelected: (story) => HomeController.openStory(context, state, story),
                onOpenLibrary: onOpenLibrary,
              ),

              const SizedBox(height: 20),

              // 5. Mẹo Gia Đình: 10 Phút Bên Nhau
              const HomeDailyTipCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
