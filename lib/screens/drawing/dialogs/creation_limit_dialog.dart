import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// 🎨 Pop-up thông báo khi bé đã dùng hết số lượt tạo nhân vật trong ngày
/// Hiển thị linh vật hoạt họa đáng yêu cổ vũ bé và khuyến khích bé đi đọc truyện
class CreationLimitDialog extends StatefulWidget {
  final VoidCallback? onOpenLibrary;

  const CreationLimitDialog({
    super.key,
    this.onOpenLibrary,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onOpenLibrary,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CreationLimitDialog(
        onOpenLibrary: onOpenLibrary,
      ),
    );
  }

  @override
  State<CreationLimitDialog> createState() => _CreationLimitDialogState();
}

class _CreationLimitDialogState extends State<CreationLimitDialog>
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
            // Linh vật nhấp nhô vui nhộn kèm huy hiệu bảng màu
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
                  // Huy hiệu bảng màu vẽ
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
                        Icons.palette_rounded,
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
                Icon(Icons.palette_rounded, color: Color(0xFFD97706), size: 22),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Đạt Giới Hạn Tạo Hôm Nay!',
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

            // Lời nhắn ấm áp từ linh vật
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFEF3C7)),
              ),
              child: const Text(
                'Bé yêu ơi, hôm nay bé đã dùng hết số lượt tạo nhân vật mới rồi!\n\n'
                'Bé hãy cùng các bạn nhỏ 3D đã vẽ bước vào những câu chuyện kỳ diệu nhé. Ngày mai bút thần sẽ nạp đầy phép thuật để bé tạo tiếp bạn mới!',
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 13.5,
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 22),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFFCD34D), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Để Sau Nhé',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ),
                if (widget.onOpenLibrary != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onOpenLibrary?.call();
                      },
                      icon: const Icon(Icons.menu_book_rounded, size: 18, color: Colors.white),
                      label: const Text(
                        'Đi Đọc Truyện',
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

