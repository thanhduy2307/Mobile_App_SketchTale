import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../models/reading_log_quiz.dart';
import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/responsive.dart';

/// 🏆 Tab Thành Tích & Hành Trình Học Tập Của Bé
class CollectionAchievementsView extends StatelessWidget {
  final ChildProfile profile;
  final AppState state;
  final List<ReadingLogQuizSummary> quizHistory;

  const CollectionAchievementsView({
    super.key,
    required this.profile,
    required this.state,
    this.quizHistory = const [],
    List<CreditTransactionLog>? creditLogs,
    bool? isLoadingCreditLogs,
  });

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Center(
                  child: Icon(icon, size: 22, color: iconColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: iconColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard({
    required IconData icon,
    required String title,
    required String desc,
    required bool isUnlocked,
    required Color activeColor,
    required Color activeBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked ? activeBg : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked
              ? activeColor.withValues(alpha: 0.4)
              : AppColors.outlineVariant.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.white : AppColors.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked
                    ? activeColor.withValues(alpha: 0.6)
                    : AppColors.outlineVariant,
                width: 1.2,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 22,
                color: isUnlocked ? activeColor : AppColors.outline,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? activeColor.withValues(alpha: 0.15)
                            : AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isUnlocked ? 'Đã đạt' : 'Đang làm',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? activeColor : AppColors.outline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTypography.labelSm(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usedMinutes = state.screenTimeUsedToday;
    final totalMinutes = profile.dailyTimeLimit > 0 ? profile.dailyTimeLimit : 30;
    final remainingMinutes =
        (totalMinutes - usedMinutes).clamp(0, totalMinutes);
    final progress = (usedMinutes / totalMinutes).clamp(0.0, 1.0);

    // Tính toán các chỉ số học tập
    final completedStoriesCount = state.completedStories.length;
    final totalCorrectAnswers = quizHistory.fold<int>(
      0,
      (sum, q) => sum + q.totalCorrectAnswers,
    );
    final totalVocabulary =
        (completedStoriesCount * 6) + (totalCorrectAnswers * 2);

    final isTablet = Responsive.isTabletOrDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Thẻ Bảng Thống Kê Học Tập & Khám Phá Của Bé
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Thành Tích Học Tập & Khám Phá',
            style: AppTypography.headlineSm(color: AppColors.onSurface),
          ),
        ),

        // Grid 4 chỉ số thống kê
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isTablet ? 4 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isTablet ? 1.25 : 1.15,
          children: [
            // Ô 1: Truyện đã đọc hôm nay
            _buildStatCard(
              context: context,
              icon: Icons.auto_stories_rounded,
              value: '$completedStoriesCount',
              label: 'Truyện Đã Đọc',
              subtitle: 'Câu chuyện bổ ích',
              iconColor: const Color(0xFFD97706),
              backgroundColor: const Color(0xFFFFFBEB),
              borderColor: const Color(0xFFFCD34D),
            ),
            // Ô 2: Câu đố vượt qua
            _buildStatCard(
              context: context,
              icon: Icons.lightbulb_rounded,
              value: '$totalCorrectAnswers',
              label: 'Câu Đố Trả Lời Đúng',
              subtitle: 'Câu hỏi thông thái',
              iconColor: const Color(0xFF7C3AED),
              backgroundColor: const Color(0xFFF5F3FF),
              borderColor: const Color(0xFFDDD6FE),
            ),
            // Ô 3: Từ vựng tích lũy
            _buildStatCard(
              context: context,
              icon: Icons.spellcheck_rounded,
              value: '$totalVocabulary',
              label: 'Vốn Từ Vựng',
              subtitle: 'Từ ngữ mới học',
              iconColor: const Color(0xFF0284C7),
              backgroundColor: const Color(0xFFF0F9FF),
              borderColor: const Color(0xFFBAE6FD),
            ),
            // Ô 4: Thời gian đọc hôm nay
            _buildStatCard(
              context: context,
              icon: Icons.schedule_rounded,
              value: '$usedMinutes p',
              label: 'Thời Gian Đọc',
              subtitle: 'Phút khám phá hôm nay',
              iconColor: const Color(0xFF16A34A),
              backgroundColor: const Color(0xFFF0FDF4),
              borderColor: const Color(0xFFBBF7D0),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // 2. Thẻ Tiến Độ Mục Tiêu Đọc Sách Hôm Nay
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.emoji_events_rounded,
                            size: 20,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Mục Tiêu Đọc Sách Hôm Nay',
                        style: AppTypography.headlineSm(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$totalMinutes phút / ngày',
                      style: AppTypography.labelSm(
                        color: AppColors.onSecondaryFixed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                        ? const Color(0xFF16A34A)
                        : AppColors.secondary,
                  ),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đã đọc: $usedMinutes phút',
                    style: AppTypography.labelSm(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    remainingMinutes > 0
                        ? 'Còn lại: $remainingMinutes phút'
                        : 'Đã hoàn thành mục tiêu!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: remainingMinutes > 0
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  usedMinutes >= totalMinutes
                      ? 'Bé đã hoàn thành xuất sắc mục tiêu đọc sách hôm nay! Giỏi lắm!'
                      : (usedMinutes > 0
                          ? 'Bé đang chăm chỉ đọc sách rất tốt, cùng tiếp tục khám phá nhé!'
                          : 'Hãy chọn một câu chuyện kỳ diệu để bắt đầu chuyến phiêu lưu hôm nay!'),
                  style: AppTypography.bodySm(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 3. Thẻ Bộ Sưu Tập Huy Hiệu Khám Phá Của Bé
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Huy Hiệu Khám Phá Của Bé',
                    style: AppTypography.headlineSm(
                      color: AppColors.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${[
                        completedStoriesCount >= 1,
                        state.characters.isNotEmpty,
                        totalCorrectAnswers >= 1,
                        totalVocabulary >= 6,
                      ].where((b) => b).length}/4 Huy hiệu',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Column(
                children: [
                  _buildBadgeCard(
                    icon: Icons.explore_rounded,
                    title: 'Nhà Thám Hiểm Nhí',
                    desc: 'Đọc và hoàn thành câu chuyện đầu tiên',
                    isUnlocked: completedStoriesCount >= 1,
                    activeColor: const Color(0xFF0284C7),
                    activeBg: const Color(0xFFF0F9FF),
                  ),
                  const SizedBox(height: 10),
                  _buildBadgeCard(
                    icon: Icons.palette_rounded,
                    title: 'Hiệp Sĩ Sáng Tạo',
                    desc: 'Vẽ tranh và tạo hình bạn 3D đầu tiên',
                    isUnlocked: state.characters.isNotEmpty,
                    activeColor: const Color(0xFFD97706),
                    activeBg: const Color(0xFFFFFBEB),
                  ),
                  const SizedBox(height: 10),
                  _buildBadgeCard(
                    icon: Icons.psychology_rounded,
                    title: 'Thần Đồng Câu Đố',
                    desc: 'Vượt qua các câu hỏi đố vui sau câu chuyện',
                    isUnlocked: totalCorrectAnswers >= 1,
                    activeColor: const Color(0xFF7C3AED),
                    activeBg: const Color(0xFFF5F3FF),
                  ),
                  const SizedBox(height: 10),
                  _buildBadgeCard(
                    icon: Icons.auto_stories_rounded,
                    title: 'Kho Từ Vựng Nhí',
                    desc: 'Tích lũy từ 6 từ vựng mới qua các bài học',
                    isUnlocked: totalVocabulary >= 6,
                    activeColor: const Color(0xFF16A34A),
                    activeBg: const Color(0xFFF0FDF4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
