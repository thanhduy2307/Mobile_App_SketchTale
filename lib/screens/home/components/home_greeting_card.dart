import 'package:flutter/material.dart';
import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';
import '../home_styles.dart';

/// 🌟 Lời chào & Huy hiệu tối giản của bé
class HomeGreetingCard extends StatelessWidget {
  final AppState state;

  const HomeGreetingCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: HomeStyles.greetingCardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFCD34D), width: 2),
                  ),
                  child: ClipOval(
                    child: state.childAvatarAsset.startsWith('http')
                        ? Image.network(
                            state.childAvatarAsset,
                            width: 52,
                            height: 52,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.child_care_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          )
                        : Image.asset(
                            state.childAvatarAsset,
                            width: 52,
                            height: 52,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.child_care_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chào ${state.kidName}!',
                        style: AppTypography.headlineMd(color: AppColors.onSurface).copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cùng bạn nhỏ đọc truyện và vẽ tranh nào!',
                        style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: const Color(0xFFFECACA), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFDC2626)),
                const SizedBox(width: 4),
                Text(
                  '${state.streakDays} ngày đọc',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
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

