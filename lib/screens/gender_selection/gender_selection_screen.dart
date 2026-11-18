import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';

/// Man hinh Chon Khong Gian Be Trai / Be Gai
/// Xuat hien ngay sau khi dang nhap thanh cong.
/// Tuong thich hoan hao tren ca Dien thoai di dong va iPad/Tablet.
class GenderSelectionScreen extends StatefulWidget {
  final AppState appState;
  final ValueChanged<String> onThemeSelected;

  const GenderSelectionScreen({
    super.key,
    required this.appState,
    required this.onThemeSelected,
  });

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  String? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleSelect(String theme) {
    if (_selectedTheme != null) return;
    setState(() {
      _selectedTheme = theme;
    });

    // Hieu ung delay nhe de be nhin thay the duoc chon roi chuyen trang
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) {
        widget.onThemeSelected(theme);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isMobile = Responsive.isMobile(context);
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9EC),
      body: Stack(
        children: [
          // 1. Anh nen Background Full man hinh
          Positioned.fill(
            child: Image.asset(
              'assets/images/gender_select_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F2FE), Color(0xFFFFF7ED), Color(0xFFFCE7F3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // 2. Lop phu mo nhe giup noi bat the va chu
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.10),
            ),
          ),

          // 3. Nut Dang xuat / Doi tai khoan o goc tren phai
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            right: 16,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => widget.appState.logout(),
                  borderRadius: BorderRadius.circular(9999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Đăng xuất',
                          style: AppTypography.labelMd(
                            color: const Color(0xFF475569),
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Noi dung chinh responsive
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: isMobile ? 18 : 28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? 480 : 860,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header: Huy hieu chao mung
                        _buildHeader(context, isMobile),
                        SizedBox(height: isMobile ? 22 : 36),

                        // Cac the lua chon (Boy / Girl)
                        _buildThemeCards(context, isMobile, isLandscape),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 28,
        vertical: isMobile ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24F59E0B),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: const Color(0xFFFCD34D), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 6),
                Text(
                  'XỨ SỞ DIỆU KỲ SKETCHTALE',
                  style: AppTypography.labelSm(
                    color: const Color(0xFFB45309),
                  ).copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Chọn Không Gian Của Bé',
            textAlign: TextAlign.center,
            style: isMobile
                ? AppTypography.headlineLg(color: const Color(0xFF001050))
                : AppTypography.displayHero(color: const Color(0xFF001050)),
          ),
          const SizedBox(height: 6),
          Text(
            'Bé hãy chọn thế giới yêu thích để cùng khám phá những câu chuyện thần tiên nhé!',
            textAlign: TextAlign.center,
            style: isMobile
                ? AppTypography.bodySm(color: const Color(0xFF475569))
                : AppTypography.bodyMd(color: const Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCards(BuildContext context, bool isMobile, bool isLandscape) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Neu la iPad hoac man hinh rong: sap xep Row 2 the song song
    // Neu la Dien thoai dang doc: sap xep Column 2 the tren duoi
    final useRow = !isMobile || (isLandscape && screenWidth >= 540);

    if (useRow) {
      final cardWidth = math.min(320.0, (screenWidth - 100) / 2);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _GenderCard(
            title: 'Bé Trai',
            subtitle: 'Thế Giới Phiêu Lưu',
            tagline: 'Khám phá & Sáng tạo',
            imageAsset: 'assets/images/boy_card.png',
            primaryColor: const Color(0xFF0288D1),
            secondaryColor: const Color(0xFFE0F2FE),
            borderColor: const Color(0xFF38BDF8),
            isSelected: _selectedTheme == 'boy',
            width: cardWidth,
            onTap: () => _handleSelect('boy'),
          ),
          const SizedBox(width: 28),
          _GenderCard(
            title: 'Bé Gái',
            subtitle: 'Xứ Sở Diệu Kỳ',
            tagline: 'Ước mơ & Ngọt ngào',
            imageAsset: 'assets/images/girl_card.png',
            primaryColor: const Color(0xFFEC407A),
            secondaryColor: const Color(0xFFFCE7F3),
            borderColor: const Color(0xFFF472B6),
            isSelected: _selectedTheme == 'girl',
            width: cardWidth,
            onTap: () => _handleSelect('girl'),
          ),
        ],
      );
    }

    // Giao dien Dien thoai di dong (Mobile Portrait)
    final mobileCardWidth = math.min(screenWidth - 36, 340.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GenderCard(
          title: 'Bé Trai',
          subtitle: 'Thế Giới Phiêu Lưu',
          tagline: 'Khám phá & Sáng tạo',
          imageAsset: 'assets/images/boy_card.png',
          primaryColor: const Color(0xFF0288D1),
          secondaryColor: const Color(0xFFE0F2FE),
          borderColor: const Color(0xFF38BDF8),
          isSelected: _selectedTheme == 'boy',
          width: mobileCardWidth,
          isCompact: true,
          onTap: () => _handleSelect('boy'),
        ),
        const SizedBox(height: 18),
        _GenderCard(
          title: 'Bé Gái',
          subtitle: 'Xứ Sở Diệu Kỳ',
          tagline: 'Ước mơ & Ngọt ngào',
          imageAsset: 'assets/images/girl_card.png',
          primaryColor: const Color(0xFFEC407A),
          secondaryColor: const Color(0xFFFCE7F3),
          borderColor: const Color(0xFFF472B6),
          isSelected: _selectedTheme == 'girl',
          width: mobileCardWidth,
          isCompact: true,
          onTap: () => _handleSelect('girl'),
        ),
      ],
    );
  }
}

/// The lua chon khong gian (Boy hoac Girl)
class _GenderCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String tagline;
  final String imageAsset;
  final Color primaryColor;
  final Color secondaryColor;
  final Color borderColor;
  final bool isSelected;
  final double width;
  final bool isCompact;
  final VoidCallback onTap;

  const _GenderCard({
    required this.title,
    required this.subtitle,
    required this.tagline,
    required this.imageAsset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.borderColor,
    required this.isSelected,
    required this.width,
    this.isCompact = false,
    required this.onTap,
  });

  @override
  State<_GenderCard> createState() => _GenderCardState();
}

class _GenderCardState extends State<_GenderCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.isSelected
        ? 1.05
        : (_isPressed
            ? 0.97
            : (_isHovered
                ? 1.03
                : 1.0));

    final imageHeight = widget.isCompact ? 160.0 : 200.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutQuad,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: widget.isSelected || _isHovered
                    ? widget.primaryColor
                    : widget.borderColor,
                width: widget.isSelected || _isHovered ? 3.5 : 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withValues(
                    alpha: widget.isSelected || _isHovered ? 0.35 : 0.18,
                  ),
                  blurRadius: widget.isSelected || _isHovered ? 24 : 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hinh anh Dai dien khong gian
                  Container(
                    height: imageHeight,
                    color: widget.secondaryColor,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          widget.imageAsset,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.palette_rounded,
                              size: 48,
                              color: widget.primaryColor,
                            ),
                          ),
                        ),
                        // Badge the tren goc trai
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 15,
                                  color: widget.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.tagline,
                                  style: AppTypography.labelSm(
                                    color: widget.primaryColor,
                                  ).copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phan noi dung va nut bam
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isCompact ? 14 : 18,
                      vertical: widget.isCompact ? 14 : 18,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: AppTypography.headlineMd(
                            color: const Color(0xFF001050),
                          ).copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: AppTypography.bodySm(
                            color: const Color(0xFF64748B),
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),

                        // Nut bam hanh dong
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.primaryColor,
                                widget.primaryColor.withValues(alpha: 0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: widget.primaryColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Khám Phá Ngay',
                                style: AppTypography.labelLg(
                                  color: Colors.white,
                                ).copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

