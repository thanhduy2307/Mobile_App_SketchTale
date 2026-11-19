import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_screen_background.dart';
import '../../widgets/story_player/story_audio_player_card.dart';
import '../../widgets/story_player/story_canvas_view.dart';
import '../../widgets/story_player/story_header_bar.dart';
import '../../widgets/story_player/story_player_bottom_bar.dart';
import '../../widgets/story_player/story_quiz_tab.dart';
import '../../widgets/story_player/story_tab_bar.dart';
import '../../widgets/story_player/story_text_card.dart';
import '../../widgets/story_player/story_vocabulary_tab.dart';
import '../quiz_reward/quiz_reward_screen.dart';
import 'dialogs/content_report_dialog.dart';
import 'dialogs/role_assignment_sheet.dart';
import 'dialogs/story_finished_dialog.dart';
import 'dialogs/vocab_detail_sheet.dart';
import 'story_player_controller.dart';

export '../../widgets/story_player/story_tab_bar.dart' show StoryPlayerTab;
export 'story_player_controller.dart';
export 'story_player_styles.dart';

/// 📖 Trình Đọc Truyện Tương Tác Trẻ Em (Clean View Component)
/// Cấu trúc theo mô hình React JSX + CSS:
/// - Toàn bộ Logic/Audio/Timeline/Quiz nằm trong [StoryPlayerController]
/// - Toàn bộ Stylesheet/BoxDecoration nằm trong [StoryPlayerStyles]
/// - Giao diện chỉ thuần túy render cấu trúc cây component, cực kỳ ngắn gọn và dễ bảo trì.
class StoryPlayerScreen extends StatefulWidget {
  final AppState appState;
  final Story story;
  final String? readingLogId;
  final bool isOriginalTemplate;

  const StoryPlayerScreen({
    super.key,
    required this.appState,
    required this.story,
    this.readingLogId,
    this.isOriginalTemplate = false,
  });

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends State<StoryPlayerScreen>
    with TickerProviderStateMixin {
  /// Ẩn tạm thời các Tab Từ Vựng, Đố Vui, Hoạt Hoạ theo yêu cầu (giữ nguyên code dùng lại sau)
  static const bool _showExtraTabs = false;

  late final StoryPlayerController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = StoryPlayerController(
      vsync: this,
      story: widget.story,
      appState: widget.appState,
      readingLogId: widget.readingLogId,
      isOriginalTemplate: widget.isOriginalTemplate,
    )..initialize();

    _controller.onStoryCompleted = () {
      if (!mounted) return;
      StoryFinishedDialog.show(
        context,
        storyTitle: widget.story.title,
        onOpenQuizReward: _openQuizRewardScreen,
      );
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openQuizRewardScreen() {
    _controller.completeReadingSession();
    widget.appState.markStoryCompleted(widget.story.id);
    final storyForQuiz = widget.story.copyWith(
      quiz: _controller.storyQuizzes.isNotEmpty
          ? _controller.storyQuizzes.first
          : widget.story.quiz,
      quizTemplates: _controller.quizTemplates.isNotEmpty
          ? _controller.quizTemplates
          : widget.story.quizTemplates,
      isCompleted: true,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizRewardScreen(
          appState: widget.appState,
          story: storyForQuiz,
          readingLogId: _controller.activeReadingLogId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScreenBackground(
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoadingPages) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  widget.story.title,
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLoadingLogo(size: 80),
                    const SizedBox(height: 20),
                    Text(
                      'Đang Mở Cuốn Truyện Kỳ Diệu...',
                      style: AppTypography.headlineMd(color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bé chờ một xíu nhé, các trang sách đang mở ra...',
                      style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }

          final pages = _controller.pages.isNotEmpty
              ? _controller.pages
              : widget.story.pages;

          if (pages.isEmpty) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: Center(
                child: AppEmptyState(
                  icon: Icons.menu_book_rounded,
                  title: 'Chưa có nội dung cho câu chuyện này',
                  message: 'Bé hãy thử chọn một cuốn truyện khác trong Thư viện nhé!',
                  actionLabel: 'Quay Lại',
                  onAction: () => Navigator.of(context).pop(),
                ),
              ),
            );
          }

          final currentPage =
              (_controller.currentPageIndex < pages.length)
              ? pages[_controller.currentPageIndex]
              : pages.first;

          final vocabList = _controller.allStoryVocabularies.values.isNotEmpty
              ? _controller.allStoryVocabularies.values.toList()
              : _controller.pageVocabularies;

          return Scaffold(
            backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.horizontalPadding(context),
                vertical: 10,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Responsive.kMaxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Top Header Bar (Back, Title, Progress Dots, Language & Safety Report)
                      StoryHeaderBar(
                        title: widget.story.title,
                        currentPageIndex: _controller.currentPageIndex,
                        totalPages: pages.length,
                        onPageDotTap: (index) =>
                            _controller.changePage(index, pages),
                        showEnglish: _controller.showEnglish,
                        onToggleEnglish: _controller.toggleEnglish,
                        onReportTap: () => ContentReportDialog.show(
                          context,
                          storyId: widget.story.id,
                          token: widget.appState.authToken,
                          onShowToast: _showToast,
                        ),
                        onBackPressed: () => Navigator.of(context).pop(),
                        showRolesButton: true,
                        onRolesTap: () => RoleAssignmentSheet.show(
                          context,
                          appState: widget.appState,
                          story: widget.story,
                          storyRoles: _controller.storyRoles,
                          storyMappings: _controller.storyMappings,
                          onShowToast: _showToast,
                          onRolesChanged: () {
                            _controller.isOriginalTemplate = false;
                            if (_controller.pages.isNotEmpty &&
                                _controller.currentPageIndex < _controller.pages.length) {
                              _controller.syncActionForCurrentPage(
                                _controller.pages[_controller.currentPageIndex],
                              );
                            }
                            setState(() {});
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 2. Playful Mode Tab Bar (Ẩn tạm thời theo yêu cầu người dùng, giữ nguyên code dùng lại sau)
                      if (_showExtraTabs) ...[
                        StoryTabBar(
                          activeTab: _controller.activeTab,
                          onTabChanged: (tab) => _controller.setActiveTab(tab),
                          vocabCount: vocabList.length,
                          quizCount: _controller.storyQuizzes.length,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // 3. Tab Contents: Reader or Vocabulary or Quiz
                      if (_controller.activeTab == StoryPlayerTab.reader) ...[
                        // A. 16:9 Canvas bám sát 100% thiết lập của Content Manager (CM)
                        Builder(
                          builder: (context) {
                            final stageSlots = _controller.buildStageSlotItems(
                              currentPage,
                            );
                            final liveSubtitle = (currentPage != null && currentPage.subtitles.isNotEmpty)
                                ? currentPage.subtitleAtPlayhead(_controller.playheadMs)
                                : (currentPage?.characterSpeech ?? currentPage?.textContent ?? '');
                            final effectiveSubtitle = (liveSubtitle.trim().isNotEmpty &&
                                    liveSubtitle.trim().toLowerCase() != 'string' &&
                                    liveSubtitle.trim().toLowerCase() != 'null')
                                ? liveSubtitle.trim()
                                : 'Trang ${_controller.currentPageIndex + 1}: Cùng khám phá câu chuyện "${widget.story.title}"';

                            final rawImg = currentPage?.imageUrl ?? '';
                            final effectiveImage = (rawImg.isNotEmpty &&
                                    rawImg.toLowerCase() != 'string' &&
                                    !rawImg.toLowerCase().endsWith('/string') &&
                                    rawImg.toLowerCase() != 'null')
                                ? rawImg
                                : ((widget.story.coverUrl.isNotEmpty &&
                                        widget.story.coverUrl.toLowerCase() != 'string' &&
                                        !widget.story.coverUrl.toLowerCase().endsWith('/string'))
                                    ? widget.story.coverUrl
                                    : 'assets/images/Br.png');

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 380),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              child: StoryCanvasView(
                                key: ValueKey('canvas-page-${currentPage?.id ?? _controller.currentPageIndex}'),
                                imageUrl: effectiveImage,
                                chapterTitle:
                                    currentPage?.chapterTitle ??
                                    'Trang ${_controller.currentPageIndex + 1} / ${pages.length}',
                                category: widget.story.category,
                                subtitleText: effectiveSubtitle,
                                stageSlots: stageSlots,
                                heroCharacter: widget.appState.heroCharacter,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // B. Dedicated Kid-Friendly Interactive Audio Player Card
                        StoryAudioPlayerCard(
                          isPlaying: _controller.isPlayingAudio,
                          position: _controller.audioPosition,
                          duration: _controller.audioDuration,
                          onTogglePlay: _controller.toggleAudio,
                          onSeek: (pos) => _controller.audioService.seek(pos),
                          onRewind5s: () =>
                              _controller.audioService.rewind5Seconds(),
                          narratorName:
                              currentPage?.narratorName ?? 'Chú Gấu Pô',
                          audioUrl: currentPage?.audioNarrationUrl,
                        ),

                        const SizedBox(height: 12),

                        // C. Clean Kid-Friendly Story Text Card với Highlight Từ Vựng & Linh vật tương tác (Giu nguyen giao dien doc nhu cu)
                        Builder(
                          builder: (context) {
                            final currentPageId = (currentPage?.id ?? '').toLowerCase();
                            final List<VocabularyTemplate> combinedVocabs = [
                              ..._controller.pageVocabularies,
                              if (currentPage != null && currentPage.vocabularies.isNotEmpty)
                                ...currentPage.vocabularies,
                              if (currentPage != null && currentPage.vocab != null)
                                VocabularyTemplate(
                                  id: 'embedded_${currentPage.pageNumber}',
                                  storyPageTemplateId: currentPage.id ?? '',
                                  word: currentPage.vocab!.word,
                                  meaning: currentPage.vocab!.definition,
                                ),
                              ..._controller.allStoryVocabularies.values.where(
                                (v) =>
                                    currentPageId.isEmpty ||
                                    v.storyPageTemplateId.isEmpty ||
                                    v.storyPageTemplateId.toLowerCase() == currentPageId,
                              ),
                            ];
                            final Map<String, VocabularyTemplate> dedupMap = {};
                            for (final v in combinedVocabs) {
                              final key = v.word.trim().toLowerCase();
                              if (key.isNotEmpty && !dedupMap.containsKey(key)) {
                                dedupMap[key] = v;
                              }
                            }
                            final effectiveVocabs = dedupMap.values.toList();

                            final rawContent = currentPage?.textContent ?? '';
                            final effectiveContent = (rawContent.isNotEmpty &&
                                    rawContent.toLowerCase() != 'string' &&
                                    rawContent.toLowerCase() != 'null')
                                ? rawContent
                                : 'Trang ${_controller.currentPageIndex + 1}: Bé hãy cùng khám phá câu chuyện "${widget.story.title}" thật kỳ diệu nhé!';

                            return StoryTextCard(
                              textContent: effectiveContent,
                              englishSubtitle: currentPage?.englishSubtitle,
                              showEnglish: _controller.showEnglish,
                              narratorName:
                                  currentPage?.narratorName ?? 'Chú Gấu Pô',
                              audioPosition: _controller.audioPosition,
                              audioDuration: _controller.audioDuration,
                              isPlayingAudio: _controller.isPlayingAudio,
                              onSeekAudio: (pos) =>
                                  _controller.audioService.seek(pos),
                              vocabularies: effectiveVocabs,
                              onVocabTap: (vocab) async {
                                final wasPlaying = _controller.isPlayingAudio;
                                if (wasPlaying) {
                                  await _controller.audioService.pauseAudio();
                                }
                                await VocabDetailSheet.show(
                                  context,
                                  vocab: vocab,
                                  isLearned: _controller.learnedVocabIds.contains(vocab.id),
                                  onMarkLearned: () =>
                                      _controller.markVocabLearned(vocab.id),
                                  onShowToast: _showToast,
                                  onInspectVocab: _controller.inspectVocabularyDetail,
                                );
                                if (wasPlaying) {
                                  await _controller.audioService.resumeAudio();
                                }
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // D. 3D Squishy Navigation Bottom Bar (Tập trung điều hướng chuyển trang cho bé)
                        StoryPlayerBottomBar(
                          currentPageIndex: _controller.currentPageIndex,
                          totalPages: pages.length,
                          onPrevPage: () => _controller.changePage(
                            _controller.currentPageIndex - 1,
                            pages,
                          ),
                          onNextPage: () => _controller.changePage(
                            _controller.currentPageIndex + 1,
                            pages,
                          ),
                          onPageSelect: (idx) => _controller.changePage(
                            idx,
                            pages,
                          ),
                          onFinishStory: () {
                            _controller.completeReadingSession();
                            StoryFinishedDialog.show(
                              context,
                              storyTitle: widget.story.title,
                              onOpenQuizReward: _openQuizRewardScreen,
                            );
                          },
                        ),
                      ] else if (_controller.activeTab ==
                          StoryPlayerTab.vocabulary) ...[
                        // Tab Từ Vựng
                        StoryVocabularyTab(
                          vocabList: vocabList,
                          learnedVocabIds: _controller.learnedVocabIds,
                          isLoading: _controller.isLoadingVocabularies,
                          storyTitle: widget.story.title,
                          onVocabTap: (vocab) => VocabDetailSheet.show(
                            context,
                            vocab: vocab,
                            isLearned: _controller.learnedVocabIds.contains(
                              vocab.id,
                            ),
                            onMarkLearned: () =>
                                _controller.markVocabLearned(vocab.id),
                            onShowToast: _showToast,
                            onInspectVocab: _controller.inspectVocabularyDetail,
                          ),
                          onBackToReader: () =>
                              _controller.setActiveTab(StoryPlayerTab.reader),
                          onGoToQuiz: () =>
                              _controller.setActiveTab(StoryPlayerTab.quiz),
                        ),
                      ] else if (_controller.activeTab ==
                          StoryPlayerTab.quiz) ...[
                        // Tab Đố Vui Nhận Sao
                        StoryQuizTab(
                          quizList: _controller.storyQuizzes,
                          currentQuizIndex: _controller.currentTabQuizIndex,
                          selectedOption: _controller.selectedTabQuizOption,
                          quizChecked: _controller.tabQuizChecked,
                          quizIsCorrect: _controller.tabQuizIsCorrect,
                          isLoading: _controller.isLoadingQuizzes,
                          isSubmitting: _controller.isSubmittingTabQuiz,
                          earnedStars: _controller.tabQuizStars,
                          feedbackMessage: _controller.tabQuizFeedback,
                          onSelectOption: (idx) =>
                              _controller.selectTabQuizOption(idx),
                          onCheckAnswer: _controller.checkTabQuizAnswer,
                          onNextQuiz: () =>
                              _controller.nextTabQuiz(_openQuizRewardScreen),
                          onBackToReader: () =>
                              _controller.setActiveTab(StoryPlayerTab.reader),
                          onOpenRewardScreen: _openQuizRewardScreen,
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
}
