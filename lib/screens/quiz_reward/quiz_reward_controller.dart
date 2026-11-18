import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/quiz_service.dart';
import '../../services/reading_log_service.dart';
import '../../services/story_audio_service.dart';
import '../../state/app_state.dart';
import '../../utils/app_config.dart';
import 'dialogs/quiz_correct_dialog.dart';

/// Controller Quan Ly Logic Cau Do & Diem Thuong (Safe-to-Fail UX)
class QuizRewardController extends ChangeNotifier {
  int selectedOptionIndex = 0;
  bool rewardClaimed = false;
  bool showHint = false;
  List<QuizQuestion> quizzes = [];
  List<StoryQuizTemplate> templates = [];
  int currentQuizIndex = 0;
  bool isLoading = false;
  bool isSubmitting = false;
  final Stopwatch questionTimer = Stopwatch();

  String? activeReadingLogId;
  ReadingLogQuizSummary? quizSummary;
  SubmitQuizAnswerResult? lastSubmitResult;

  // Safe-to-Fail UX state
  final Set<int> disabledOptionIndices = {};
  int? correctSelectedIndex;
  bool isPlayingAudio = false;
  final StoryAudioService _audioService = StoryAudioService();

  QuizRewardController({
    required Story story,
    String? initialReadingLogId,
  }) : activeReadingLogId = initialReadingLogId {
    quizzes = story.allQuizzes;
    templates = story.quizTemplates;
    questionTimer.start();
  }

  QuizQuestion getCurrentQuiz(Story story) {
    if (quizzes.isNotEmpty && currentQuizIndex < quizzes.length) {
      return quizzes[currentQuizIndex];
    }
    return story.quiz;
  }

  StoryQuizTemplate? get currentTemplate {
    if (templates.isNotEmpty && currentQuizIndex < templates.length) {
      return templates[currentQuizIndex];
    }
    return null;
  }

  int get totalQuizzes => quizzes.isNotEmpty ? quizzes.length : 1;
  double get progressFactor => ((currentQuizIndex + 1) / totalQuizzes).clamp(0.0, 1.0);
  int get progressPercent => (progressFactor * 100).round();
  bool get isLastQuestion => currentQuizIndex >= totalQuizzes - 1;

  void toggleHint() {
    showHint = !showHint;
    notifyListeners();
  }

  /// Tự động chuyển câu tiếp theo (Safe-to-Fail UX sau 1.5s)
  void nextQuestion(BuildContext context, {AppState? appState}) {
    if (!isLastQuestion) {
      currentQuizIndex++;
      disabledOptionIndices.clear();
      correctSelectedIndex = null;
      selectedOptionIndex = 0;
      rewardClaimed = false;
      showHint = false;
      questionTimer
        ..reset()
        ..start();
      _audioService.pauseAudio();
      isPlayingAudio = false;
      notifyListeners();
    } else {
      // Đã hoàn thành câu cuối: Hiện phần thưởng vinh danh
      _showCompletionCelebration(context, appState: appState);
    }
  }

  void _showCompletionCelebration(BuildContext context, {AppState? appState}) {
    final quiz = quizzes.isNotEmpty ? quizzes.last : null;
    if (quiz == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    // Đồng bộ lại lịch sử quiz & truyện hoàn thành lên server
    if (appState != null) {
      final childId = appState.effectiveChildProfileId;
      if (AppConfig.isValidUuid(childId)) {
        QuizService.fetchChildQuizHistory(childId!, token: appState.authToken);
      }
      appState.syncCompletedStoriesFromBackend();
    }

    QuizCorrectDialog.show(
      context,
      quiz: quiz,
      celebrationMessage: 'Hoan hô bé đã hoàn thành xuất sắc tất cả câu đố!',
      isLastQuestion: true,
      onNext: () {
        // Đọc truyện khác: Quay về Thư Viện truyện (màn hình chính)
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  /// Xu ly chon dap an truc tiep theo quy tac "Khong phat khi sai"
  /// Khong khoa o dap an sai; neu be chon lai o sai van cho phep va nhac be.
  void handleOptionSelection({
    required int index,
    required BuildContext context,
    required AppState appState,
    required Story story,
    required String? readingLogId,
  }) {
    if (correctSelectedIndex != null) return;

    final quiz = getCurrentQuiz(story);
    final bool isCorrect = (index == quiz.correctIndex);

    // 1. Xac dinh storyQuizTemplateId
    final tpl = currentTemplate;
    String targetQuizId = tpl?.id ?? '';
    if (!AppConfig.isValidUuid(targetQuizId)) {
      if (currentQuizIndex < templates.length &&
          AppConfig.isValidUuid(templates[currentQuizIndex].id)) {
        targetQuizId = templates[currentQuizIndex].id;
      } else if (AppConfig.isValidUuid(story.id)) {
        targetQuizId = story.id;
      }
    }

    // 2. Xac dinh readingLogId
    String? effectiveLogId = readingLogId ?? activeReadingLogId;
    if (effectiveLogId == null || !AppConfig.isValidUuid(effectiveLogId)) {
      for (final log in appState.completedReadingLogs) {
        if (log.storyTemplateId.toLowerCase() == story.id.toLowerCase() ||
            log.generatedStoryId.toLowerCase() == story.id.toLowerCase()) {
          if (AppConfig.isValidUuid(log.id)) {
            effectiveLogId = log.id;
            activeReadingLogId = log.id;
            break;
          }
        }
      }
    }

    final logIdToSend = (effectiveLogId != null && AppConfig.isValidUuid(effectiveLogId))
        ? effectiveLogId
        : '00000000-0000-0000-0000-000000000000';

    if (isCorrect) {
      correctSelectedIndex = index;
      rewardClaimed = true;
      notifyListeners();

      // Ghi nhan dap an dung len Backend (POST /api/child-quiz-answers)
      if (kDebugMode) {
        debugPrint(
          '[QuizRewardController] Submitting CORRECT answer to POST /api/child-quiz-answers: '
          'readingLogId=$logIdToSend, quizId=$targetQuizId, option=$index',
        );
      }

      QuizService.submitAnswer(
        readingLogId: logIdToSend,
        storyQuizTemplateId: targetQuizId,
        selectedOptionIndex: index,
        responseTimeSeconds: questionTimer.elapsed.inSeconds,
        childProfileId: appState.effectiveChildProfileId,
        token: appState.authToken,
      ).then((res) {
        if (res != null) {
          lastSubmitResult = res;
          if (res.isQuizCompleted && res.stars > 0) {
            appState.addStars(res.stars);
          }
          if (AppConfig.isValidUuid(logIdToSend) &&
              logIdToSend != '00000000-0000-0000-0000-000000000000') {
            QuizService.fetchReadingLogSummary(
              logIdToSend,
              token: appState.authToken,
            ).then((summary) {
              if (summary != null) {
                quizSummary = summary;
                notifyListeners();
              }
            });
          }
        }
      });
    } else {
      final isFirstWrongAttemptOnOption = disabledOptionIndices.add(index);
      notifyListeners();

      // Ghi nhan lan thu sai dau tien cua o nay len Backend (POST /api/child-quiz-answers)
      if (isFirstWrongAttemptOnOption) {
        if (kDebugMode) {
          debugPrint(
            '[QuizRewardController] Submitting WRONG attempt to POST /api/child-quiz-answers: '
            'readingLogId=$logIdToSend, quizId=$targetQuizId, option=$index',
          );
        }

        QuizService.submitAnswer(
          readingLogId: logIdToSend,
          storyQuizTemplateId: targetQuizId,
          selectedOptionIndex: index,
          responseTimeSeconds: questionTimer.elapsed.inSeconds,
          childProfileId: appState.effectiveChildProfileId,
          token: appState.authToken,
        );
      }
    }
  }

  /// Phát âm thanh câu hỏi từ file âm thanh CM đã set
  Future<void> playQuestionAudio(BuildContext context, Story story) async {
    final tpl = currentTemplate;
    final audioUrl = tpl?.questionAudioUrl;

    if (audioUrl != null && audioUrl.isNotEmpty) {
      if (isPlayingAudio) {
        await _audioService.pauseAudio();
        isPlayingAudio = false;
      } else {
        await _audioService.playAudio(
          tpl!.fullAudioUrl,
          pageNumber: currentQuizIndex + 1,
          storyTitle: 'Câu đố: ${story.title}',
        );
        isPlayingAudio = true;
      }
      notifyListeners();
    } else {
      // Fallback thông báo nếu chưa có file âm thanh
      final quiz = getCurrentQuiz(story);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chú Gấu Pô đọc: "${quiz.questionText}"',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0284C7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> loadQuizzesFromBackend({
    required String storyId,
    required String storyTitle,
    String? token,
    AppState? appState,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final fetched = await QuizService.fetchStoryQuizzes(
        storyId,
        token: token,
        storyTitle: storyTitle,
      );
      if (fetched.isNotEmpty) {
        templates = fetched;
        quizzes = fetched.map((t) => t.toQuizQuestion()).toList();
      }

      // Neu chua co activeReadingLogId, tra cuu hoac khoi tao phien doc
      if (activeReadingLogId == null && appState != null) {
        await appState.syncCompletedStoriesFromBackend();
        String? matchedGenId;
        for (final log in appState.completedReadingLogs) {
          if (log.storyTemplateId.toLowerCase() == storyId.toLowerCase() ||
              log.generatedStoryId.toLowerCase() == storyId.toLowerCase()) {
            matchedGenId = log.generatedStoryId;
            if (AppConfig.isValidUuid(log.id)) {
              activeReadingLogId = log.id;
            }
            break;
          }
        }

        if (activeReadingLogId == null) {
          final started = await ReadingLogService.startReadingSession(
            generatedStoryId: matchedGenId ?? storyId,
            token: token,
          );
          if (started != null && AppConfig.isValidUuid(started.id)) {
            activeReadingLogId = started.id;
          }
        }

        final childId = appState.effectiveChildProfileId;
        if (activeReadingLogId == null && AppConfig.isValidUuid(childId)) {
          final history = await QuizService.fetchChildQuizHistory(
            childId!,
            token: token,
          );
          final quizIds = templates.map((q) => q.id).toSet();
          for (final item in history) {
            if (!AppConfig.isValidUuid(item.readingLogId)) continue;
            if (item.answers.any((a) => quizIds.contains(a.storyQuizTemplateId))) {
              activeReadingLogId = item.readingLogId;
              quizSummary = item;
              break;
            }
          }
        }
      }

      // Kiem tra tien do ket qua quiz cua phien doc hien tai
      // (GET /api/child-quiz-answers/reading-logs/{readingLogId})
      if (activeReadingLogId != null && AppConfig.isValidUuid(activeReadingLogId)) {
        final summary = await QuizService.fetchReadingLogSummary(
          activeReadingLogId!,
          token: token,
        );
        if (summary != null) {
          quizSummary = summary;
        }
      }
    } catch (e) {
      debugPrint('[QuizRewardController] Error loading quizzes: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
