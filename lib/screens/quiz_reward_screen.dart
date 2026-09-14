import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class QuizRewardScreen extends StatefulWidget {
  final AppState appState;
  final Story story;
  final VoidCallback onOpenParentGate;

  const QuizRewardScreen({
    super.key,
    required this.appState,
    required this.story,
    required this.onOpenParentGate,
  });

  @override
  State<QuizRewardScreen> createState() => _QuizRewardScreenState();
}

class _QuizRewardScreenState extends State<QuizRewardScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedOptionIndex = 0; // Default to correct answer for showcase or kid interaction
  bool _rewardClaimed = false;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onClaimReward() {
    if (!_rewardClaimed) {
      widget.appState.addStars(5);
      setState(() => _rewardClaimed = true);
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.story.quiz;
    final isCorrect = (_selectedOptionIndex == quiz.correctIndex);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        leading: ChunkyIconButton(
          size: 40,
          borderDepth: 3,
          backgroundColor: AppColors.surfaceContainer,
          borderColor: const Color(0xFFD6C4AC),
          icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Câu Đố Vui & Thưởng Sao',
          style: AppTypography.headlineMd(color: AppColors.primary),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${widget.appState.stars}',
                  style: AppTypography.labelMd(color: AppColors.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Celebration Top Ribbon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 4), blurRadius: 0),
                ],
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _confettiController,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(0, -6 * _confettiController.value),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryFixed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFFFFBA38), offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(
                        Icons.celebration_rounded,
                        color: AppColors.onPrimaryFixed,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            'Hoàn thành Chương 2',
                            style: AppTypography.labelSm(color: AppColors.onTertiaryFixed),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hoan hô ${widget.appState.kidName}! 🎉',
                          style: AppTypography.headlineLg(color: AppColors.onSurface),
                        ),
                        Text(
                          'Đã đọc xong trang 6 xuất sắc!',
                          style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Question Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Audio Replay button & Question Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ChunkyButton(
                        height: 42,
                        borderDepth: 3,
                        backgroundColor: AppColors.tertiary,
                        borderColor: const Color(0xFF004D67),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đang đọc câu hỏi: ${quiz.questionText}',
                                style: AppTypography.labelMd(color: Colors.white),
                              ),
                              backgroundColor: AppColors.tertiary,
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.volume_up_rounded, size: 18, color: Colors.white),
                            const SizedBox(width: 6),
                            Text('Nghe lại câu hỏi', style: AppTypography.labelSm(color: Colors.white)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: AppColors.primaryContainer, size: 18),
                          const SizedBox(width: 4),
                          Text('CÂU HỎI SỐ 1', style: AppTypography.labelSm(color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Question Title
                  RichText(
                    text: TextSpan(
                      text: 'Trong câu chuyện, bạn ',
                      style: AppTypography.headlineMd(color: AppColors.onSurface),
                      children: [
                        TextSpan(
                          text: widget.appState.heroCharacter?.name ?? 'Khủng Long Cam',
                          style: AppTypography.headlineMd(color: AppColors.secondary),
                        ),
                        const TextSpan(
                          text: ' đã tìm thấy quả gì trong khu rừng thần tiên?',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Visual Hint Illustration
                  if (quiz.visualClueUrl.isNotEmpty)
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                quiz.visualClueUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: AppColors.surfaceContainerHigh,
                                  child: const Center(
                                    child: Icon(Icons.lightbulb_rounded, color: AppColors.primaryContainer, size: 48),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lightbulb_rounded, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text('Manh mối bí mật', style: AppTypography.labelSm(color: AppColors.onSurface)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Big Interactive Answer Choices
            Column(
              children: List.generate(quiz.options.length, (idx) {
                final isSelected = (_selectedOptionIndex == idx);
                final optionLabel = String.fromCharCode(65 + idx); // A, B, C
                final emoji = quiz.optionEmojis[idx];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedOptionIndex = idx),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryFixed.withValues(alpha: 0.4)
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryContainer : const Color(0xFFE4E2DD),
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? const Color(0xFFD6C4AC) : const Color(0xFFE4E2DD),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: isSelected
                                  ? const [BoxShadow(color: Color(0xFFFFBA38), offset: Offset(0, 3))]
                                  : null,
                            ),
                            child: Center(
                              child: Text(emoji, style: const TextStyle(fontSize: 26)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lựa chọn $optionLabel',
                                  style: AppTypography.labelSm(
                                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  quiz.options[idx],
                                  style: AppTypography.headlineMd(
                                    color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isSelected
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                  : Text(optionLabel, style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Positive Reinforcement Feedback Box
            if (isCorrect) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFFFB59F), offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF852300), offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.thumb_up_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(quiz.celebrationTitle, style: AppTypography.headlineMd(color: AppColors.onSecondaryFixed)),
                          Text(quiz.celebrationMessage, style: AppTypography.bodyMd(color: AppColors.onSecondaryFixedVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Reward Counter Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFFFBA38), offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('+${quiz.rewardStars} Sao Phép Thuật', style: AppTypography.labelLg(color: AppColors.onPrimaryFixed)),
                            Text('Đã bay vào túi phép thuật', style: AppTypography.bodyMd(color: AppColors.onPrimaryFixed)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: const [BoxShadow(color: Color(0xFFD6C4AC), offset: Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.appState.stars + (_rewardClaimed ? 0 : 5)} ⭐',
                            style: AppTypography.labelMd(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Bottom Actions
            ChunkyButton(
              height: 62,
              borderDepth: 6,
              backgroundColor: AppColors.secondaryContainer,
              borderColor: const Color(0xFF852300),
              foregroundColor: Colors.white,
              onPressed: _onClaimReward,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.redeem_rounded, size: 28, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Nhận Thưởng & Về Thư Viện',
                    style: AppTypography.headlineMd(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ChunkyButton(
              height: 52,
              borderDepth: 4,
              backgroundColor: AppColors.surfaceContainerHigh,
              borderColor: const Color(0xFFD6C4AC),
              foregroundColor: AppColors.onSurfaceVariant,
              onPressed: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.replay_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text('Đọc lại truyện', style: AppTypography.labelLg(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
