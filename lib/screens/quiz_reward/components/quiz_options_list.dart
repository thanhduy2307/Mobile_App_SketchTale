import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

/// Danh Sach Dap An Do Vui Linh Hoat & Safe-to-Fail UX (Khong Phat Khi Sai)
/// - Tu dong co gian chieu cao theo do dai dap an (1 tu den ca cau dai)
/// - Can giua, chu to ro, khoang cach 14-16px chong bam nham
/// - Chon sai: Rung lac ngang (shake), hien bieu tuong sai ben trai (khong hien ben phai),
///   khong khoa o dap an va tiep tuc nhac be neu be bam lai o do
/// - Chon dung: Nay len (bounce), doi sang mau xanh la tuoi, tu dong chuyen cau sau 1.5s
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
          CurvedAnimation(parent: _bounceController, curve: Curves.easeOut),
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
    if (widget.correctSelectedIndex != null) return; // Da tra loi dung

    final isCorrect = (index == widget.correctIndex);

    if (isCorrect) {
      // CHON DUNG:
      setState(() {
        _bouncingIndex = index;
        _shakingIndex = null;
        _mascotFeedbackMessage = 'Tuyệt vời! Bé chọn đúng rồi!';
      });
      _bounceController.forward(from: 0.0);
      widget.onSelectOption(index);

      // Tu dong chuyen sang cau tiep theo sau 1.5 giay
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
      // CHON SAI (Khong khoa o; neu be chon lai van rung va nhac be):
      final alreadyTried = widget.disabledIndices.contains(index);
      setState(() {
        _shakingIndex = index;
        _mascotFeedbackMessage = alreadyTried
            ? 'Ô này chưa đúng đâu bé ơi, bé hãy thử chọn một đáp án khác nhé!'
            : 'Ối, thử ô khác xem sao! Bé làm được mà!';
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
    final isTriedWrong = widget.disabledIndices.contains(index);
    final isCorrect = (widget.correctSelectedIndex == index);
    final isShaking = (_shakingIndex == index);
    final isBouncing = (_bouncingIndex == index);

    // Xac dinh mau sac theo quy tac Safe-to-Fail UX (khong khoa o khi chon sai)
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isCorrect) {
      // Dung: Xanh la tuoi ruc ro
      backgroundColor = const Color(0xFFD1FAE5);
      borderColor = const Color(0xFF10B981);
      textColor = const Color(0xFF065F46);
    } else if (isTriedWrong) {
      // Da chon sai: Cam nhat nhe nhang, van mo de be co the bam lai
      backgroundColor = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFFED7AA);
      textColor = AppColors.onSurface;
    } else {
      // Binh thuong: Trang kem voi vien noi
      backgroundColor = AppColors.surfaceContainerLowest;
      borderColor = const Color(0xFFE2E8F0);
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
                : const Color(0x10001050),
            offset: const Offset(0, 4),
            blurRadius: isCorrect ? 10 : 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Huy hieu ben trai: Chi hien bieu tuong dung/sai hoac ky tu A, B, C, D o ben trai
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCorrect
                  ? const Color(0xFF10B981)
                  : (isTriedWrong
                        ? const Color(0xFFFFEDD5)
                        : const Color(0xFFFEF3C7)),
              border: Border.all(
                color: isCorrect
                    ? const Color(0xFF059669)
                    : (isTriedWrong
                          ? const Color(0xFFFB923C)
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
                  : (isTriedWrong
                        ? const Icon(
                            Icons.close_rounded,
                            color: Color(0xFFEA580C),
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

          // Noi dung chu cua dap an (Can giua, tu co gian theo chieu dai)
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

          // Khoang trong ben phai de giu chu o chinh giua (da bo toan bo icon ben phai)
          const SizedBox(width: 50),
        ],
      ),
    );

    // Boc hieu ung Rung Lac Ngang (Shake) neu chon sai
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

    // Boc hieu ung Nay Len (Bounce) neu chon dung
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
      onTap: () => _handleOptionTap(index),
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
              '1.5s',
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
