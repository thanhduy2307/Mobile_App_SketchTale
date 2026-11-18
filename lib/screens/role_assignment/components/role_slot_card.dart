import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/character_cutout_image.dart';
import '../role_assignment_styles.dart';

/// The vi tri vai dien trong truyen
/// Hien thi thong tin vai dien tu Content Manager (CM).
/// Neu be da gan ban nho: hien thi nhan vat be ve.
/// Neu chua gan ban nho (khong du ban nho): tu dong lay mac dinh cua CM.
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

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: 58,
      height: 58,
      color: AppColors.secondaryFixed,
      child: const Icon(Icons.theater_comedy_rounded, color: AppColors.onSecondaryFixed),
    );
  }

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
                    tooltip: 'Quay lại mặc định',
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              roleTemplate?.roleName.isNotEmpty == true
                  ? 'Gán cho vai: ${roleTemplate!.roleName}'
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
                    child: CharacterCutoutImage(
                      imageUrl: assignedCharacter!.avatar3dUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                      errorFallbackBuilder: () => Container(
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                assignedCharacter!.name,
                                style: AppTypography.headlineSm(color: AppColors.onSurface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                'Bé vẽ',
                                style: AppTypography.labelSm(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
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
              // Trang thai chua gan: Tu dong lay mac dinh cua CM
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isTarget ? AppColors.primary : AppColors.outlineVariant,
                    width: isTarget ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: (roleTemplate != null && roleTemplate!.fullDefaultAssetUrl.isNotEmpty)
                          ? CharacterCutoutImage(
                              imageUrl: roleTemplate!.fullDefaultAssetUrl,
                              width: 58,
                              height: 58,
                              fit: BoxFit.contain,
                              errorFallbackBuilder: _buildDefaultPlaceholder,
                            )
                          : _buildDefaultPlaceholder(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  roleTemplate?.roleName.isNotEmpty == true
                                      ? roleTemplate!.roleName
                                      : 'Nhân vật gốc',
                                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  'Mặc định CM',
                                  style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isTarget
                                ? 'Chạm bạn nhỏ bên dưới nếu muốn thay đổi vai này'
                                : 'Đang dùng nhân vật gốc của truyện (CM)',
                            style: AppTypography.bodySm(
                              color: isTarget ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Reset to default character if assigned
            if (hasChar) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onResetDefault,
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: Text(
                    'Quay lại mặc định của CM',
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
