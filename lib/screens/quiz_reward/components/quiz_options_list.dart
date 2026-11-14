import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

/// 🔠 Danh Sách Đáp Án Đố Vui Linh Hoạt & Safe-to-Fail UX (Không Phạt Khi Sai)
/// - Tự động co giãn chiều cao theo độ dài đáp án (1 từ đến cả câu dài)
/// - Căn giữa, chữ to rõ, khoảng cách 14-16px chống bấm nhầm
/// - Chọn sai: Rung lắc ngang (shake), đổi sang màu cam nhạt/xám mờ, vô hiệu hóa thẻ và hiện linh vật nhắc nhở
/// - Chọn đúng: Nảy lên (bounce), đổi sang màu xanh lá tươi, bắn hiệu ứng ngôi sao và tự động chuyển câu sau 1.5s
class QuizOptionsList extends StatefulWidget {
  final List<QuizOptionDetail> optionDetails;
  final int correctIndex;
  final Set<int> disabledIndices;
  final int? correctSelectedIndex;
  final ValueChanged<int> onSelectOption;
  final VoidCallback onAutoNext;
  final int? selectedIndex;
  final ValueChanged<String>? onPlayOptionSound;

  const QuizOptionsList({
    super.key,
    required this.optionDetails,
    required this.correctIndex,
    required this.disabledIndices,
    this.correctSelectedIndex,
    required this.onSelectOption,
    required this.onAutoNext,
    this.selectedIndex,
    this.onPlayOptionSound,
  });

  @override
  State<QuizOptionsList> createState() => _QuizOptionsListState();
}

class _QuizOptionsListState extends State<QuizOptionsList>
    with TickerProviderStateMixin {
  int? _shakingIndex;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  int? _bouncingIndex;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  String? _mascotFeedbackMessage;
  Timer? _autoNextTimer;

  @override
  void initState() {
    super.initState();

    // Controller hiệu ứng rung lắc ngang (Shake Animation)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 10.0, end: -7.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 7.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    // Controller hiệu ứng nảy lên (Bounce Animation)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _bounceAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.96), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _bounceController, curve: Curves.easeOutBack),
        );
  }

  @override
  void dispose() {
    _autoNextTimer?.cancel();
    _shakeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleOptionTap(int index) {
    if (widget.disabledIndices.contains(index)) return;
    if (widget.correctSelectedIndex != null) return; // Đã trả lời đúng

    final isCorrect = (index == widget.correctIndex);

    if (isCorrect) {
      // CHỌN ĐÚNG:
      setState(() {
        _bouncingIndex = index;
        _shakingIndex = null;
        _mascotFeedbackMessage = 'Tuyệt vời! Bé chọn đúng rồi!';
      });
      _bounceController.forward(from: 0.0);
      widget.onSelectOption(index);

      // Tự động chuyển sang câu tiếp theo sau 1.5 giây
      _autoNextTimer?.cancel();
      _autoNextTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _bouncingIndex = null;
            _mascotFeedbackMessage = null;
          });
          widget.onAutoNext();
        }
      });
    } else {
      // CHỌN SAI (Safe-to-Fail UX):
      setState(() {
        _shakingIndex = index;
        _mascotFeedbackMessage = 'Ối, thử ô khác xem sao! Bé làm được mà!';
      });
      _shakeController.forward(from: 0.0);
      widget.onSelectOption(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Danh sách các thẻ đáp án (tối thiểu 14px-16px giữa các thẻ)
        for (int i = 0; i < widget.optionDetails.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          _buildOptionCard(i),
        ],

        // Khung thông điệp động viên từ Linh Vật khi bé chọn
        if (_mascotFeedbackMessage != null) ...[
          const SizedBox(height: 16),
          _buildMascotEncouragementBanner(),
        ],
      ],
    );
  }

  Widget _buildOptionCard(int index) {
    final opt = widget.optionDetails[index];
    final isDisabled = widget.disabledIndices.contains(index);
    final isCorrect = (widget.correctSelectedIndex == index);
    final isShaking = (_shakingIndex == index);
    final isBouncing = (_bouncingIndex == index);

    // Xác định màu sắc theo quy tắc Safe-to-Fail UX
    Color backgroundColor;
    Color borderColor;
    Color bevelColor;
    Color textColor;

    if (isCorrect) {
      // Đúng: Xanh lá tươi rực rỡ
      backgroundColor = const Color(0xFFD1FAE5);
      borderColor = const Color(0xFF10B981);
      bevelColor = const Color(0xFF059669);
      textColor = const Color(0xFF065F46);
    } else if (isDisabled) {
      // Sai: Cam nhạt/xám mờ nhẹ nhàng, không dùng đỏ đậm
      backgroundColor = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFFED7AA);
      bevelColor = const Color(0xFFFDBA74);
      textColor = const Color(0xFF9CA3AF);
    } else {
      // Bình thường: Trắng kem với viền nổi 3D
      backgroundColor = AppColors.surfaceContainerLowest;
      borderColor = const Color(0xFFE2E8F0);
      bevelColor = const Color(0xFFCBD5E1);
      textColor = AppColors.onSurface;
    }

    Widget cardContent = Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: isCorrect
                ? const Color(0x3510B981)
                : (isDisabled ? Colors.transparent : const Color(0x10001050)),
            offset: const Offset(0, 4),
            blurRadius: isCorrect ? 10 : 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Huy hiệu ký tự (A, B, C, D)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCorrect
                  ? const Color(0xFF10B981)
                  : (isDisabled
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFFFEF3C7)),
              border: Border.all(
                color: isCorrect
                    ? const Color(0xFF059669)
                    : (isDisabled
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFFF59E0B)),
                width: 1.5,
              ),
            ),
            child: Center(
              child: isCorrect
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : (isDisabled
                        ? const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF94A3B8),
                            size: 18,
                          )
                        : Text(
                            opt.letter,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF92400E),
                            ),
                          )),
            ),
          ),

          const SizedBox(width: 14),

          // Nội dung chữ của đáp án (Căn giữa, tự co giãn theo chiều dài)
          Expanded(
            child: Text(
              opt.title.replaceAll(RegExp(r'^[A-D]\.\s*'), ''),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Icon hiệu ứng khi đúng hoặc sai
          if (isCorrect) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 24,
            ),
          ] else if (isDisabled) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.replay_rounded,
              color: Color(0xFFFB923C),
              size: 18,
            ),
          ] else ...[
            const SizedBox(width: 8),
            const SizedBox(width: 18), // Giữ cân đối căn lề giữa
          ],
        ],
      ),
    );

    // Bọc hiệu ứng Rung Lắc Ngang (Shake) nếu chọn sai
    if (isShaking) {
      cardContent = AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: cardContent,
      );
    }

    // Bọc hiệu ứng Nảy Lên (Bounce) nếu chọn đúng
    if (isBouncing) {
      cardContent = AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _bounceAnimation.value, child: child);
        },
        child: cardContent,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled ? null : () => _handleOptionTap(index),
      child: cardContent,
    );
  }

  /// Banner linh vật hiện lên động viên bé khi chọn sai hoặc chúc mừng khi chọn đúng
  Widget _buildMascotEncouragementBanner() {
    final bool isCorrect = (widget.correctSelectedIndex != null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Image.asset(
              'assets/images/SketchTale_Mascot_Loading.webp',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/bobby-chinh-dien.webp',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _mascotFeedbackMessage ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isCorrect
                    ? const Color(0xFF065F46)
                    : const Color(0xFF92400E),
              ),
            ),
          ),
          if (isCorrect)
            const Text(
              '1.5s ⏳',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF059669),
              ),
            ),
        ],
      ),
    );
  }
}
