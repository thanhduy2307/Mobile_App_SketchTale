import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../home_styles.dart';

/// 📚 Mục Truyện Đọc Hôm Nay
class HomeTodayStories extends StatelessWidget {
  final String? childAgeGroupLabel;
  final Story story1;
  final Story story2;
  final ValueChanged<Story> onStorySelected;
  final VoidCallback onOpenLibrary;

  const HomeTodayStories({
    super.key,
    this.childAgeGroupLabel,
    required this.story1,
    required this.story2,
    required this.onStorySelected,
    required this.onOpenLibrary,
  });

  Widget _buildTodayStoryCard({
    required BuildContext context,
    required Story story,
    required Color accentColor,
    required Color bevelColor,
    required int durationMinutes,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onStorySelected(story),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: HomeStyles.todayStoryCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with time pill
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: Image.network(
                      story.coverUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: appImageLoadingBuilder,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.surfaceContainer,
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: AppColors.outline, width: 0.8),
                    ),
                    child: Text(
                      '$durationMinutes phút',
                      style: AppTypography.labelSm(color: AppColors.onSurface),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              story.title,
              style: AppTypography.headlineSm(color: AppColors.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Đồng hành cùng bé',
                      style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Squishy3DButton(
                  onPressed: () => onStorySelected(story),
                  width: 36,
                  height: 36,
                  padding: EdgeInsets.zero,
                  backgroundColor: accentColor,
                  bevelColor: bevelColor,
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.onPrimary,
                    size: 20,
                  ),
                ),
              ],
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Truyện Đọc Hôm Nay',
                    style: AppTypography.headlineMd(color: AppColors.onSurface),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onOpenLibrary,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLowest,
                side: const BorderSide(color: AppColors.outline, width: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              ),
              child: Text(
                'Xem tất cả',
                style: AppTypography.labelSm(color: AppColors.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTodayStoryCard(
                context: context,
                story: story1,
                accentColor: AppColors.primaryContainer,
                bevelColor: const Color(0xFFD97706),
                durationMinutes: story1.durationMinutes,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildTodayStoryCard(
                context: context,
                story: story2,
                accentColor: AppColors.secondaryContainer,
                bevelColor: const Color(0xFF006398),
                durationMinutes: story2.durationMinutes,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

