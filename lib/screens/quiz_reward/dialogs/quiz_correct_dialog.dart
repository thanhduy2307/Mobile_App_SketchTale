import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

/// 🎉 Pop-up chúc mừng khi bé hoàn thành câu đố & về đích
/// Hiển thị linh vật vui nhộn và nút bấm chuyển thẳng về Thư Viện để đọc truyện khác
class QuizCorrectDialog extends StatefulWidget {
  final QuizQuestion quiz;
  final String celebrationMessage;
  final String? starsText;
  final bool isLastQuestion;
  final VoidCallback onNext;

  const QuizCorrectDialog({
    super.key,
    required this.quiz,
    required this.celebrationMessage,
    this.starsText,
    required this.isLastQuestion,
    required this.onNext,
  });

  static Future<void> show(
    BuildContext context, {
    required QuizQuestion quiz,
    required String celebrationMessage,
    String? starsText,
    required bool isLastQuestion,
    required VoidCallback onNext,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => QuizCorrectDialog(
        quiz: quiz,
        celebrationMessage: celebrationMessage,
        starsText: starsText,
        isLastQuestion: isLastQuestion,
        onNext: () {
          Navigator.of(ctx).pop();
          onNext();
        },
      ),
    );
  }

  @override
  State<QuizCorrectDialog> createState() => _QuizCorrectDialogState();
}

class _QuizCorrectDialogState extends State<QuizCorrectDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFFDE68A), width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              offset: Offset(0, 10),
              blurRadius: 26,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Linh vật nhảy múa ăn mừng
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: child,
                );
              },
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      offset: const Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/SketchTale_Mascot_Loading.webp',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/bobby-nhay.webp',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tiêu đề
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.celebration_rounded, color: Color(0xFFD97706), size: 24),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Bé Đã Về Đích Xuất Sắc!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF92400E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Lời chúc mừng
            Text(
              widget.celebrationMessage.isNotEmpty
                  ? widget.celebrationMessage
                  : 'Bé thật thông minh khi đã trả lời đúng tất cả câu đố!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.45,
                color: AppColors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 22),

            // Nút bấm: "ĐỌC TRUYỆN KHÁC" (khi là câu cuối) hoặc "CÂU TIẾP THEO"
            Squishy3DButton(
              onPressed: widget.onNext,
              height: 54,
              depth: 4.5,
              backgroundColor: const Color(0xFFF59E0B),
              bevelColor: const Color(0xFFD97706),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isLastQuestion
                        ? Icons.auto_stories_rounded
                        : Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isLastQuestion ? 'ĐỌC TRUYỆN KHÁC' : 'CÂU TIẾP THEO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            if (widget.isLastQuestion) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Chỉ đóng dialog, ở lại xem trang
                },
                child: const Text(
                  'Xem lại truyện vừa đọc',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
