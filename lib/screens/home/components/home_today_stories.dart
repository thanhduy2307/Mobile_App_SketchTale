import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/app_loading.dart';
import '../home_styles.dart';

/// Muc Truyen Doc Hom Nay (Thiet ke nho gon, vua van tam mat)
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
    required bool isTablet,
  }) {
    final imageHeight = isTablet ? 115.0 : 92.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onStorySelected(story),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: HomeStyles.todayStoryCardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image with time pill
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: Image.network(
                        story.coverUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: appImageLoadingBuilder,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.surfaceContainer,
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppColors.outline, width: 0.8),
                      ),
                      child: Text(
                        '$durationMinutes phút',
                        style: AppTypography.labelSm(color: AppColors.onSurface).copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                story.title,
                style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(
                  fontSize: isTablet ? 15.5 : 14.0,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'Đồng hành cùng bé',
                        style: AppTypography.labelSm(color: AppColors.onSurfaceVariant).copyWith(
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Squishy3DButton(
                    onPressed: () => onStorySelected(story),
                    width: 32,
                    height: 32,
                    padding: EdgeInsets.zero,
                    backgroundColor: accentColor,
                    bevelColor: bevelColor,
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.onPrimary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gợi Ý Truyện Hôm Nay',
              style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(
                fontWeight: FontWeight.w800,
                fontSize: isTablet ? 17 : 15,
              ),
            ),
            TextButton(
              onPressed: onOpenLibrary,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLowest,
                side: const BorderSide(color: AppColors.outline, width: 1.0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              ),
              child: Text(
                'Xem tất cả',
                style: AppTypography.labelSm(color: AppColors.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTodayStoryCard(
                context: context,
                story: story1,
                accentColor: AppColors.primaryContainer,
                bevelColor: const Color(0xFFD97706),
                durationMinutes: story1.durationMinutes,
                isTablet: isTablet,
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
                isTablet: isTablet,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

