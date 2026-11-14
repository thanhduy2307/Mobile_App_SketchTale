import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Kid-friendly, Extra-Large 3D Squishy Navigation Bar for Story Player (Designed for Kids 6+)
/// Tối ưu hóa trải nghiệm lật trang mượt mà, trực quan cho bé.
class StoryPlayerBottomBar extends StatelessWidget {
  final int currentPageIndex;
  final int totalPages;
  final bool isPlayingAudio;
  final VoidCallback? onToggleAudio;
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;
  final VoidCallback? onFinishStory;
  final ValueChanged<int>? onPageSelect;

  const StoryPlayerBottomBar({
    super.key,
    required this.currentPageIndex,
    required this.totalPages,
    this.isPlayingAudio = false,
    this.onToggleAudio,
    required this.onPrevPage,
    required this.onNextPage,
    this.onFinishStory,
    this.onPageSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPrev = currentPageIndex > 0;
    final bool hasNext = currentPageIndex < totalPages - 1;
    final int safeTotalPages = totalPages > 0 ? totalPages : 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.outline, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12001050),
            offset: Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Nút Trang Trước: To rõ, dễ bấm cho ngón tay của bé
          Expanded(
            flex: 4,
            child: Squishy3DButton(
              onPressed: hasPrev ? onPrevPage : null,
              height: 56,
              depth: hasPrev ? 4.0 : 1.0,
              backgroundColor: hasPrev
                  ? const Color(0xFFE0F2FE)
                  : AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
              bevelColor: hasPrev
                  ? const Color(0xFFBAE6FD)
                  : Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    color: hasPrev
                        ? const Color(0xFF0284C7)
                        : AppColors.onSurfaceVariant.withValues(alpha: 0.35),
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Trước',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: hasPrev
                            ? const Color(0xFF0284C7)
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.35),
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 2. Trung Tâm: Bộ Hiển Thị & Chọn Trang Trực Quan Cho Bé (Thay thế nút Nghe Đọc)
          Expanded(
            flex: 4,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dòng nhãn số trang
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Trang ${currentPageIndex + 1}/$safeTotalPages',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Dãy chấm trang tương tác (Bé có thể chạm để nhảy trang)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < safeTotalPages; i++)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onPageSelect != null
                                ? () => onPageSelect!(i)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.5),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: (i == currentPageIndex) ? 16 : 7,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: (i == currentPageIndex)
                                      ? const Color(0xFFF59E0B)
                                      : (i < currentPageIndex)
                                          ? const Color(0xFF0284C7)
                                          : const Color(0xFFCBD5E1),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 3. Nút Trang Tiếp Theo / Hoàn Thành: Nổi bật nhất cho bé bấm khám phá tiếp
          Expanded(
            flex: 5,
            child: Squishy3DButton(
              onPressed: hasNext ? onNextPage : onFinishStory,
              height: 56,
              depth: 4.5,
              backgroundColor: hasNext
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF10B981),
              bevelColor: hasNext
                  ? const Color(0xFFD97706)
                  : const Color(0xFF059669),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      hasNext ? 'Trang Tiếp' : 'Đọc Xong',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    hasNext
                        ? Icons.arrow_forward_rounded
                        : Icons.star_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
