import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../library_styles.dart';

/// 📚 Thẻ hiển thị một câu chuyện trong Thư Viện
class StoryCard extends StatelessWidget {
  final StoryTemplate template;
  final int targetAgeGroup;
  final VoidCallback onTap;

  const StoryCard({
    super.key,
    required this.template,
    required this.targetAgeGroup,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = template.educationTheme;
    final rawTheme = theme?.name?.trim() ?? '';
    final themeName = rawTheme.isNotEmpty ? rawTheme : 'Khám Phá';
    final themeColor = LibraryStyles.getThemeColor(themeName);

    final rawDesc = template.description.trim();
    final displayDesc = rawDesc.isNotEmpty
        ? rawDesc
        : 'Cùng khám phá câu chuyện kỳ thú với những bài học bổ ích và thú vị dành cho bé.';

    final durationMinutes = (template.totalPageNumbers * 2).clamp(3, 15);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: LibraryStyles.storyCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh truyện với huy hiệu số trang & thời lượng
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1.25,
                    child: Image.network(
                      template.fullCoverUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: appImageLoadingBuilder,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.surfaceContainer,
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),

                // Góc dưới trái: Thời lượng đọc
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.outline, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$durationMinutes phút',
                          style: AppTypography.labelSm(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Góc dưới phải: Số trang
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.outline, width: 0.8),
                    ),
                    child: Text(
                      '${template.totalPageNumbers} trang',
                      style: AppTypography.labelSm(color: AppColors.onSurface),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 2. Thẻ Chủ Đề Giáo Dục
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: themeColor.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                themeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: themeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // 3. Tên Truyện (Title)
            Text(
              template.title,
              style: AppTypography.headlineSm(color: AppColors.onSurface)
                  .copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // 4. Mô Tả Truyện (Description)
            Expanded(
              child: Text(
                displayDesc,
                style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // 5. Nút Đọc Ngay Nổi Bật Dành Cho Bé
            Squishy3DButton.primary(
              height: 38,
              depth: 2.5,
              onPressed: onTap,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 16,
                    color: AppColors.onPrimary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Đọc Truyện',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onPrimary,
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
}
