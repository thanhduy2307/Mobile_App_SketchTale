import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../library_styles.dart';

/// 📖 BottomSheet Thần Tiên: Cho bé chọn cách đọc truyện (Phương án 2)
/// Thay thế hoàn toàn thuật ngữ kỹ thuật "Mẫu Tác Giả CM" và "Gán nhân vật"
/// bằng 2 Thẻ Phiêu Lưu trực quan, sinh động dành riêng cho trẻ em.
class StoryOptionsSheet extends StatelessWidget {
  final StoryTemplate template;
  final VoidCallback onReadStory;
  final VoidCallback onAssignRoles;
  final KidCharacter? heroCharacter;
  final bool hasCharacters;

  const StoryOptionsSheet({
    super.key,
    required this.template,
    required this.onReadStory,
    required this.onAssignRoles,
    this.heroCharacter,
    this.hasCharacters = false,
  });

  static Future<void> show(
    BuildContext context, {
    required StoryTemplate template,
    required VoidCallback onReadStory,
    required VoidCallback onAssignRoles,
    KidCharacter? heroCharacter,
    bool hasCharacters = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StoryOptionsSheet(
        template: template,
        onReadStory: onReadStory,
        onAssignRoles: onAssignRoles,
        heroCharacter: heroCharacter,
        hasCharacters: hasCharacters,
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color borderColor,
    required Widget leadingIcon,
    required String title,
    required Color titleColor,
    required String subtitle,
    required Color subtitleColor,
    required Color arrowColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              leadingIcon,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: arrowColor,
                  ),
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
    final theme = template.educationTheme;
    final rawTheme = theme?.name?.trim() ?? '';
    final themeName = rawTheme.isNotEmpty ? rawTheme : 'Khám Phá';
    final themeColor = LibraryStyles.getThemeColor(themeName);
    final durationMinutes = (template.totalPageNumbers * 2).clamp(3, 15);

    final rawDesc = template.description.trim();
    final displayDesc = rawDesc.isNotEmpty
        ? rawDesc
        : 'Cùng mở câu chuyện kỳ diệu và bước vào hành trình phiêu lưu thật bổ ích nhé!';

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFFCD34D), width: 1.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  offset: Offset(0, 10),
                  blurRadius: 28,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Thanh gạt & Nút Đóng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 36),
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: AppColors.outline,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Đóng',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 2. Thông tin Câu Chuyện (Bìa + Tên + Badge)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 86,
                        height: 108,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          border: Border.all(
                            color: const Color(0xFFFCD34D).withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                        ),
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.title,
                            style: AppTypography.headlineSm(
                              color: AppColors.onSurface,
                            ).copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: themeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: themeColor.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  themeName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${template.totalPageNumbers} trang • $durationMinutes phút',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayDesc,
                            style: AppTypography.bodySm(
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 3. Tiêu đề chọn chế độ
                Row(
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      size: 18,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Bé hãy chọn cách đọc truyện nhé:',
                      style: AppTypography.labelMd(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. Thẻ 1: Đọc Truyện Cổ Tích (Bản Gốc Tác Giả)
                _buildModeCard(
                  context: context,
                  onTap: onReadStory,
                  backgroundColor: const Color(0xFFFFFBEB),
                  borderColor: const Color(0xFFFCD34D),
                  title: 'Đọc Truyện Cổ Tích',
                  titleColor: const Color(0xFF92400E),
                  subtitle: 'Lắng nghe câu chuyện nguyên bản cùng giọng đọc ấm áp',
                  subtitleColor: const Color(0xFFB45309),
                  arrowColor: const Color(0xFFD97706),
                  leadingIcon: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFCD34D),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 26,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 5. Thẻ 2: Hóa Thân Vào Truyện (Đưa bạn 3D vào)
                _buildModeCard(
                  context: context,
                  onTap: onAssignRoles,
                  backgroundColor: const Color(0xFFF0F9FF),
                  borderColor: const Color(0xFFBAE6FD),
                  title: 'Hóa Thân Vào Truyện',
                  titleColor: const Color(0xFF0369A1),
                  subtitle: (heroCharacter != null && heroCharacter!.name.isNotEmpty)
                      ? 'Cùng bạn ${heroCharacter!.name} bước vào câu chuyện'
                      : 'Đưa bạn nhỏ của bé trở thành nhân vật chính phiêu lưu',
                  subtitleColor: const Color(0xFF0284C7),
                  arrowColor: const Color(0xFF0284C7),
                  leadingIcon: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFBAE6FD),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: (heroCharacter != null &&
                              heroCharacter!.avatarAsset.isNotEmpty)
                          ? (heroCharacter!.avatarAsset.startsWith('http')
                              ? Image.network(
                                  heroCharacter!.avatarAsset,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 24,
                                    color: Color(0xFF0284C7),
                                  ),
                                )
                              : Image.asset(
                                  heroCharacter!.avatarAsset,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 24,
                                    color: Color(0xFF0284C7),
                                  ),
                                ))
                          : const Center(
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 24,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
