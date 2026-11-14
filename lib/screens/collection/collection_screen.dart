import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_loading.dart';
import '../role_assignment/role_assignment_screen.dart';
import '../story_player/story_player_screen.dart';
import 'collection_controller.dart';
import 'collection_styles.dart';
import 'components/character_card.dart';
import 'components/collection_achievements_view.dart';
import 'components/collection_hero_header.dart';
import 'components/collection_segment_bar.dart';
import 'components/completed_story_card.dart';

export 'collection_controller.dart';
export 'collection_styles.dart';

/// 🎒 Màn hình Tủ Đồ & Góc Của Bé (Clean View Component)
/// Cấu trúc theo mô hình React JSX + CSS:
/// - Controller [CollectionController] quản lý State & Logic
/// - Stylesheet [CollectionStyles] quản lý định dạng Box/Text
/// - Giao diện tinh giản, hiển thị 3 Segment: Nhân vật 3D, Truyện đã đọc, Thành tích
class CollectionScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onOpenDrawing;
  final VoidCallback? onOpenLibrary;

  const CollectionScreen({
    super.key,
    required this.appState,
    required this.onOpenDrawing,
    this.onOpenLibrary,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late final CollectionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CollectionController();
    final childId = widget.appState.activeChildProfile?.id;
    _controller.loadQuizHistory(childId, widget.appState.authToken);
    _controller.loadCreditLogs(widget.appState.authToken);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _playSound(KidCharacter char) {
    _showToast('${char.name}: "${char.voicePhrase}"');
  }

  void _onRoleplay(KidCharacter char) {
    widget.appState.setHeroCharacter(char);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoleAssignmentScreen(
          appState: widget.appState,
        ),
      ),
    );
  }

  Widget _buildCharactersTab(AppState state, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick Action: Vẽ thêm bạn 3D
        GestureDetector(
          onTap: widget.onOpenDrawing,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFE4E2DD),
                  offset: Offset(0, 3),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFD99800),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vẽ thêm bạn 3D mới ngay',
                        style: AppTypography.headlineSm(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Biến nét vẽ của bé thành nhân vật sống động',
                        style: AppTypography.bodySm(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Danh sách nhân vật
        if (state.characters.isEmpty)
          AppEmptyState(
            icon: Icons.palette_outlined,
            title: 'Chưa có nhân vật nào!',
            message: 'Bé hãy vào mục Bé Vẽ Tranh để tạo nhân vật đầu tiên nhé!',
            actionLabel: 'Vẽ Bạn Mới Ngay',
            onAction: widget.onOpenDrawing,
          )
        else if (isTablet)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.gridColumns(
                context,
                mobile: 1,
                tablet: 2,
                desktop: 3,
              ),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 155,
            ),
            itemCount: state.characters.length,
            itemBuilder: (_, idx) => CharacterCard(
              character: state.characters[idx],
              onPlaySound: () => _playSound(state.characters[idx]),
              onRoleplay: () => _onRoleplay(state.characters[idx]),
            ),
          )
        else
          Column(
            children: state.characters.map((char) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CharacterCard(
                  character: char,
                  onPlaySound: () => _playSound(char),
                  onRoleplay: () => _onRoleplay(char),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _openStory(Story story) {
    widget.appState.setCurrentStory(story);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryPlayerScreen(
          story: story,
          appState: widget.appState,
        ),
      ),
    );
  }

  Widget _buildCompletedStoriesTab() {
    final completedStories = widget.appState.completedStories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_controller.quizHistory.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Lịch Sử Đố Vui & Bài Học',
              style: AppTypography.headlineSm(color: AppColors.onSurface),
            ),
          ),
          ..._controller.quizHistory.map((log) {
            final starsText =
                log.stars > 0 ? '${log.stars} sao' : 'Đang làm';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.quiz_rounded, size: 22, color: Color(0xFFD97706)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đúng ${log.totalCorrectAnswers}/${log.totalQuestions} câu (${log.accuracyPercentage.round()}%)',
                          style: AppTypography.labelMd(
                            color: const Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Đã trả lời ${log.totalAnswered}/${log.totalQuestions} câu hỏi',
                          style: AppTypography.bodySm(
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    starsText,
                    style: AppTypography.labelMd(color: AppColors.primary),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
        if (completedStories.isEmpty)
          AppEmptyState(
            icon: Icons.menu_book_rounded,
            title: 'Chưa có câu chuyện nào đã đọc!',
            message: 'Bé hãy chọn một câu chuyện trong Kho Truyện để cùng đọc và phiêu lưu nhé!',
            actionLabel: 'Khám Phá Kho Truyện',
            onAction: widget.onOpenLibrary,
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Truyện Bé Đã Hoàn Thành (${completedStories.length})',
              style: AppTypography.headlineSm(color: AppColors.onSurface),
            ),
          ),
          ...completedStories.map(
            (s) => CompletedStoryCard(
              title: s.title,
              artist: s.characterName.isNotEmpty ? s.characterName : widget.appState.kidName,
              imageUrl: s.coverUrl,
              onReplay: () => _openStory(s),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final isTablet = Responsive.isTabletOrDesktop(context);

    final activeProfile = state.activeChildProfile ??
        ChildProfile(
          id: 'local-child',
          nickName: state.kidName,
          dailyTimeLimit: state.screenTimeMinutesAllowed,
          stars: state.stars,
          streakDays: state.streakDays,
        );

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: () => _controller.refreshProfile(
            state,
            onToast: _showToast,
          ),
          color: AppColors.primaryContainer,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: ResponsiveContainer(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.horizontalPadding(context),
                vertical: 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Unified Hero Profile Header Card
                  CollectionHeroHeader(
                    profile: activeProfile,
                    state: state,
                    isRefreshing: _controller.isRefreshing,
                    onRefresh: () => _controller.refreshProfile(
                      state,
                      onToast: _showToast,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Segment Switcher (Nhân vật | Truyện đã đọc | Thành tích)
                  CollectionSegmentBar(
                    activeSegment: _controller.activeSegment,
                    characterCount: state.characters.length,
                    onSegmentChanged: (idx) => _controller.setSegment(idx),
                  ),

                  const SizedBox(height: 18),

                  // 3. Tab Contents
                  if (_controller.activeSegment == 0)
                    _buildCharactersTab(state, isTablet)
                  else if (_controller.activeSegment == 1)
                    _buildCompletedStoriesTab()
                  else
                    CollectionAchievementsView(
                      profile: activeProfile,
                      state: state,
                      quizHistory: _controller.quizHistory,
                      creditLogs: _controller.creditLogs,
                      isLoadingCreditLogs: _controller.isLoadingCreditLogs,
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

