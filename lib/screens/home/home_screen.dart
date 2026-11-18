import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../utils/responsive.dart';
import 'components/home_creation_gates.dart';
import 'components/home_greeting_card.dart';
import 'components/home_today_stories.dart';
import 'home_controller.dart';

export 'home_controller.dart';
export 'home_styles.dart';

/// Man hinh Trang Chu (HomeScreen)
/// Da tai cau truc theo mo hinh Component hoa tinh gon:
/// - Controller: [HomeController]
/// - Stylesheet: [HomeStyles]
/// - Components: [HomeGreetingCard], [HomeCreationGates], [HomeTodayStories]
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
        vertical: isTablet ? 16 : 12,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.kMaxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Loi chao cua be
              HomeGreetingCard(state: state),

              const SizedBox(height: 16),

              // 2. Khong Gian Sang Tao (Vat the chinh - to lon, noi bat)
              HomeCreationGates(
                isTablet: isTablet,
                onOpenDrawing: onOpenDrawing,
                onOpenLibrary: onOpenLibrary,
              ),

              const SizedBox(height: 20),

              // 3. Goi Y Truyen Hom Nay (Phu - toi da 2 truyen)
              HomeTodayStories(
                story1: featured.story1,
                story2: featured.story2,
                onStorySelected: (story) => HomeController.openStory(context, state, story),
                onOpenLibrary: onOpenLibrary,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
