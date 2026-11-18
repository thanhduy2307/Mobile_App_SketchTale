import 'package:flutter/material.dart';
import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';
import '../home_styles.dart';

/// Loi chao cua be tren Trang Chu
class HomeGreetingCard extends StatelessWidget {
  final AppState state;

  const HomeGreetingCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: HomeStyles.greetingCardDecoration,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFCD34D), width: 1.8),
            ),
            child: ClipOval(
              child: state.childAvatarAsset.startsWith('http')
                  ? Image.network(
                      state.childAvatarAsset,
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.child_care_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    )
                  : Image.asset(
                      state.childAvatarAsset,
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.child_care_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chào ${state.kidName}!',
                  style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Cùng bạn nhỏ đọc truyện và vẽ tranh nào!',
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant).copyWith(
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

