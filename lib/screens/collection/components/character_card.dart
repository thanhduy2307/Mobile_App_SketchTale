import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../collection_styles.dart';

/// Card hien thi ban nho 3D trong Tu Do cua be
class CharacterCard extends StatelessWidget {
  final KidCharacter character;
  final VoidCallback onPlaySound;
  final VoidCallback onRoleplay;
  final VoidCallback? onRename;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onPlaySound,
    required this.onRoleplay,
    this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = character.isParentApproved;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: CollectionStyles.characterCardDecoration(isApproved: isApproved),
      child: Row(
        children: [
          // Avatar 3D
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: character.avatar3dUrl.startsWith('assets/')
                ? Image.asset(
                    character.avatar3dUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    character.avatar3dUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    loadingBuilder: appImageLoadingBuilder,
                    errorBuilder: (_, _, _) => Container(
                      width: 90,
                      height: 90,
                      color: AppColors.primaryContainer,
                      child: const Icon(
                        Icons.cruelty_free_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Thông tin & Nút Đóng vai truyện
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? AppColors.primaryFixed
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    isApproved ? 'Ba Mẹ đã duyệt' : 'Ba Mẹ sắp duyệt',
                    style: AppTypography.labelSm(
                      color: isApproved
                          ? AppColors.onPrimaryFixed
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        character.name,
                        style: AppTypography.headlineSm(color: AppColors.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onRename != null)
                      GestureDetector(
                        onTap: onRename,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  character.title,
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Nút Đóng vai truyện
                Squishy3DButton(
                  height: 36,
                  depth: 2.5,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: isApproved
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerHigh,
                  bevelColor: isApproved
                      ? const Color(0xFFD97706)
                      : AppColors.surfaceDim,
                  onPressed: isApproved
                      ? onRoleplay
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Bé hãy nhờ Ba Mẹ duyệt nhân vật ${character.name} nhé.',
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          ),
                  child: Center(
                    child: Text(
                      isApproved ? 'Đóng vai truyện' : 'Chờ duyệt',
                      style: AppTypography.labelSm(
                        color: isApproved
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
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

