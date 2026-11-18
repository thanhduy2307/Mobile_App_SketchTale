import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_screen_background.dart';
import 'components/quiz_options_list.dart';
import 'components/quiz_question_card.dart';
import 'components/quiz_score_banner.dart';
import 'quiz_reward_controller.dart';

export 'quiz_reward_controller.dart';
export 'quiz_reward_styles.dart';

/// Man hinh Cau Do Vui & Nhan Thuong (Safe-to-Fail UX)
/// - Thanh tien do hinh anh nhan vat chay ve phia hop qua
/// - Giong doc cau hoi tu file am thanh CM
/// - Dap an co gian linh hoat 1 tu den cau dai, can giua
/// - Chon sai: Rung lac nhe, hien bieu tuong sai ben trai, khong khoa o va nhac nho be neu chon lai
/// - Chon dung: Nay len, mau xanh la tuoi, tu dong chuyen cau sau 1.5s
class QuizRewardScreen extends StatefulWidget {
  final AppState appState;
  final Story story;
  final String? readingLogId;

  const QuizRewardScreen({
    super.key,
    required this.appState,
    required this.story,
    this.readingLogId,
  });

  @override
  State<QuizRewardScreen> createState() => _QuizRewardScreenState();
}

class _QuizRewardScreenState extends State<QuizRewardScreen>
    with SingleTickerProviderStateMixin {
  late final QuizRewardController _controller;
  late final AnimationController _starBounceController;

  @override
  void initState() {
    super.initState();
    _controller = QuizRewardController(
      story: widget.story,
      initialReadingLogId: widget.readingLogId,
    );
    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _starBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _controller.loadQuizzesFromBackend(
      storyId: widget.story.id,
      storyTitle: widget.story.title,
      token: widget.appState.authToken,
      appState: widget.appState,
    );
  }

  @override
  void dispose() {
    _starBounceController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _controller.getCurrentQuiz(widget.story);
    final optionDetails = quiz.optionDetails.isNotEmpty
        ? quiz.optionDetails
        : [
            const QuizOptionDetail(letter: 'A', title: 'A. Chiếc Đèn Lồng', subtitle: '', imageUrl: ''),
            const QuizOptionDetail(letter: 'B', title: 'B. Gậy Phép Pha Lê', subtitle: '', imageUrl: ''),
            const QuizOptionDetail(letter: 'C', title: 'C. Ngọn Đuốc Gỗ', subtitle: '', imageUrl: ''),
            const QuizOptionDetail(letter: 'D', title: 'D. Quả Cầu Pha Lê', subtitle: '', imageUrl: ''),
          ];

    return AppScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.horizontalPadding(context),
            vertical: 12,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Responsive.kMaxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Thanh tiến độ dạng hình ảnh (Visual Progress Track)
                  QuizScoreBanner(
                    story: widget.story,
                    currentQuizIndex: _controller.currentQuizIndex,
                    totalQuizzes: _controller.totalQuizzes,
                    progressFactor: _controller.progressFactor,
                    progressPercent: _controller.progressPercent,
                    hasBackendTemplates: _controller.templates.isNotEmpty,
                    starBounceController: _starBounceController,
                    onBack: () => Navigator.of(context).pop(),
                    isPlayingAudio: _controller.isPlayingAudio,
                    onPlayAudio: () => _controller.playQuestionAudio(context, widget.story),
                  ),

                  const SizedBox(height: 14),

                  // 2. Thẻ câu hỏi kèm Mascot & Giọng đọc CM
                  QuizQuestionCard(
                    quiz: quiz,
                    story: widget.story,
                    isPlayingAudio: _controller.isPlayingAudio,
                    onPlayAudio: () => _controller.playQuestionAudio(context, widget.story),
                  ),

                  const SizedBox(height: 18),

                  // 3. Danh sách đáp án co giãn linh hoạt & Safe-to-Fail UX
                  QuizOptionsList(
                    optionDetails: optionDetails,
                    correctIndex: quiz.correctIndex,
                    disabledIndices: _controller.disabledOptionIndices,
                    correctSelectedIndex: _controller.correctSelectedIndex,
                    onSelectOption: (index) => _controller.handleOptionSelection(
                      index: index,
                      context: context,
                      appState: widget.appState,
                      story: widget.story,
                      readingLogId: widget.readingLogId,
                    ),
                    onAutoNext: () => _controller.nextQuestion(
                      context,
                      appState: widget.appState,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
