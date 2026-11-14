import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../role_assignment_styles.dart';

/// 📖 Thẻ tóm tắt truyện cần gán vai
class RoleStorySummary extends StatelessWidget {
  final Story story;

  const RoleStorySummary({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RoleAssignmentStyles.summaryCardDecoration,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              story.coverUrl,
              width: 70,
              height: 85,
              fit: BoxFit.cover,
              loadingBuilder: appImageLoadingBuilder,
              errorBuilder: (_, _, _) => Container(
                width: 70,
                height: 85,
                color: AppColors.primaryContainer,
                child: const Icon(Icons.auto_stories_rounded, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        story.category,
                        style: AppTypography.labelSm(color: AppColors.onSecondaryFixed),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        '${story.totalPages} trang',
                        style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  story.title,
                  style: AppTypography.headlineMd(color: AppColors.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    'Cần: 1 Bạn Chính + 1 Bạn Đi Cùng',
                    style: AppTypography.labelSm(color: AppColors.secondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

