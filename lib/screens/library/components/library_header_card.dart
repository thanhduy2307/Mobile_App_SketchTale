import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../library_styles.dart';

/// 📚 Header Card hiển thị tiêu đề thư viện và số lượng câu chuyện
class LibraryHeaderCard extends StatelessWidget {
  final String? avatarAsset;
  final int totalStories;
  final Future<void> Function() onRefresh;

  const LibraryHeaderCard({
    super.key,
    this.avatarAsset,
    required this.totalStories,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = avatarAsset ?? 'assets/images/child-avatars/child-01.png';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: LibraryStyles.headerCardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outline,
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: avatar.startsWith('http')
                      ? Image.network(
                          avatar,
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        )
                      : Image.asset(
                          avatar,
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THƯ VIỆN CÂU CHUYỆN',
                    style: AppTypography.labelSm(
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kho Truyện Của Bé',
                    style: AppTypography.headlineSm(
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    '$totalStories câu chuyện bổ ích',
                    style: AppTypography.bodySm(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(
              Icons.sync_rounded,
              color: AppColors.secondary,
              size: 22,
            ),
            tooltip: 'Tải lại thư viện',
          ),
        ],
      ),
    );
  }
}

