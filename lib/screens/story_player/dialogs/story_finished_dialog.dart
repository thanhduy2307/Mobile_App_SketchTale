import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../story_player_styles.dart';

/// 🎉 Dialog Chúc Mừng Bé Đọc Xong Truyện Kèm Linh Vật & Nút Chuyển Sang Quiz
class StoryFinishedDialog extends StatefulWidget {
  final String storyTitle;
  final VoidCallback onOpenQuizReward;
  final VoidCallback? onOpenAnimationControls;

  const StoryFinishedDialog({
    super.key,
    required this.storyTitle,
    required this.onOpenQuizReward,
    this.onOpenAnimationControls,
  });

  static Future<void> show(
    BuildContext context, {
    required String storyTitle,
    required VoidCallback onOpenQuizReward,
    VoidCallback? onOpenAnimationControls,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => StoryFinishedDialog(
        storyTitle: storyTitle,
        onOpenQuizReward: onOpenQuizReward,
        onOpenAnimationControls: onOpenAnimationControls,
      ),
    );
  }

  @override
  State<StoryFinishedDialog> createState() => _StoryFinishedDialogState();
}

class _StoryFinishedDialogState extends State<StoryFinishedDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: -12.0).animate(
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
              color: Color(0x30F59E0B),
              offset: Offset(0, 8),
              blurRadius: 28,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Linh vật nhảy múa chúc mừng
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: child,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
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
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/images/SketchTale_Mascot_Loading.webp',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/bobby-nhay.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: -6,
                    right: -8,
                    child: Icon(Icons.star_rounded, size: 28, color: Color(0xFFF59E0B)),
                  ),
                  const Positioned(
                    top: 10,
                    left: -10,
                    child: Icon(Icons.auto_awesome_rounded, size: 24, color: Color(0xFF10B981)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Tiêu đề chúc mừng
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.celebration_rounded, color: Color(0xFFD97706), size: 22),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Hoan Hô Bé Đã Đọc Xong!',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF92400E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Lời thoại chúc mừng của linh vật
            Text(
              'Bé thật tuyệt vời khi đã hoàn thành cuốn truyện "${widget.storyTitle}"!\nGiờ chúng mình cùng thử tài Đố Vui để xem bé nhớ câu chuyện đến đâu nhé!',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 22),

            // Nút Chuyển Sang Trả Lời Quiz
            Squishy3DButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onOpenQuizReward();
              },
              height: 54,
              depth: 4.5,
              backgroundColor: const Color(0xFFF59E0B),
              bevelColor: const Color(0xFFD97706),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'CÙNG CHƠI ĐỐ VUI THÔI NÀO!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Nút ở lại đọc tiếp
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Bé muốn ở lại xem tiếp trang này',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
