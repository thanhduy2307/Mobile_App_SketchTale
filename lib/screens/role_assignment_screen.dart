import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'story_player_screen.dart';

class RoleAssignmentScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onOpenParentGate;

  const RoleAssignmentScreen({
    super.key,
    required this.appState,
    required this.onOpenParentGate,
  });

  @override
  State<RoleAssignmentScreen> createState() => _RoleAssignmentScreenState();
}

class _RoleAssignmentScreenState extends State<RoleAssignmentScreen> {
  int _targetSlot = 1; // 1: Hero, 2: Companion

  void _startStory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryPlayerScreen(
          appState: widget.appState,
          story: widget.appState.currentStory,
          onOpenParentGate: widget.onOpenParentGate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final story = state.currentStory;

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Story Quick Summary Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFE4E2DD),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      story.coverUrl,
                      width: 70,
                      height: 85,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 70,
                        height: 85,
                        color: AppColors.primaryContainer,
                        child: const Icon(Icons.auto_stories_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryFixed,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                story.ageRange,
                                style: AppTypography.labelSm(color: AppColors.onTertiaryFixed),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                story.category,
                                style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          story.title,
                          style: AppTypography.headlineMd(color: AppColors.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            'Cần: 1 Bạn Chính + 1 Bạn Đi Cùng',
                            style: AppTypography.labelSm(color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Step Instruction Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.theater_comedy_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bé ơi, ai sẽ đóng vai trong truyện?',
                          style: AppTypography.labelMd(color: AppColors.onSecondaryFixed),
                        ),
                        Text(
                          'Gán tranh bé vẽ để bắt đầu hành trình nhé!',
                          style: AppTypography.bodyMd(color: AppColors.onSecondaryFixedVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Role 1 Slot: Main Hero
            GestureDetector(
              onTap: () => setState(() => _targetSlot = 1),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _targetSlot == 1 ? AppColors.primaryContainer : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 4), blurRadius: 0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('1', style: AppTypography.labelMd(color: AppColors.onPrimaryContainer)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(story.heroRoleTitle, style: AppTypography.headlineMd(color: AppColors.onSurface)),
                                Text('Nhân vật chính (Bắt buộc)', style: AppTypography.labelSm(color: AppColors.secondary)),
                              ],
                            ),
                          ],
                        ),
                        if (state.heroCharacter != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sync_rounded, size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text('Đổi bạn', style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (state.heroCharacter != null)
                      _buildAssignedCharacterCard(state.heroCharacter!)
                    else
                      _buildEmptySlotCard('Chạm để chọn Nhân vật chính'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Role 2 Slot: Companion
            GestureDetector(
              onTap: () => setState(() => _targetSlot = 2),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _targetSlot == 2 ? AppColors.tertiaryContainer : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 4), blurRadius: 0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.tertiaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('2', style: AppTypography.labelMd(color: AppColors.onTertiaryContainer)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(story.companionRoleTitle, style: AppTypography.headlineMd(color: AppColors.onSurface)),
                                Text('Bạn đồng hành (Tùy chọn)', style: AppTypography.labelSm(color: AppColors.tertiary)),
                              ],
                            ),
                          ],
                        ),
                        if (state.companionCharacter != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sync_rounded, size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text('Đổi bạn', style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (state.companionCharacter != null)
                      _buildAssignedCharacterCard(state.companionCharacter!)
                    else
                      _buildEmptySlotCard('Chạm để chọn Bạn đồng hành'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Kid's Character Drawer / Quick Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.collections_bookmark_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 6),
                    Text('Kho Bạn Bè Của Bé', style: AppTypography.headlineMd(color: AppColors.onSurface)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text('${state.characters.length} bạn', style: AppTypography.labelSm(color: AppColors.primary)),
                    ),
                  ],
                ),
                Text(
                  _targetSlot == 1 ? '👉 Đang chọn Vị trí 1' : '👉 Đang chọn Vị trí 2',
                  style: AppTypography.labelSm(color: AppColors.secondary),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Horizontal character shelf
            SizedBox(
              height: 145,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: state.characters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, idx) {
                  final char = state.characters[idx];
                  final isCurrentHero = (state.heroCharacter?.id == char.id);
                  final isCurrentCompanion = (state.companionCharacter?.id == char.id);
                  final isSelected = (_targetSlot == 1 && isCurrentHero) || (_targetSlot == 2 && isCurrentCompanion);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_targetSlot == 1) {
                          state.setHeroCharacter(char);
                        } else {
                          state.setCompanionCharacter(char);
                        }
                      });
                    },
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary : const Color(0xFFE4E2DD),
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                char.avatar3dUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(Icons.cruelty_free_rounded, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            char.name,
                            style: AppTypography.labelSm(color: AppColors.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isCurrentHero ? '★ Vị trí 1' : (isCurrentCompanion ? '★ Vị trí 2' : 'Chọn gán vai'),
                            style: AppTypography.labelSm(
                              color: isCurrentHero
                                  ? AppColors.primary
                                  : (isCurrentCompanion ? AppColors.tertiary : AppColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Start Story CTA Button
            ChunkyButton(
              height: 62,
              borderDepth: 6,
              backgroundColor: AppColors.primaryContainer,
              borderColor: const Color(0xFFD99800),
              foregroundColor: AppColors.onPrimaryContainer,
              onPressed: _startStory,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_stories_rounded, size: 26, color: AppColors.onPrimaryContainer),
                  const SizedBox(width: 10),
                  Text(
                    'Bắt đầu chuyến phiêu lưu! 🚀',
                    style: AppTypography.headlineMd(color: AppColors.onPrimaryContainer),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedCharacterCard(KidCharacter char) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              char.avatar3dUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 56,
                height: 56,
                color: AppColors.primaryContainer,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(char.name, style: AppTypography.headlineMd(color: AppColors.onSurface)),
                Text(char.title, style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: AppColors.accentMintDark),
                    const SizedBox(width: 4),
                    Text('Đã được Ba Mẹ duyệt 🌟', style: AppTypography.labelSm(color: AppColors.accentMintDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlotCard(String prompt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6C4AC), style: BorderStyle.solid, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, color: AppColors.onPrimaryContainer, size: 28),
          ),
          const SizedBox(height: 8),
          Text(prompt, style: AppTypography.labelMd(color: AppColors.primary)),
          Text('Chọn bạn từ kho bạn bè phía dưới nha!', style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
