import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../app_loading.dart';

/// Clean Dedicated Comprehension Quiz Tab View
class StoryQuizTab extends StatelessWidget {
  final List<QuizQuestion> quizList;
  final int currentQuizIndex;
  final int selectedOption;
  final bool quizChecked;
  final bool quizIsCorrect;
  final bool isLoading;
  final bool isSubmitting;
  final int? earnedStars;
  final String? feedbackMessage;
  final ValueChanged<int> onSelectOption;
  final VoidCallback onCheckAnswer;
  final VoidCallback onNextQuiz;
  final VoidCallback onBackToReader;
  final VoidCallback onOpenRewardScreen;

  const StoryQuizTab({
    super.key,
    required this.quizList,
    required this.currentQuizIndex,
    required this.selectedOption,
    required this.quizChecked,
    required this.quizIsCorrect,
    required this.isLoading,
    this.isSubmitting = false,
    this.earnedStars,
    this.feedbackMessage,
    required this.onSelectOption,
    required this.onCheckAnswer,
    required this.onNextQuiz,
    required this.onBackToReader,
    required this.onOpenRewardScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: const AppLoadingLogo(
          size: 64,
          label: 'Đang tải câu hỏi đố vui...',
        ),
      );
    }

    if (quizList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        alignment: Alignment.center,
        child: const AppLoadingLogo(
          size: 56,
          label: 'Đang chuẩn bị câu hỏi đố vui...',
        ),
      );
    }

    final currentQuiz = (currentQuizIndex < quizList.length)
        ? quizList[currentQuizIndex]
        : quizList.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quiz Header Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18F59E0B),
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.quiz_rounded, size: 24, color: Color(0xFFD97706)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thử Thách Đố Vui',
                      style: AppTypography.headlineSm(color: const Color(0xFF92400E)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Câu hỏi ${currentQuizIndex + 1}/${quizList.length} • Kiểm tra mức độ hiểu bài',
                      style: AppTypography.bodySm(color: const Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onOpenRewardScreen,
                tooltip: 'Mở sân khấu đố vui toàn màn hình',
                icon: const Icon(
                  Icons.open_in_full_rounded,
                  color: Color(0xFFB45309),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quiz Question Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFD8E3FB),
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentQuiz.questionText,
                style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),

              // Options
              for (int i = 0; i < currentQuiz.options.length; i++) ...[
                GestureDetector(
                  onTap: (quizChecked || isSubmitting) ? null : () => onSelectOption(i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedOption == i
                          ? const Color(0xFFFEF3C7)
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: quizChecked
                            ? (i == currentQuiz.correctIndex
                                ? const Color(0xFF10B981)
                                : (selectedOption == i
                                    ? AppColors.error
                                    : Colors.transparent))
                            : (selectedOption == i
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFE2E8F0)),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: selectedOption == i
                                ? const Color(0xFFF59E0B)
                                : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + i), // A, B, C, D
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedOption == i
                                    ? Colors.white
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            currentQuiz.options[i],
                            style: AppTypography.bodyMd(color: AppColors.onSurface),
                          ),
                        ),
                        if (quizChecked && i == currentQuiz.correctIndex)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                        else if (quizChecked && selectedOption == i && !quizIsCorrect)
                          const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
                      ],
                    ),
                  ),
                ),
              ],

              if (quizChecked && feedbackMessage != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: quizIsCorrect
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: quizIsCorrect
                          ? const Color(0xFF6EE7B7)
                          : const Color(0xFFFCD34D),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        quizIsCorrect ? Icons.check_circle_rounded : Icons.lightbulb_outline_rounded,
                        size: 20,
                        color: quizIsCorrect ? Colors.green : Colors.amber.shade800,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feedbackMessage!,
                          style: AppTypography.bodySm(color: AppColors.onSurface),
                        ),
                      ),
                      if (earnedStars != null && earnedStars! > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '+$earnedStars Sao',
                            style: AppTypography.labelSm(color: AppColors.onPrimaryFixed),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ] else
                const SizedBox(height: 10),

              // Action Buttons: Kiểm tra / Tiếp theo
              if (!quizChecked)
                Squishy3DButton(
                  onPressed: isSubmitting ? () {} : onCheckAnswer,
                  height: 48,
                  backgroundColor: const Color(0xFFF59E0B),
                  bevelColor: const Color(0xFFD97706),
                  child: Center(
                    child: isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppLoadingLogo(size: 24),
                              SizedBox(width: 8),
                              Text(
                                'ĐANG CHẤM ĐIỂM...',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          )
                        : const Text(
                            'KIỂM TRA CÂU TRẢ LỜI',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Squishy3DButton(
                        onPressed: currentQuizIndex < quizList.length - 1
                            ? onNextQuiz
                            : onOpenRewardScreen,
                        height: 48,
                        backgroundColor: const Color(0xFF10B981),
                        bevelColor: const Color(0xFF059669),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentQuizIndex < quizList.length - 1
                                  ? 'CÂU TIẾP THEO'
                                  : 'SÂN KHẤU NHẬN SAO',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Back to story reader button
        TextButton.icon(
          onPressed: onBackToReader,
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Quay lại đọc truyện'),
        ),
      ],
    );
  }
}
