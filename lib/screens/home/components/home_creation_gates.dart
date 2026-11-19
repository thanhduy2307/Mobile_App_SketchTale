import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../home_styles.dart';

/// Cong vao Khong Gian Sang Tao va Thu Vien Truyen
class HomeCreationGates extends StatelessWidget {
  final bool isTablet;
  final VoidCallback onOpenDrawing;
  final VoidCallback onOpenLibrary;

  const HomeCreationGates({
    super.key,
    required this.isTablet,
    required this.onOpenDrawing,
    required this.onOpenLibrary,
  });

  Widget _buildDrawGateCard() {
    final imageSize = isTablet ? 180.0 : 112.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onOpenDrawing,
        child: Container(
          constraints: BoxConstraints(
            minHeight: isTablet ? 280 : 190,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 28 : 18,
            vertical: isTablet ? 36 : 20,
          ),
          decoration: HomeStyles.drawGateCardDecoration,
          child: Row(
            children: [
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 2.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18F59E0B),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(
                    'assets/images/rabbit.webp',
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.palette_rounded,
                      color: AppColors.primary,
                      size: 54,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 26 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: const Color(0xFFFCD34D), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.brush_rounded,
                            size: 14,
                            color: Color(0xFF946000),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'HOẠT ĐỘNG CHÍNH',
                            style: AppTypography.labelSm(
                              color: const Color(0xFF946000),
                            ).copyWith(
                              fontSize: isTablet ? 12.5 : 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      'Bé Vẽ Tranh & Hóa Thân',
                      style: AppTypography.headlineMd(color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: isTablet ? 26 : 19.5,
                      ),
                    ),
                    SizedBox(height: isTablet ? 10 : 5),
                    Text(
                      'Biến nét vẽ thành nhân vật và bước vào thế giới truyện tranh kỳ diệu',
                      style: AppTypography.bodySm(color: AppColors.onSurfaceVariant).copyWith(
                        fontSize: isTablet ? 15.5 : 13.0,
                        height: 1.45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 24 : 14),
                    Squishy3DButton.primary(
                      onPressed: onOpenDrawing,
                      height: isTablet ? 60 : 48,
                      depth: 5.5,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.palette_rounded,
                            size: 21,
                            color: AppColors.onPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'VẼ TRANH NGAY',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: isTablet ? 16.5 : 14.5,
                              color: AppColors.onPrimary,
                              letterSpacing: 0.5,
                            ),
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
    );
  }

  Widget _buildStoryGateCard() {
    final imageSize = isTablet ? 180.0 : 112.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onOpenLibrary,
        child: Container(
          constraints: BoxConstraints(
            minHeight: isTablet ? 280 : 190,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 28 : 18,
            vertical: isTablet ? 36 : 20,
          ),
          decoration: HomeStyles.storyGateCardDecoration,
          child: Row(
            children: [
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFBAE6FD), width: 2.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x180288D1),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(
                    'assets/images/bobby-chinh-dien.webp',
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.secondary,
                      size: 54,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 26 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: const Color(0xFF7DD3FC), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_stories_rounded,
                            size: 14,
                            color: Color(0xFF0288D1),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'KHO TRUYỆN CỔ TÍCH',
                            style: AppTypography.labelSm(
                              color: const Color(0xFF0288D1),
                            ).copyWith(
                              fontSize: isTablet ? 12.5 : 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      'Mở Một Câu Chuyện',
                      style: AppTypography.headlineMd(color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: isTablet ? 26 : 19.5,
                      ),
                    ),
                    SizedBox(height: isTablet ? 10 : 5),
                    Text(
                      'Khám phá thế giới cổ tích kỳ diệu cùng giọng đọc ấm áp và truyền cảm',
                      style: AppTypography.bodySm(color: AppColors.onSurfaceVariant).copyWith(
                        fontSize: isTablet ? 15.5 : 13.0,
                        height: 1.45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 24 : 14),
                    Squishy3DButton.cyan(
                      onPressed: onOpenLibrary,
                      height: isTablet ? 60 : 48,
                      depth: 5.5,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            size: 21,
                            color: AppColors.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MỞ THƯ VIỆN',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: isTablet ? 16.5 : 14.5,
                              color: AppColors.onSurface,
                              letterSpacing: 0.5,
                            ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Không Gian Sáng Tạo',
          style: AppTypography.headlineLg(color: AppColors.onSurface).copyWith(
            fontWeight: FontWeight.w900,
            fontSize: isTablet ? 25 : 20,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        if (isTablet)
          Row(
            children: [
              Expanded(child: _buildDrawGateCard()),
              const SizedBox(width: 18),
              Expanded(child: _buildStoryGateCard()),
            ],
          )
        else
          Column(
            children: [
              _buildDrawGateCard(),
              const SizedBox(height: 14),
              _buildStoryGateCard(),
            ],
          ),
      ],
    );
  }
}

