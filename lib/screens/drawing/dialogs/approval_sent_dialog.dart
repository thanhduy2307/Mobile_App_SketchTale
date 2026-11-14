import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

/// 💌 Hộp thoại thông báo khi nhân vật đã được gửi lên cho Ba Mẹ phê duyệt thành công
/// Hiển thị linh vật vui nhộn chúc mừng và hai lựa chọn: Vẽ thêm tranh hoặc Xem kho của bé
class ApprovalSentDialog extends StatefulWidget {
  final KidCharacter character;
  final VoidCallback onDrawMore;
  final VoidCallback onOpenCollection;

  const ApprovalSentDialog({
    super.key,
    required this.character,
    required this.onDrawMore,
    required this.onOpenCollection,
  });

  static Future<void> show(
    BuildContext context, {
    required KidCharacter character,
    required VoidCallback onDrawMore,
    required VoidCallback onOpenCollection,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ApprovalSentDialog(
        character: character,
        onDrawMore: onDrawMore,
        onOpenCollection: onOpenCollection,
      ),
    );
  }

  @override
  State<ApprovalSentDialog> createState() => _ApprovalSentDialogState();
}

class _ApprovalSentDialogState extends State<ApprovalSentDialog>
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
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOutSine),
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
            // Linh vật nhấp nhô vui nhộn kèm huy hiệu thư
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
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: 0.35),
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
                  // Huy hiệu thư gửi ba mẹ
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
                        Icons.mark_email_read_rounded,
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
                Icon(
                  Icons.celebration_rounded,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Đã Gửi Cho Ba Mẹ Duyệt!',
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

            // Lời nhắn ấm áp (Đã bỏ hoàn toàn +10 Sao)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFEF3C7)),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 13.5,
                    height: 1.55,
                  ),
                  children: [
                    const TextSpan(text: 'Bạn nhỏ '),
                    TextSpan(
                      text: '"${widget.character.name}"',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' siêu đáng yêu đã được gửi tới Ba Mẹ để duyệt.\n\n'
                          'Khi Ba Mẹ duyệt xong, bé sẽ được mang bạn vào cùng phiêu lưu trong truyện nhé!',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDrawMore();
                    },
                    icon: const Icon(
                      Icons.palette_rounded,
                      size: 18,
                      color: Color(0xFFD97706),
                    ),
                    label: const Text(
                      'Vẽ Thêm Tranh',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFFCD34D),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onOpenCollection();
                    },
                    icon: const Icon(
                      Icons.backpack_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Xem Kho Của Bé',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
