import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_loading.dart';
import 'components/library_header_card.dart';
import 'components/library_theme_filter.dart';
import 'components/story_card.dart';
import 'dialogs/story_options_sheet.dart';
import 'library_controller.dart';
import 'library_styles.dart';

export 'library_controller.dart';
export 'library_styles.dart';

/// 📚 Màn hình Thư Viện Câu Chuyện (Clean View Component)
/// Cấu trúc theo mô hình React JSX + CSS:
/// - Controller [LibraryController] quản lý State & Điều hướng
/// - Stylesheet [LibraryStyles] quản lý định dạng Box/Text
/// - Giao diện tinh giản, hiển thị Banner, Bộ lọc chủ đề và Lưới StoryCard
class LibraryScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onOpenDrawing;

  const LibraryScreen({
    super.key,
    required this.appState,
    required this.onOpenDrawing,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final LibraryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LibraryController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final isTablet = Responsive.isTabletOrDesktop(context);
    final themeCategories = _controller.getThemeCategories(state);
    final templates = _controller.getFilteredTemplates(state);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: () => state.fetchStoryTemplates(),
          color: AppColors.primaryContainer,
          backgroundColor: AppColors.surfaceContainerLowest,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.horizontalPadding(context),
              vertical: 12,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Responsive.kMaxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header Card (Title, Count & Refresh)
                    LibraryHeaderCard(
                      avatarAsset: state.childAvatarAsset,
                      totalStories: state.storyTemplates.length,
                      onRefresh: () => state.fetchStoryTemplates(),
                    ),

                    const SizedBox(height: 16),

                    // 2. Theme Category Filters
                    LibraryThemeFilter(
                      categories: themeCategories,
                      selectedCategory: state.selectedCategory,
                      onSelectCategory: (cat) => state.setSelectedCategory(cat),
                    ),

                    const SizedBox(height: 20),

                    // 3. Kid-Friendly Library Section Banner (Kho Truyện Kỳ Diệu)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFCD34D),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C001050),
                            offset: Offset(0, 3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x14D97706),
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.auto_stories_rounded,
                                color: Color(0xFFD97706),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kho Truyện Kỳ Diệu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Mỗi câu chuyện là một thế giới mới đang chờ bé khám phá!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFB45309).withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFFCD34D),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              '${templates.length} truyện',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 4. Grid of Story Templates
                    if (state.isLoadingStories && templates.isEmpty)
                      Container(
                        height: 220,
                        alignment: Alignment.center,
                        child: const AppLoadingLogo(
                          size: 72,
                          label: 'Đang mở cánh cửa kho truyện kỳ diệu...',
                        ),
                      )
                    else if (templates.isEmpty)
                      AppEmptyState(
                        icon: Icons.auto_stories_rounded,
                        title: 'Không có truyện nào phù hợp với bộ lọc',
                        message: 'Bé thử chọn chủ đề khác nhé!',
                        actionLabel: 'Xem tất cả truyện',
                        onAction: () => state.setSelectedCategory('Tất Cả'),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 3 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 14,
                          childAspectRatio: isTablet ? 0.74 : 0.62,
                        ),
                        itemCount: templates.length,
                        itemBuilder: (context, index) {
                          final template = templates[index];
                          return StoryCard(
                            template: template,
                            targetAgeGroup: state.currentChildAgeGroup,
                            onTap: () => StoryOptionsSheet.show(
                              context,
                              template: template,
                              heroCharacter: state.heroCharacter ??
                                  (state.characters.isNotEmpty
                                      ? state.characters.first
                                      : null),
                              hasCharacters: state.characters.isNotEmpty,
                              onReadStory: () =>
                                  _controller.openStoryFromTemplate(
                                    context,
                                    state,
                                    template,
                                    isOriginalTemplate: true,
                                  ),
                              onAssignRoles: () =>
                                  _controller.openRoleAssignmentForTemplate(
                                    context,
                                    state,
                                    template,
                                  ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
