import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../role_assignment_styles.dart';

/// 🎨 Tủ nhân vật của bé để chọn gán vai
class RoleCharacterShelf extends StatelessWidget {
  final AppState state;
  final bool isTablet;
  final void Function(KidCharacter character) onSelectCharacter;

  const RoleCharacterShelf({
    super.key,
    required this.state,
    required this.isTablet,
    required this.onSelectCharacter,
  });

  Widget _buildCharacterItem(KidCharacter character) {
    final isHero = state.heroCharacter?.id == character.id;
    final isCompanion = state.companionCharacter?.id == character.id;
    final isAssigned = isHero || isCompanion;

    return GestureDetector(
      onTap: () => onSelectCharacter(character),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: RoleAssignmentStyles.characterCardDecoration.copyWith(
          border: isAssigned ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: character.avatar3dUrl.startsWith('assets/')
                  ? Image.asset(
                      character.avatar3dUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.contain,
                    )
                  : Image.network(
                      character.avatar3dUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      loadingBuilder: appImageLoadingBuilder,
                      errorBuilder: (_, _, _) => Container(
                        width: 58,
                        height: 58,
                        color: AppColors.primaryContainer,
                        child: const Icon(Icons.cruelty_free_rounded, color: Colors.white),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        character.name,
                        style: AppTypography.headlineSm(color: AppColors.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (character.isParentApproved) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.accentMintDark,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    character.title,
                    style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isAssigned) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        isHero ? 'Đang là Bạn Chính' : 'Đang là Bạn Đi Cùng',
                        style: AppTypography.labelSm(color: AppColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final characters = state.characters;

    if (characters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Bé chưa có nhân vật nào! Hãy vẽ bạn mới ở xưởng vẽ nhé.',
            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (isTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: characters.length,
        itemBuilder: (_, index) => _buildCharacterItem(characters[index]),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: characters.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _buildCharacterItem(characters[index]),
    );
  }
}

