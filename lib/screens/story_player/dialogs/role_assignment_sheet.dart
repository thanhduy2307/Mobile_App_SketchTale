import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../story_player_styles.dart';

/// 🎭 BottomSheet: Gán nhân vật của bé vào vai diễn trong truyện
/// Cho phép bé chọn bạn nhỏ (phải được Ba Mẹ duyệt) để đóng vai chính hoặc bạn đồng hành,
/// hoặc quay về mẫu nhân vật gốc của Content Manager (CM).
class RoleAssignmentSheet extends StatefulWidget {
  final AppState appState;
  final Story story;
  final List<StoryRoleTemplate> storyRoles;
  final List<UserStoryCharacterMapping> storyMappings;
  final void Function(String msg) onShowToast;
  final VoidCallback onRolesChanged;

  const RoleAssignmentSheet({
    super.key,
    required this.appState,
    required this.story,
    required this.storyRoles,
    required this.storyMappings,
    required this.onShowToast,
    required this.onRolesChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required AppState appState,
    required Story story,
    required List<StoryRoleTemplate> storyRoles,
    required List<UserStoryCharacterMapping> storyMappings,
    required void Function(String msg) onShowToast,
    required VoidCallback onRolesChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoleAssignmentSheet(
        appState: appState,
        story: story,
        storyRoles: storyRoles,
        storyMappings: storyMappings,
        onShowToast: onShowToast,
        onRolesChanged: onRolesChanged,
      ),
    );
  }

  @override
  State<RoleAssignmentSheet> createState() => _RoleAssignmentSheetState();
}

class _RoleAssignmentSheetState extends State<RoleAssignmentSheet> {
  KidCharacter? _resolveMappedKidCharacter(StoryRoleTemplate role) {
    // 1. Kiem tra mapping theo roleId truc tiep tu appState cho dung vai nay
    final fromState = widget.appState.getMappedCharacterForRole(
      widget.story.id,
      role.id,
    );
    if (fromState != null && fromState.isParentApproved) return fromState;

    // 2. Kiem tra mapping tu may chu cho dung vai nay
    for (final m in widget.storyMappings) {
      if (m.isApproved &&
          m.storyRoleTemplateId.toLowerCase() == role.id.toLowerCase()) {
        for (final c in widget.appState.characters) {
          if (c.id == m.characterId && c.isParentApproved) return c;
        }
      }
    }

    // Neu vai nay chua duoc gan rieng, tra ve null de he thong tu dong lay anh goc tu CM
    return null;
  }

  Widget _buildRoleAssignmentItem(StoryRoleTemplate role) {
    final mappedChar = _resolveMappedKidCharacter(role);
    final isRoleMapped = mappedChar != null;
    final directlyMapped = widget.appState.getMappedCharacterForRole(
      widget.story.id,
      role.id,
    );
    final isDirectlyMapped = directlyMapped != null && directlyMapped.isParentApproved;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: StoryPlayerStyles.roleCardDecoration(isRoleMapped: isRoleMapped),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: StoryPlayerStyles.roleBadgeDecoration,
                    child: Text(
                      role.storyRoleType == StoryRoleType.mainCharacter
                          ? 'Vai chính'
                          : 'Bạn đồng hành',
                      style: AppTypography.labelSm(color: AppColors.secondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    role.roleName,
                    style: AppTypography.headlineSm(color: AppColors.onSurface),
                  ),
                ],
              ),
              if (isRoleMapped)
                TextButton.icon(
                  onPressed: () {
                    widget.appState.clearRoleMapping(widget.story.id, role.id);
                    if (role.storyRoleType == StoryRoleType.mainCharacter) {
                      widget.appState.assignHeroCharacter(null);
                    } else if (role.storyRoleType == StoryRoleType.companion) {
                      widget.appState.assignCompanionCharacter(null);
                    }
                    setState(() {});
                    widget.onRolesChanged();
                    widget.onShowToast(
                      'Đã chuyển vai "${role.roleName}" về nhân vật gốc của truyện.',
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text('Nhân vật gốc', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isRoleMapped
                ? 'Bạn nhỏ đang đóng vai: ${mappedChar.name}'
                : 'Đang dùng: Mẫu nhân vật gốc từ Content Manager (CM)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isRoleMapped ? FontWeight.bold : FontWeight.normal,
              color: isRoleMapped ? AppColors.secondary : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),

          // Danh sách bạn nhỏ của bé
          if (widget.appState.approvedCharacters.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Chưa có nhân vật nào được Ba Mẹ duyệt. Bé hãy nhờ Ba Mẹ duyệt nhân vật ở Tủ Đồ nhé.',
                style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            )
          else ...[
            Text(
              'Chọn bạn nhỏ của bé vào vai này:',
              style: AppTypography.labelSm(color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.appState.approvedCharacters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final char = widget.appState.approvedCharacters[idx];
                  final isAssignedHere = mappedChar?.id == char.id;
                  final isApproved = char.isParentApproved;

                  return GestureDetector(
                    onTap: () {
                      if (!isApproved) {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Row(
                              children: [
                                Icon(Icons.hourglass_empty_rounded, size: 18, color: Color(0xFFD97706)),
                                SizedBox(width: 6),
                                Text('Chờ Ba Mẹ Duyệt', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            content: Text(
                              'Bạn nhỏ "${char.name}" đang chờ Ba Mẹ duyệt. Bé hãy nhờ Ba Mẹ duyệt trước khi mang bạn vào kể chuyện nhé.',
                              style: const TextStyle(fontSize: 13),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(c).pop(),
                                child: const Text('Đã hiểu'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      // Neu ban nho nay da duoc gan cho vai khac trong truyen, go vai cu ve mac dinh CM
                      for (final otherRole in widget.storyRoles) {
                        if (otherRole.id != role.id) {
                          final otherAssigned = widget.appState.getMappedCharacterForRole(
                            widget.story.id,
                            otherRole.id,
                          );
                          if (otherAssigned != null && otherAssigned.id == char.id) {
                            widget.appState.clearRoleMapping(widget.story.id, otherRole.id);
                          }
                        }
                      }

                      // Gán vai
                      widget.appState.assignCharacterRole(
                        storyId: widget.story.id,
                        storyRoleTemplateId: role.id,
                        characterId: char.id,
                      );
                      if (role.storyRoleType == StoryRoleType.mainCharacter) {
                        widget.appState.assignHeroCharacter(char);
                      } else if (role.storyRoleType == StoryRoleType.companion) {
                        widget.appState.assignCompanionCharacter(char);
                      }
                      setState(() {});
                      widget.onRolesChanged();
                      widget.onShowToast(
                        'Đã chọn bạn "${char.name}" vào vai "${role.roleName}".',
                      );
                    },
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isAssignedHere
                            ? AppColors.secondaryFixedDim.withValues(alpha: 0.3)
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isAssignedHere
                              ? AppColors.secondary
                              : (isApproved
                                  ? AppColors.outlineVariant
                                  : const Color(0xFFFCD34D)),
                          width: isAssignedHere ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: char.avatar3dUrl.startsWith('assets/')
                                      ? Image.asset(
                                          char.avatar3dUrl,
                                          fit: BoxFit.contain,
                                        )
                                      : Image.network(
                                          char.avatar3dUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: appImageLoadingBuilder,
                                          errorBuilder: (_, _, _) => const Icon(
                                            Icons.cruelty_free_rounded,
                                            size: 28,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                ),
                                if (!isApproved)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.lock_clock_rounded,
                                        color: Colors.amber,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            char.name,
                            style: AppTypography.labelSm(
                              color: isAssignedHere
                                  ? AppColors.secondary
                                  : AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isAssignedHere
                                ? 'Đang chọn'
                                : (isApproved ? 'Chọn bạn' : 'Chờ duyệt'),
                            style: TextStyle(
                              fontSize: 9.5,
                              color: isAssignedHere
                                  ? AppColors.secondary
                                  : (isApproved
                                      ? AppColors.onSurfaceVariant
                                      : const Color(0xFFB45309)),
                              fontWeight: isAssignedHere
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: StoryPlayerStyles.bottomSheetDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh gạt modal
          Center(child: StoryPlayerStyles.sheetDragHandle),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.theater_comedy_rounded, size: 22, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text(
                    'Hóa Thân Nhân Vật Vào Truyện',
                    style: StoryPlayerStyles.sheetTitle,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Text(
            'Bé có thể chọn người bạn nhỏ đáng yêu để cùng đóng vai trong truyện, hoặc giữ nguyên nhân vật của câu chuyện nhé.',
            style: StoryPlayerStyles.sheetSubtitle,
          ),
          const SizedBox(height: 14),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                if (widget.storyRoles.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Câu chuyện này không có vai diễn tùy biến nào.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  for (final role in widget.storyRoles) ...[
                    _buildRoleAssignmentItem(role),
                    const SizedBox(height: 14),
                  ],
              ],
            ),
          ),

          const SizedBox(height: 10),
          // Nút hành động phía dưới
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.appState.resetRoleMappingsForStory(widget.story.id);
                    setState(() {});
                    widget.onRolesChanged();
                    widget.onShowToast(
                      'Đã đặt lại nhân vật nguyên bản của câu chuyện.',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Nhân Vật Gốc Của Truyện',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Đọc Truyện Tiếp',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

