import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../collection_styles.dart';

/// 🌟 Header thông tin hồ sơ của bé (Avatar, Sao, Streak, Credits, Lượt tạo)
class CollectionHeroHeader extends StatelessWidget {
  final ChildProfile profile;
  final AppState state;
  final bool isRefreshing;
  final Future<void> Function() onRefresh;

  const CollectionHeroHeader({
    super.key,
    required this.profile,
    required this.state,
    required this.isRefreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: CollectionStyles.heroHeaderDecoration,
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline, width: 1.5),
            ),
            child: ClipOval(
              child: state.childAvatarAsset.startsWith('http')
                  ? Image.network(
                      state.childAvatarAsset,
                      width: 68,
                      height: 68,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(
                          Icons.account_circle_rounded,
                          size: 40,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    )
                  : Image.asset(
                      state.childAvatarAsset,
                      width: 68,
                      height: 68,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(
                          Icons.account_circle_rounded,
                          size: 40,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Name, Level & Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        profile.nickName,
                        style: AppTypography.headlineLg(color: AppColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: isRefreshing ? null : onRefresh,
                      icon: isRefreshing
                          ? const AppLoadingLogo(size: 22)
                          : const Icon(
                              Icons.sync_rounded,
                              color: AppColors.secondary,
                              size: 22,
                            ),
                      tooltip: 'Đồng bộ từ Ba Mẹ',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Không gian sáng tạo và khám phá truyện kỳ diệu',
                  style: AppTypography.bodySm(
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
}

