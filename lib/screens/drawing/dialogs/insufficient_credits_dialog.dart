import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// 🪙 Hộp thoại thông báo khi số dư credits của Phụ huynh không đủ để biến hình AI
/// Hiển thị linh vật hoạt họa đáng yêu nhắc nhở bé và ba mẹ
class InsufficientCreditsDialog extends StatefulWidget {
  final int requiredCredits;
  final int currentCredits;

  const InsufficientCreditsDialog({
    super.key,
    required this.requiredCredits,
    required this.currentCredits,
  });

  static Future<void> show(
    BuildContext context, {
    required int requiredCredits,
    required int currentCredits,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => InsufficientCreditsDialog(
        requiredCredits: requiredCredits,
        currentCredits: currentCredits,
      ),
    );
  }

  @override
  State<InsufficientCreditsDialog> createState() =>
      _InsufficientCreditsDialogState();
}

class _InsufficientCreditsDialogState extends State<InsufficientCreditsDialog>
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
        constraints: const BoxConstraints(maxWidth: 400),
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
            // Linh vật nhấp nhô vui nhộn kèm huy hiệu đồng xu
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
                          blurRadius: 18,
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
                  // Huy hiệu đồng xu Credits
                  Positioned(
                    bottom: 0,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.monetization_on_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Lấp lánh ma thuật
                  const Positioned(
                    top: -4,
                    left: -4,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 24,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Tiêu đề
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 22),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Ba Mẹ Ơi, Cần Thêm Credits!',
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
            const SizedBox(height: 14),

            // Thẻ thông điệp chi tiết
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFEF3C7)),
              ),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                      children: [
                        const TextSpan(text: 'Tính năng biến hình kỳ diệu cần '),
                        TextSpan(
                          text: '${widget.requiredCredits} credits',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const TextSpan(text: ', số dư hiện tại của Ba Mẹ là '),
                        TextSpan(
                          text: '${widget.currentCredits} credits',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const TextSpan(
                          text:
                              '.\n\nBé hãy nhờ Ba Mẹ nạp thêm gói credits để bút thần tiếp tục thổi hồn 3D cho các bức vẽ nhé!',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Nút xác nhận
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                label: const Text(
                  'Dạ Vâng, Bé Đã Hiểu!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
