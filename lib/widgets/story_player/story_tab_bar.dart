import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum StoryPlayerTab {
  reader, // 📖 Đọc Truyện
  vocabulary, // 📚 Từ Vựng
  quiz, // 🎯 Đố Vui
}

/// Compact & Playful Tab Switcher for Story Player with Animation Customizer CTA
class StoryTabBar extends StatelessWidget {
  final StoryPlayerTab activeTab;
  final ValueChanged<StoryPlayerTab> onTabChanged;
  final int vocabCount;
  final int quizCount;
  final VoidCallback? onOpenAnimationControls;

  const StoryTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.vocabCount,
    this.quizCount = 0,
    this.onOpenAnimationControls,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C001050),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(
            tab: StoryPlayerTab.reader,
            label: 'Đọc Truyện',
            icon: Icons.menu_book_rounded,
            color: AppColors.primary,
          ),
          _buildTabItem(
            tab: StoryPlayerTab.vocabulary,
            label: 'Từ Vựng',
            icon: Icons.translate_rounded,
            badge: '$vocabCount từ',
            color: const Color(0xFF0D9488),
          ),
          _buildTabItem(
            tab: StoryPlayerTab.quiz,
            label: 'Đố Vui',
            icon: Icons.quiz_rounded,
            badge: quizCount > 0 ? '$quizCount câu' : 'Nhận sao',
            color: const Color(0xFFF59E0B),
          ),
          if (onOpenAnimationControls != null)
            _buildActionButton(
              onPressed: onOpenAnimationControls!,
              label: 'Hoạt Họa',
              icon: Icons.auto_fix_high_rounded,
              badge: 'Tùy biến',
              color: const Color(0xFF8B5CF6),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    String? badge,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      style: AppTypography.labelMd(
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (badge != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required StoryPlayerTab tab,
    required String label,
    required IconData icon,
    String? badge,
    required Color color,
  }) {
    final isSelected = activeTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      style: AppTypography.labelMd(
                        color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (badge != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.black.withValues(alpha: 0.15)
                        : color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.onPrimary : color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
