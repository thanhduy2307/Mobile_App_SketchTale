import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';

/// 📖 Thẻ truyện bé đã hoàn thành
class CompletedStoryCard extends StatelessWidget {
  final String title;
  final String artist;
  final String imageUrl;
  final VoidCallback onReplay;

  const CompletedStoryCard({
    super.key,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE4E2DD),
            offset: Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              loadingBuilder: appImageLoadingBuilder,
              errorBuilder: (_, _, _) => Container(
                width: 72,
                height: 72,
                color: AppColors.primaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoàn thành 100%',
                  style: AppTypography.labelSm(color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Tranh vẽ bởi: $artist',
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ChunkyIconButton(
            size: 38,
            borderDepth: 2,
            backgroundColor: AppColors.surfaceContainerHigh,
            borderColor: AppColors.outlineVariant,
            icon: const Icon(
              Icons.replay_rounded,
              size: 20,
              color: AppColors.onSurface,
            ),
            onPressed: onReplay,
          ),
        ],
      ),
    );
  }
}

