import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../home_styles.dart';

/// 📖 Thẻ Hero Đọc Tiếp Nè (Quick-Play 1 chạm cho bé)
/// Hiển thị linh hoạt 3 trạng thái:
/// 1. Đã hoàn thành: "BÉ ĐÃ ĐỌC XONG 🎉" -> "ĐỌC LẠI TRUYỆN 🔄"
/// 2. Đang đọc dở: "BÉ ĐỌC TIẾP NHÉ 📖" -> "VÀO ĐỌC TIẾP NGAY ▶"
/// 3. Truyện mới: "GỢI Ý HÔM NAY ✨" -> "BẮT ĐẦU ĐỌC TRUYỆN 📚"
class HomeHeroStoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;
  final bool? isCompleted;

  const HomeHeroStoryCard({
    super.key,
    required this.story,
    required this.onTap,
    this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final bool completed = isCompleted ?? story.isCompleted;
    final int safeTotalPages = story.totalPages > 0 ? story.totalPages : 3;
    final int safeCurrentPage = story.currentPage.clamp(1, safeTotalPages);
    final bool isReadingInProgress = !completed && safeCurrentPage > 1;

    final String badgeText;
    final Color badgeColor;
    final String subtitleText;
    final String buttonText;
    final IconData buttonIcon;
    final BoxDecoration cardDecoration;
    final Color titleColor;
    final Color subtitleColor;

    if (completed) {
      badgeText = 'BÉ ĐÃ ĐỌC XONG';
      badgeColor = const Color(0xFF10B981);
      subtitleText = 'Đã hoàn thành 100% • Bé có thể đọc lại bất cứ lúc nào!';
      buttonText = 'ĐỌC LẠI TRUYỆN NÀY';
      buttonIcon = Icons.replay_rounded;
      cardDecoration = HomeStyles.heroCompletedCardDecoration;
      titleColor = const Color(0xFF065F46);
      subtitleColor = const Color(0xFF047857);
    } else if (isReadingInProgress) {
      badgeText = 'BÉ ĐỌC TIẾP NHÉ';
      badgeColor = const Color(0xFFF59E0B);
      subtitleText = 'Đang đọc trang $safeCurrentPage/$safeTotalPages • Cùng bạn ${story.characterName}';
      buttonText = 'VÀO ĐỌC TIẾP NGAY';
      buttonIcon = Icons.play_circle_fill_rounded;
      cardDecoration = HomeStyles.heroContinueCardDecoration;
      titleColor = const Color(0xFF78350F);
      subtitleColor = const Color(0xFFB45309);
    } else {
      badgeText = 'GỢI Ý HÔM NAY';
      badgeColor = const Color(0xFFF59E0B);
      subtitleText = story.subtitle.trim().isNotEmpty
          ? '${story.subtitle} • $safeTotalPages trang'
          : 'Câu chuyện kỳ diệu • Cùng bạn ${story.characterName}';
      buttonText = 'BẮT ĐẦU ĐỌC TRUYỆN';
      buttonIcon = Icons.auto_stories_rounded;
      cardDecoration = HomeStyles.heroContinueCardDecoration;
      titleColor = const Color(0xFF78350F);
      subtitleColor = const Color(0xFFB45309);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 86,
                    height: 86,
                    child: Image.network(
                      story.coverUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: appImageLoadingBuilder,
                      errorBuilder: (_, _, _) => Container(
                        color: completed
                            ? const Color(0xFFA7F3D0)
                            : AppColors.primaryContainer,
                        child: Icon(
                          completed
                              ? Icons.check_circle_rounded
                              : Icons.auto_stories_rounded,
                          color: completed
                              ? const Color(0xFF059669)
                              : Colors.white,
                          size: 36,
                        ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        story.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitleText,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Squishy3DButton(
              onPressed: onTap,
              height: 52,
              depth: 4.5,
              backgroundColor: completed ? const Color(0xFF10B981) : AppColors.primary,
              bevelColor: completed ? const Color(0xFF047857) : AppColors.primaryBevel,
              foregroundColor: AppColors.onPrimary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(buttonIcon, color: AppColors.onPrimary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
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
    );
  }
}
