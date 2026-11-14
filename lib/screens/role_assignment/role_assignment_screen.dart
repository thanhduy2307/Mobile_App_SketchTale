import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_loading.dart';
import 'components/role_character_shelf.dart';
import 'components/role_slot_card.dart';
import 'components/role_step_instruction.dart';
import 'components/role_story_summary.dart';
import 'role_assignment_controller.dart';

export 'role_assignment_controller.dart';
export 'role_assignment_styles.dart';

/// Màn hình Phân Vai Nhân Vật Vào Truyện (RoleAssignmentScreen)
/// Lấy toàn bộ vai diễn do Content Manager (CM) thiết lập.
/// Bé có thể chọn bạn nhỏ để gán vào từng vai, nếu không đủ bạn nhỏ thì hệ thống tự động lấy mặc định của CM.
class RoleAssignmentScreen extends StatefulWidget {
  final AppState appState;

  const RoleAssignmentScreen({
    super.key,
    required this.appState,
  });

  @override
  State<RoleAssignmentScreen> createState() => _RoleAssignmentScreenState();
}

class _RoleAssignmentScreenState extends State<RoleAssignmentScreen> {
  late final RoleAssignmentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RoleAssignmentController();
    _controller.addListener(() => setState(() {}));
    _controller.loadStoryRoles(
      storyId: widget.appState.currentStory.id,
      token: widget.appState.authToken,
      storyTitle: widget.appState.currentStory.title,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final story = state.currentStory;
    final isTablet = Responsive.isTabletOrDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        leading: ChunkyIconButton(
          size: 40,
          borderDepth: 3,
          backgroundColor: AppColors.surfaceContainer,
          borderColor: const Color(0xFFD6C4AC),
          icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Phân Vai Nhân Vật',
          style: AppTypography.headlineMd(color: AppColors.primary),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${state.stars}',
                  style: AppTypography.labelMd(color: AppColors.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ResponsiveContainer(
          padding: Responsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Tóm tắt truyện & Hướng dẫn
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: RoleStorySummary(
                        story: story,
                        rolesCount: _controller.storyRoles.length,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(flex: 2, child: RoleStepInstruction()),
                  ],
                )
              else ...[
                RoleStorySummary(
                  story: story,
                  rolesCount: _controller.storyRoles.length,
                ),
                const SizedBox(height: 14),
                const RoleStepInstruction(),
              ],
              const SizedBox(height: 18),

              // 2. Danh sách toàn bộ các vai diễn do CM thiết lập
              if (_controller.isLoadingRoles)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: AppLoadingLogo(size: 48),
                  ),
                )
              else
                _buildRoleSlotsList(state, isTablet),
              const SizedBox(height: 22),

              // 3. Tiêu đề tủ đồ nhân vật
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Kho Bạn Bè Của Bé',
                        style: AppTypography.headlineMd(color: AppColors.onSurface),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          '${state.approvedCharacters.length} bạn',
                          style: AppTypography.labelSm(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Danh sách nhân vật bé vẽ
              RoleCharacterShelf(
                state: state,
                isTablet: isTablet,
                controller: _controller,
                onSelectCharacter: (char) => _controller.assignCharacterToTargetSlot(
                  context: context,
                  state: state,
                  character: char,
                ),
              ),

              const SizedBox(height: 26),

              // 5. Nút Khởi hành chuyến phiêu lưu
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isTablet ? 500 : double.infinity),
                  child: Squishy3DButton.primary(
                    height: 58,
                    depth: 5,
                    onPressed: () => _controller.startStory(context, state),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_stories_rounded, size: 24, color: AppColors.onPrimary),
                        const SizedBox(width: 10),
                        Text(
                          'Bắt Đầu Chuyến Phiêu Lưu',
                          style: AppTypography.headlineSm(color: AppColors.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSlotsList(AppState state, bool isTablet) {
    final roles = _controller.storyRoles;

    if (roles.isEmpty) {
      // Fallback khi chua co du lieu
      return isTablet
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSlotCardForIndex(state, 0, null)),
                const SizedBox(width: 16),
                Expanded(child: _buildSlotCardForIndex(state, 1, null)),
              ],
            )
          : Column(
              children: [
                _buildSlotCardForIndex(state, 0, null),
                const SizedBox(height: 14),
                _buildSlotCardForIndex(state, 1, null),
              ],
            );
    }

    if (isTablet && roles.length > 1) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 16) / 2;
          return Wrap(
            spacing: 16,
            runSpacing: 14,
            children: [
              for (var i = 0; i < roles.length; i++)
                SizedBox(
                  width: itemWidth > 320 ? itemWidth : constraints.maxWidth,
                  child: _buildSlotCardForIndex(state, i, roles[i]),
                ),
            ],
          );
        },
      );
    }

    return Column(
      children: [
        for (var i = 0; i < roles.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          _buildSlotCardForIndex(state, i, roles[i]),
        ],
      ],
    );
  }

  Widget _buildSlotCardForIndex(AppState state, int index, StoryRoleTemplate? role) {
    final effectiveRole = role ??
        (index < _controller.storyRoles.length ? _controller.storyRoles[index] : null);

    final assignedChar = effectiveRole != null
        ? _controller.getAssignedCharacterForRole(state, effectiveRole, index)
        : (index == 0 ? state.heroCharacter : state.companionCharacter);

    final roleName = effectiveRole?.roleName ??
        (index == 0 ? 'Bạn Chính' : (index == 1 ? 'Bạn Đi Cùng' : 'Vai Diễn ${index + 1}'));

    final title = 'VAI ${index + 1}: ${roleName.toUpperCase()}';

    final desc = effectiveRole?.description.isNotEmpty == true
        ? effectiveRole!.description
        : (index == 0
            ? 'Nhân vật dẫn dắt câu chuyện cổ tích'
            : 'Người bạn trung thành sẻ chia mọi khó khăn');

    return RoleSlotCard(
      title: title,
      description: desc,
      assignedCharacter: assignedChar,
      roleTemplate: effectiveRole,
      isTarget: _controller.targetSlotIndex == index,
      onTap: () => _controller.setTargetSlot(index),
      onClear: () {
        if (effectiveRole != null) {
          _controller.resetRoleToDefault(state: state, role: effectiveRole, index: index);
        } else {
          if (index == 0) state.assignHeroCharacter(null);
          if (index == 1) state.assignCompanionCharacter(null);
        }
      },
      onResetDefault: () {
        if (effectiveRole != null) {
          _controller.resetRoleToDefault(state: state, role: effectiveRole, index: index);
        } else {
          if (index == 0) state.assignHeroCharacter(null);
          if (index == 1) state.assignCompanionCharacter(null);
        }
      },
    );
  }
}
