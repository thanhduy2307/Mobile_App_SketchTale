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
    final thumbSize = isTablet ? 78.0 : 66.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onStorySelected(story),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 10,
            vertical: isTablet ? 10 : 8,
          ),
          decoration: HomeStyles.todayStoryCardDecoration,
          child: Row(
            children: [
              // Anh bia vuong nho gon ben trai - Hien thi tron ven nhan vat khong bi cat
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  color: const Color(0xFFFDF8EE),
                  child: Image.network(
                    story.coverUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    loadingBuilder: appImageLoadingBuilder,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.surfaceContainer,
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 14 : 10),
              // Thong tin truyen o giua
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      story.title,
                      style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(
                        fontSize: isTablet ? 16.0 : 14.0,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: const Color(0xFFFCD34D), width: 0.8),
                          ),
                          child: Text(
                            '$durationMinutes phút',
                            style: AppTypography.labelSm(color: const Color(0xFF92400E)).copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            'Đồng hành cùng bé',
                            style: AppTypography.labelSm(color: AppColors.onSurfaceVariant).copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Nut Play 3D ben phai
              Squishy3DButton(
                onPressed: () => onStorySelected(story),
                width: isTablet ? 38 : 34,
                height: isTablet ? 38 : 34,
                padding: EdgeInsets.zero,
                backgroundColor: accentColor,
                bevelColor: bevelColor,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.onPrimary,
                  size: isTablet ? 22 : 18,
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

