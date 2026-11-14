import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../home_styles.dart';

/// 🎨 Cổng vào Không Gian Sáng Tạo & Thư Viện Truyện
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
    return GestureDetector(
      onTap: onOpenDrawing,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: HomeStyles.gateCardDecoration,
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/rabbit.webp',
                  width: 76,
                  height: 76,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.palette_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'SÁNG TẠO NHÂN VẬT',
                      style: AppTypography.labelSm(color: const Color(0xFF946000)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bé Vẽ Tranh & Hóa Thân',
                    style: AppTypography.headlineSm(color: AppColors.onSurface),
                  ),
                  Text(
                    'Biến nét vẽ thành nhân vật và bước vào truyện',
                    style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Squishy3DButton.primary(
                    onPressed: onOpenDrawing,
                    height: 44,
                    depth: 3.5,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    child: const Text(
                      'VẼ TRANH NGAY',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryGateCard() {
    return GestureDetector(
      onTap: onOpenLibrary,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: HomeStyles.gateCardDecoration,
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/bobby-chinh-dien.webp',
                  width: 76,
                  height: 76,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.secondary,
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'THƯ VIỆN TRUYỆN',
                      style: AppTypography.labelSm(color: AppColors.secondary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mở Một Câu Chuyện',
                    style: AppTypography.headlineSm(color: AppColors.onSurface),
                  ),
                  Text(
                    'Khám phá thế giới cổ tích cùng giọng đọc ấm áp',
                    style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Squishy3DButton.cyan(
                    onPressed: onOpenLibrary,
                    height: 44,
                    depth: 3.5,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    child: const Text(
                      'MỞ THƯ VIỆN',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Không Gian Sáng Tạo',
              style: AppTypography.headlineMd(color: AppColors.onSurface),
            ),
            Text(
              'Mỗi nét vẽ, một câu chuyện',
              style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isTablet)
          Row(
            children: [
              Expanded(child: _buildDrawGateCard()),
              const SizedBox(width: 16),
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

