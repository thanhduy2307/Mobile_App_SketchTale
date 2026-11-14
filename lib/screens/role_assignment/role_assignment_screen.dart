import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import 'components/role_character_shelf.dart';
import 'components/role_slot_card.dart';
import 'components/role_step_instruction.dart';
import 'components/role_story_summary.dart';
import 'role_assignment_controller.dart';

export 'role_assignment_controller.dart';
export 'role_assignment_styles.dart';

/// 🎭 Màn hình Phân Vai Nhân Vật Vào Truyện (RoleAssignmentScreen)
/// Đã tái cấu trúc theo mô hình Component hóa siêu tinh gọn:
/// - Controller: [RoleAssignmentController]
/// - Stylesheet: [RoleAssignmentStyles]
/// - Components: [RoleStorySummary], [RoleStepInstruction], [RoleSlotCard], [RoleCharacterShelf]
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
                    Expanded(flex: 3, child: RoleStorySummary(story: story)),
                    const SizedBox(width: 16),
                    const Expanded(flex: 2, child: RoleStepInstruction()),
                  ],
                )
              else ...[
                RoleStorySummary(story: story),
                const SizedBox(height: 14),
                const RoleStepInstruction(),
              ],
              const SizedBox(height: 18),

              // 2. Hai vị trí vai diễn
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildHeroSlotCard(state)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCompanionSlotCard(state)),
                  ],
                )
              else ...[
                _buildHeroSlotCard(state),
                const SizedBox(height: 14),
                _buildCompanionSlotCard(state),
              ],
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

              // 4. Danh sách nhân vật
              RoleCharacterShelf(
                state: state,
                isTablet: isTablet,
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

  Widget _buildHeroSlotCard(AppState state) {
    return RoleSlotCard(
      title: 'VAI 1: BẠN CHÍNH',
      description: 'Nhân vật dẫn dắt câu chuyện cổ tích',
      assignedCharacter: state.heroCharacter,
      roleTemplate: _controller.heroRole,
      isTarget: _controller.targetSlot == 1,
      onTap: () => _controller.setTargetSlot(1),
      onClear: () => state.assignHeroCharacter(null),
      onResetDefault: () => state.assignHeroCharacter(null),
    );
  }

  Widget _buildCompanionSlotCard(AppState state) {
    return RoleSlotCard(
      title: 'VAI 2: BẠN ĐI CÙNG',
      description: 'Người bạn trung thành sẻ chia mọi khó khăn',
      assignedCharacter: state.companionCharacter,
      roleTemplate: _controller.companionRole,
      isTarget: _controller.targetSlot == 2,
      onTap: () => _controller.setTargetSlot(2),
      onClear: () => state.assignCompanionCharacter(null),
      onResetDefault: () => state.assignCompanionCharacter(null),
    );
  }
}
