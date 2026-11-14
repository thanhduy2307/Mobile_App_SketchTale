import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../role_assignment_styles.dart';

/// 🎭 Thẻ vị trí vai diễn (Nhân vật chính hoặc Bạn đồng hành)
class RoleSlotCard extends StatelessWidget {
  final String title;
  final String description;
  final KidCharacter? assignedCharacter;
  final StoryRoleTemplate? roleTemplate;
  final bool isTarget;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final VoidCallback onResetDefault;

  const RoleSlotCard({
    super.key,
    required this.title,
    required this.description,
    required this.assignedCharacter,
    required this.roleTemplate,
    required this.isTarget,
    required this.onTap,
    required this.onClear,
    required this.onResetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final hasChar = assignedCharacter != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: RoleAssignmentStyles.roleSlotDecoration(
          isTarget: isTarget,
          hasCharacter: hasChar,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Slot Title & Target Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isTarget ? AppColors.primary : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        title,
                        style: AppTypography.labelSm(
                          color: isTarget ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (isTarget) ...[
                      const SizedBox(width: 8),
                      Text(
                        'ĐANG CHỌN',
                        style: AppTypography.labelSm(color: AppColors.primary),
                      ),
                    ],
                  ],
                ),
                if (hasChar)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.outline,
                    onPressed: onClear,
                    tooltip: 'Hủy chọn',
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              roleTemplate?.roleName.isNotEmpty == true
                  ? 'Gán cho: ${roleTemplate!.roleName}'
                  : description,
              style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),

            // Slot Content
            if (hasChar)
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: assignedCharacter!.avatar3dUrl.startsWith('assets/')
                        ? Image.asset(
                            assignedCharacter!.avatar3dUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                          )
                        : Image.network(
                            assignedCharacter!.avatar3dUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            loadingBuilder: appImageLoadingBuilder,
                            errorBuilder: (_, _, _) => Container(
                              width: 64,
                              height: 64,
                              color: AppColors.primaryContainer,
                              child: const Icon(Icons.cruelty_free_rounded, color: Colors.white),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignedCharacter!.name,
                          style: AppTypography.headlineSm(color: AppColors.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          assignedCharacter!.title,
                          style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isTarget ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outline,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Text(
                    isTarget ? 'Chạm nhân vật bên dưới để gán' : 'Chạm để chọn vai này',
                    style: AppTypography.labelMd(
                      color: isTarget ? AppColors.primary : AppColors.outline,
                    ),
                  ),
                ),
              ),

            // Reset to default character if assigned
            if (hasChar) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onResetDefault,
                  child: Text(
                    'Dùng nhân vật mặc định',
                    style: AppTypography.labelSm(color: AppColors.secondary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

