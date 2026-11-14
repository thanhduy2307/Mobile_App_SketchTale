import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/quiz_service.dart';
import '../../services/story_audio_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'dialogs/quiz_correct_dialog.dart';

/// 🧠 Controller Quản Lý Logic Câu Đố & Điểm Thưởng (Safe-to-Fail UX)
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

  // Safe-to-Fail UX state
  final Set<int> disabledOptionIndices = {};
  int? correctSelectedIndex;
  bool isPlayingAudio = false;
  final StoryAudioService _audioService = StoryAudioService();

  QuizRewardController({required Story story}) {
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
  void nextQuestion(BuildContext context) {
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
      _showCompletionCelebration(context);
    }
  }

  void _showCompletionCelebration(BuildContext context) {
    final quiz = quizzes.isNotEmpty ? quizzes.last : null;
    if (quiz == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
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

  /// Xử lý chọn đáp án trực tiếp theo quy tắc "Không phạt khi sai"
  void handleOptionSelection({
    required int index,
    required BuildContext context,
    required AppState appState,
    required Story story,
    required String? readingLogId,
  }) {
    if (disabledOptionIndices.contains(index)) return;
    if (correctSelectedIndex != null) return;

    final quiz = getCurrentQuiz(story);
    final bool isCorrect = (index == quiz.correctIndex);

    if (isCorrect) {
      correctSelectedIndex = index;
      rewardClaimed = true;
      notifyListeners();

      // Ghi nhận đáp án đúng lên Backend
      final tpl = currentTemplate;
      if (readingLogId != null && tpl != null) {
        QuizService.submitAnswer(
          readingLogId: readingLogId,
          storyQuizTemplateId: tpl.id,
          selectedOptionIndex: index,
          responseTimeSeconds: questionTimer.elapsed.inSeconds,
          childProfileId: appState.activeChildProfile?.id,
          token: appState.authToken,
        );
      }
    } else {
      disabledOptionIndices.add(index);
      notifyListeners();

      // Ghi nhận lần thử sai lên Backend
      final tpl = currentTemplate;
      if (readingLogId != null && tpl != null) {
        QuizService.submitAnswer(
          readingLogId: readingLogId,
          storyQuizTemplateId: tpl.id,
          selectedOptionIndex: index,
          responseTimeSeconds: questionTimer.elapsed.inSeconds,
          childProfileId: appState.activeChildProfile?.id,
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
