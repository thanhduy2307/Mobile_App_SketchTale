import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

/// Thanh dieu huong & Tien trinh cau do dang hinh anh sinh dong (Visual Progress Track)
/// Hinh nhan vat chay tu trai sang phai huong ve phia hop qua ky dieu o cuoi thanh.
class QuizScoreBanner extends StatelessWidget {
  final Story story;
  final int currentQuizIndex;
  final int totalQuizzes;
  final double progressFactor;
  final int progressPercent;
  final bool hasBackendTemplates;
  final AnimationController starBounceController;
  final VoidCallback onBack;
  final VoidCallback onPlayAudio;
  final bool isPlayingAudio;

  const QuizScoreBanner({
    super.key,
    required this.story,
    required this.currentQuizIndex,
    required this.totalQuizzes,
    required this.progressFactor,
    required this.progressPercent,
    required this.hasBackendTemplates,
    required this.starBounceController,
    required this.onBack,
    required this.onPlayAudio,
    this.isPlayingAudio = false,
  });

  @override
  Widget build(BuildContext context) {
    final int safeTotal = totalQuizzes > 0 ? totalQuizzes : 1;
    final double clampedProgress = (currentQuizIndex / safeTotal).clamp(
      0.0,
      1.0,
    );
    final bool isAtFinalGoal = currentQuizIndex >= safeTotal - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Navigation Bar (chi giu nut Ve Truyen o goc trai)
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.6),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C001050),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 13,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Về Truyện',
                    style: AppTypography.labelMd(color: AppColors.secondary),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Visual Progress Track (Nhân vật chạy về phía hộp quà)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.7)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0E001050),
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tiêu đề chặng đua về đích
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.directions_run_rounded,
                        size: 17,
                        color: Color(0xFFD97706),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Đường đua về Đích',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isAtFinalGoal
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAtFinalGoal ? 'Đã về đích' : 'Về đích',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isAtFinalGoal
                            ? const Color(0xFF065F46)
                            : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Đường chạy trực quan với nhân vật và hộp quà
              LayoutBuilder(
                builder: (context, constraints) {
                  final trackWidth = constraints.maxWidth;
                  const double mascotSize = 36.0;
                  const double giftSize = 38.0;
                  final double usableWidth = trackWidth - mascotSize - giftSize;
                  final double mascotLeft = (usableWidth * clampedProgress)
                      .clamp(0.0, usableWidth);

                  return SizedBox(
                    height: 50,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Thanh ray (Road track background)
                        Positioned(
                          left: 12,
                          right: giftSize / 2,
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),

                        // Thanh tiến độ đã chạy qua (Road track active)
                        Positioned(
                          left: 12,
                          width: (mascotLeft + mascotSize / 2).clamp(
                            14.0,
                            trackWidth - giftSize / 2,
                          ),
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFF10B981)],
                              ),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),

                        // Nhân vật chạy dọc theo tiến độ
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutBack,
                          left: mascotLeft,
                          child: Container(
                            width: mascotSize,
                            height: mascotSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFF59E0B),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x25000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(3),
                            child: Image.asset(
                              'assets/images/SketchTale_Mascot_Loading.webp',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/bobby-di-bo.webp',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        // Vạch đích / Cúp chiến thắng ở cuối đường đua
                        Positioned(
                          right: 0,
                          child: ScaleTransition(
                            scale: Tween(begin: 1.0, end: 1.15).animate(
                              CurvedAnimation(
                                parent: starBounceController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: Container(
                              width: giftSize,
                              height: giftSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isAtFinalGoal
                                    ? const Color(0xFFFEF08A)
                                    : Colors.white,
                                border: Border.all(
                                  color: isAtFinalGoal
                                      ? const Color(0xFFEAB308)
                                      : const Color(0xFFCBD5E1),
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x18000000),
                                    offset: Offset(0, 2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  isAtFinalGoal
                                      ? Icons.emoji_events_rounded
                                      : Icons.flag_rounded,
                                  size: 20,
                                  color: isAtFinalGoal
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Chú thích tiến độ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Câu ${currentQuizIndex + 1} / $safeTotal',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  Text(
                    isAtFinalGoal
                        ? 'Sắp cán đích thành công!'
                        : 'Sắp về đích rồi!',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
